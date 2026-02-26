import 'dart:typed_data';

import 'package:firebase_ai/firebase_ai.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:gemini_nano_android/gemini_nano_android.dart';
import 'package:saver_expense_manager/app/app.dart';

class AiService {
  AiService({
    required RemoteConfigService remoteConfig,
    required AuthenticationService authentication,
    FirebaseAI? remoteModel,
    GeminiNanoAndroid? localModel,
  }) {
    _remoteConfig = remoteConfig;
    _remoteModel = remoteModel ??
        FirebaseAI.googleAI(
          appCheck: FirebaseAppCheck.instance,
          auth: authentication.auth,
        );
    _localModel = localModel ?? GeminiNanoAndroid();
  }

  bool get isLocalModelAvailable => _isLocalModelAvailable;

  Future<void> initialize() async {
    _isLocalModelAvailable = await _localModel.isAvailable();
  }

  late final RemoteConfigService _remoteConfig;
  late final FirebaseAI _remoteModel;
  late final GeminiNanoAndroid _localModel;
  late final bool _isLocalModelAvailable;

  Future<String?> generateContentRemote({
    required List<PromptPart> prompt,
    String responseMimeType = 'text/plain',
  }) async {
    if (prompt.isEmpty) {
      return null;
    }

    final remoteModel = _remoteModel.generativeModel(
      model: _remoteConfig.geminiModelId,
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
          return Content.inlineData(p.mimeType ?? '', p.bytes ?? Uint8List(0));
      }
    });

    final response = await remoteModel.generateContent(contentPrompt);

    return response.text;
  }

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

    final response = await _localModel.generate(
      prompt: textPrompt.text ?? '',
      image: imagePrompt?.bytes,
    );

    return response.first.isEmpty ? null : response.first;
  }
}
