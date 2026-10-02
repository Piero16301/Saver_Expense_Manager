import 'dart:convert';
import 'dart:typed_data';

import 'package:firebase_ai/firebase_ai.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:gemini_nano_android/gemini_nano_android.dart';
import 'package:saver_expense_manager/app/app.dart';

typedef TemplateContentGenerator =
    Future<GenerateContentResponse> Function(
      String templateId, {
      required Map<String, Object?> inputs,
    });

abstract class AiRepository {
  Future<void> initialize();
  bool get isLocalModelAvailable;
  Future<String?> generateContentFromTemplate({
    required String templateId,
    PromptPart? attachment,
    Map<String, Object?> inputs = const {},
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
  bool get isLocalModelAvailable => false;

  @override
  Future<String?> generateContentFromTemplate({
    required String templateId,
    PromptPart? attachment,
    Map<String, Object?> inputs = const {},
  }) async => null;

  @override
  Future<String?> generateContentLocal({
    required PromptPart textPrompt,
    PromptPart? imagePrompt,
  }) async => null;
}

class FirebaseAiRepository implements AiRepository {
  FirebaseAiRepository({
    FirebaseAI? remoteModel,
    TemplateContentGenerator? templateGenerator,
    GeminiNanoAndroid? localModel,
  }) : _remoteAi = remoteModel,
       _templateContentGenerator = templateGenerator,
       _localModel = localModel ?? GeminiNanoAndroid();

  final FirebaseAI? _remoteAi;
  final TemplateContentGenerator? _templateContentGenerator;
  final GeminiNanoAndroid _localModel;
  bool _isLocalModelAvailable = false;

  @override
  Future<void> initialize() async {
    if (kIsWeb) {
      _isLocalModelAvailable = false;
      return;
    }
    _isLocalModelAvailable = await _localModel.isAvailable();
  }

  @override
  bool get isLocalModelAvailable => _isLocalModelAvailable;

  @override
  Future<String?> generateContentFromTemplate({
    required String templateId,
    PromptPart? attachment,
    Map<String, Object?> inputs = const {},
  }) async {
    if (templateId.isEmpty) {
      return null;
    }

    final performance = getIt<PerformanceService>();
    final trace = performance.startTrace('gemini_generate_from_template');

    try {
      final templateInputs = Map<String, Object?>.from(inputs);

      if (attachment != null) {
        if (attachment.type.isFile && attachment.bytes != null) {
          final effectiveMime =
              (attachment.mimeType != null &&
                  attachment.mimeType!.trim().isNotEmpty)
              ? attachment.mimeType!
              : ((templateInputs['mimeType'] as String?)?.trim().isNotEmpty ==
                        true
                    ? templateInputs['mimeType']! as String
                    : 'image/jpeg');
          if (!templateInputs.containsKey('receiptUrl')) {
            final base64Data = base64Encode(attachment.bytes!);
            templateInputs['receiptUrl'] =
                'data:$effectiveMime;base64,$base64Data';
          }
          if (attachment.mimeType != null &&
              attachment.mimeType!.trim().isNotEmpty) {
            templateInputs.putIfAbsent('mimeType', () => attachment.mimeType);
          }
        } else if (attachment.type.isText && attachment.text != null) {
          templateInputs.putIfAbsent('text', () => attachment.text);
        }
      }

      // Ensure mimeType is always set and never empty.
      final currentMime = templateInputs['mimeType'];
      if (currentMime == null ||
          (currentMime is String && currentMime.trim().isEmpty)) {
        templateInputs['mimeType'] = 'image/jpeg';
      }

      templateInputs.updateAll((key, value) {
        if (value is Uint8List) {
          return base64Encode(value);
        }
        return value;
      });

      final GenerateContentResponse response;
      if (_templateContentGenerator != null) {
        response = await _templateContentGenerator(
          templateId,
          inputs: templateInputs,
        );
      } else {
        final ai =
            _remoteAi ??
            FirebaseAI.agentPlatform(useLimitedUseAppCheckTokens: true);
        // Server template API is marked experimental in firebase_ai.
        // ignore: experimental_member_use
        final templateModel = ai.templateGenerativeModel();
        // Server template API is marked experimental in firebase_ai.
        // ignore: experimental_member_use
        response = await templateModel.generateContent(
          templateId,
          inputs: templateInputs,
        );
      }

      return response.text;
    } catch (e, stackTrace) {
      getIt<CrashService>().recordError(
        e,
        stackTrace,
        reason: 'AiService generateContentFromTemplate error',
      );
      rethrow;
    } finally {
      performance.stopTrace(trace);
    }
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

    final performance = getIt<PerformanceService>();
    final trace = performance.startTrace('gemini_generate_local');
    try {
      if (imagePrompt != null &&
          imagePrompt.mimeType != 'image/jpeg' &&
          imagePrompt.mimeType != 'image/png') {
        return null;
      }

      final response = await _localModel.generate(
        prompt: textPrompt.text ?? '',
        image: imagePrompt?.bytes,
      );

      return response.isEmpty || response.first.isEmpty ? null : response.first;
    } catch (e, stackTrace) {
      getIt<CrashService>().recordError(
        e,
        stackTrace,
        reason: 'AiService generateContentLocal error',
      );
      rethrow;
    } finally {
      performance.stopTrace(trace);
    }
  }
}
