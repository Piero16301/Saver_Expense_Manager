import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
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

class GeminiAiRepository implements AiRepository {
  GeminiAiRepository({
    Dio? dio,
    GeminiNanoAndroid? localModel,
  })  : _dio = dio ?? Dio(),
        _localModel = localModel ?? GeminiNanoAndroid();

  final Dio _dio;
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
      final model = remoteConfig.geminiModelId;
      final apiKey = remoteConfig.geminiApiKey;

      final url =
          'https://generativelanguage.googleapis.com/v1beta/models/$model:generateContent?key=$apiKey';

      final partsJson = prompt.map((p) {
        switch (p.type) {
          case PromptPartType.text:
            return {
              'text': p.text ?? '',
            };
          case PromptPartType.file:
            return {
              'inlineData': {
                'mimeType': p.mimeType ?? '',
                'data': base64Encode(p.bytes ?? Uint8List(0)),
              },
            };
        }
      }).toList();

      final requestBody = {
        'contents': [
          {
            'parts': partsJson,
          }
        ],
        'safetySettings': [
          {
            'category': 'HARM_CATEGORY_DANGEROUS_CONTENT',
            'threshold': 'BLOCK_NONE',
          },
        ],
        'generationConfig': {
          'responseMimeType': responseMimeType,
        },
      };

      final response = await _dio.post<Map<String, dynamic>>(
        url,
        data: requestBody,
        options: Options(
          headers: {
            'Content-Type': 'application/json',
          },
        ),
      );

      final responseData = response.data;
      if (response.statusCode == 200 && responseData != null) {
        final candidates = responseData['candidates'] as List<dynamic>?;
        if (candidates != null && candidates.isNotEmpty) {
          final candidate = candidates.first as Map<String, dynamic>;
          final content = candidate['content'] as Map<String, dynamic>?;
          if (content != null) {
            final parts = content['parts'] as List<dynamic>?;
            if (parts != null && parts.isNotEmpty) {
              final part = parts.first as Map<String, dynamic>;
              return part['text'] as String?;
            }
          }
        }
      }

      return null;
    } catch (e, stackTrace) {
      getIt<CrashService>().recordError(
        e,
        stackTrace,
        reason: 'AiService generateContentRemote error via HTTP/Dio',
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
