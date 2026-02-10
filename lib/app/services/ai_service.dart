import 'package:firebase_ai/firebase_ai.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:saver_expense_manager/app/app.dart';

class AiService {
  AiService({required RemoteConfigService remoteConfig})
      : _model = FirebaseAI.googleAI(
          appCheck: FirebaseAppCheck.instance,
          auth: FirebaseAuth.instance,
        ).generativeModel(
          model: remoteConfig.geminiModelId,
          safetySettings: [
            SafetySetting(
              HarmCategory.dangerousContent,
              HarmBlockThreshold.none,
              null,
            ),
          ],
          generationConfig: GenerationConfig(
            responseMimeType: 'application/json',
          ),
        );

  final GenerativeModel _model;

  GenerativeModel get model => _model;
}
