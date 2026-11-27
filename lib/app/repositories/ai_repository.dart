import 'dart:convert';

import 'package:firebase_ai/firebase_ai.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:gemini_nano_android/gemini_nano_android.dart';
import 'package:intl/intl.dart';
import 'package:saver_expense_manager/app/app.dart';

typedef TemplateContentGenerator = Future<GenerateContentResponse> Function(
  String templateId, {
  required Map<String, Object?> inputs,
});

abstract class AiRepository {
  Future<void> initialize();
  bool get isLocalModelAvailable;
  Future<String?> generateContentRemote({
    required List<PromptPart> prompt,
    required String model,
    String responseMimeType = 'text/plain',
  });
  Future<String?> generateContentLocal({
    required PromptPart textPrompt,
    PromptPart? imagePrompt,
  });
}

class MockAiRepository implements AiRepository {
  @override
  Future<void> initialize() async {}

  @override
  bool get isLocalModelAvailable => true;

  String _generateMockResponse({
    required String promptText,
    required bool isReceiptExtraction,
  }) {
    if (isReceiptExtraction) {
      final isIncome = promptText.toLowerCase().contains('income');
      final today = DateFormat('dd/MM/yyyy').format(DateTime.now());
      return jsonEncode({
        'title': isIncome
            ? 'Freelance services payment'
            : 'Grocery shopping',
        'description': isIncome
            ? 'Transfer received for professional services.'
            : 'Purchase of groceries and beverages at Metro.',
        'date': today,
        'category': isIncome ? 'FREELANCE' : 'FEEDING',
        'price': isIncome ? 450.00 : 64.50,
        'company': isIncome ? 'bcp' : 'metro',
      });
    }

    return '☕ **Daily coffee runs:** Cutting back on frequent cafe visits '
        r'could save you around **$25 per month**. ||| '
        '🚗 **Short ride-shares:** Grouping errands or taking public transit '
        'for short trips can lower your transport spend by **15%**. ||| '
        '📱 **Digital subscriptions:** Review recurring streaming and music '
        'plans to avoid overlapping charges.';
  }

  @override
  Future<String?> generateContentRemote({
    required List<PromptPart> prompt,
    required String model,
    String responseMimeType = 'text/plain',
  }) async {
    if (prompt.isEmpty) {
      return null;
    }
    final promptText = prompt
        .where((p) => p.type.isText && p.text != null)
        .map((p) => p.text!)
        .join('\n');
    final hasFile = prompt.any((p) => p.type.isFile);
    return _generateMockResponse(
      promptText: promptText,
      isReceiptExtraction: responseMimeType == 'application/json' || hasFile,
    );
  }

  @override
  Future<String?> generateContentLocal({
    required PromptPart textPrompt,
    PromptPart? imagePrompt,
  }) async {
    return _generateMockResponse(
      promptText: textPrompt.text ?? '',
      isReceiptExtraction: imagePrompt != null,
    );
  }
}

class FirebaseAiRepository implements AiRepository {
  new({FirebaseAI? remoteModel, GeminiNanoAndroid? localModel})
    : _remoteAi = remoteModel,
      _localModel = localModel ?? GeminiNanoAndroid();

  final FirebaseAI? _remoteAi;
  final GeminiNanoAndroid _localModel;
  bool _isLocalModelAvailable = false;

  @override
  Future<void> initialize() async {
    if (kIsWeb) {
      _isLocalModelAvailable = false;
      return;
    }
    try {
      _isLocalModelAvailable = await _localModel.isAvailable().timeout(
        AppVariables.timeoutDuration,
        onTimeout: () => false,
      );
    } on Object catch (_) {
      _isLocalModelAvailable = false;
    }
  }

  @override
  bool get isLocalModelAvailable => _isLocalModelAvailable;

  @override
  Future<String?> generateContentRemote({
    required List<PromptPart> prompt,
    required String model,
    String responseMimeType = 'text/plain',
  }) async {
    if (prompt.isEmpty) {
      return null;
    }

    final ai = _remoteAi ?? FirebaseAI.agentPlatform();

    final genModel = ai.generativeModel(
      model: model,
      generationConfig: GenerationConfig(responseMimeType: responseMimeType),
      safetySettings: [
        SafetySetting(
          HarmCategory.dangerousContent,
          HarmBlockThreshold.none,
          null,
        ),
      ],
    );

    final parts = <Part>[
      for (final item in prompt)
        if (item.type.isText && item.text != null)
          TextPart(item.text!)
        else if (item.type.isFile && item.bytes != null)
          InlineDataPart(
            item.mimeType?.isNotEmpty == true ? item.mimeType! : 'image/jpeg',
            item.bytes!,
          ),
    ];

    if (parts.isEmpty) {
      return null;
    }

    final response = await genModel
        .generateContent([Content.multi(parts)])
        .timeout(AppVariables.aiTimeoutDuration);

    return response.text;
  }

  @override
  Future<String?> generateContentLocal({
    required PromptPart textPrompt,
    PromptPart? imagePrompt,
  }) async {
    if (!(await _localModel.isAvailable())) {
      return null;
    }

    if (!textPrompt.type.isText) {
      return null;
    }

    if (imagePrompt != null && !imagePrompt.type.isFile) {
      return null;
    }

    if (imagePrompt != null &&
        imagePrompt.mimeType != 'image/jpeg' &&
        imagePrompt.mimeType != 'image/png') {
      return null;
    }

    final response = await _localModel
        .generate(prompt: textPrompt.text ?? '', image: imagePrompt?.bytes)
        .timeout(AppVariables.aiTimeoutDuration);

    return response.isEmpty || response.first.isEmpty ? null : response.first;
  }
}
