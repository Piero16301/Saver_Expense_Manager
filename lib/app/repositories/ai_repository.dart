import 'dart:typed_data';

import 'package:firebase_ai/firebase_ai.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:gemini_nano_android/gemini_nano_android.dart';
import 'package:saver_expense_manager/app/app.dart';

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
  }) async =>
      null;

  @override
  Future<String?> generateContentLocal({
    required PromptPart textPrompt,
    PromptPart? imagePrompt,
  }) async =>
      null;
}

class FirebaseAiRepository implements AiRepository {
  FirebaseAiRepository({
    FirebaseAI? remoteModel,
    GeminiNanoAndroid? localModel,
  })  : _remoteModel = remoteModel ??
            FirebaseAI.googleAI(appCheck: FirebaseAppCheck.instance),
        _localModel = localModel ?? GeminiNanoAndroid();

  final FirebaseAI _remoteModel;
  final GeminiNanoAndroid _localModel;
  bool _isLocalModelAvailable = false;

  @override
  Future<void> initialize() async {
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
      final remoteModel = _remoteModel.generativeModel(
        model: remoteConfig.geminiModelId,
        safetySettings: [
          SafetySetting(
            HarmCategory.dangerousContent,
            HarmBlockThreshold.none,
            null,
          ),
        ],
        generationConfig: GenerationConfig(
          responseMimeType: responseMimeType,
        ),
      );

      final contentPrompt = prompt.map((p) {
        switch (p.type) {
          case PromptPartType.text:
            return Content.text(p.text ?? '');
          case PromptPartType.file:
            return Content.inlineData(
              p.mimeType ?? '',
              p.bytes ?? Uint8List(0),
            );
        }
      });

      final response = await remoteModel.generateContent(contentPrompt);

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

      return response.first.isEmpty ? null : response.first;
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
