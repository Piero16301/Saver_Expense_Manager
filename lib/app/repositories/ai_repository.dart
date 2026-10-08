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
  Future<String?> generateContentRemote({
    required List<PromptPart> prompt,
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
  bool get isLocalModelAvailable => false;

  @override
  Future<String?> generateContentRemote({
    required List<PromptPart> prompt,
    String responseMimeType = 'text/plain',
  }) async => null;

  @override
  Future<String?> generateContentLocal({
    required PromptPart textPrompt,
    PromptPart? imagePrompt,
  }) async => null;
}

class FirebaseAiRepository implements AiRepository {
  FirebaseAiRepository({FirebaseAI? remoteModel, GeminiNanoAndroid? localModel})
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
    _isLocalModelAvailable = await _localModel.isAvailable();
  }

  @override
  bool get isLocalModelAvailable => _isLocalModelAvailable;

  @override
  Future<String?> generateContentRemote({
    required List<PromptPart> prompt,
    String responseMimeType = 'text/plain',
  }) async {
    if (prompt.isEmpty) {
      return null;
    }

    final performance = getIt<PerformanceService>();
    final trace = performance.startTrace('gemini_generate_remote');

    try {
      final remoteConfig = getIt<RemoteConfigService>();
      final model = remoteConfig.geminiModelName;

      final ai =
          _remoteAi ??
          FirebaseAI.agentPlatform(useLimitedUseAppCheckTokens: true);

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

      final response = await genModel.generateContent([Content.multi(parts)]);

      return response.text;
    } catch (e, stackTrace) {
      getIt<CrashService>().recordError(
        e,
        stackTrace,
        reason: 'AiService generateContentRemote error',
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
