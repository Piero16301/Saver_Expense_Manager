import 'package:firebase_ai/firebase_ai.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gemini_nano_android/gemini_nano_android.dart';
import 'package:mocktail/mocktail.dart';
import 'package:saver_expense_manager/app/app.dart';

class MockFirebaseAI extends Mock implements FirebaseAI {}

class MockGeminiNanoAndroid extends Mock implements GeminiNanoAndroid {}

class MockRemoteConfigService extends Mock implements RemoteConfigService {}

class MockAuthenticationService extends Mock implements AuthenticationService {}

void main() {
  late AiService aiService;
  late MockFirebaseAI mockFirebaseAI;
  late MockGeminiNanoAndroid mockGeminiNanoAndroid;
  late MockRemoteConfigService mockRemoteConfigService;
  late MockAuthenticationService mockAuthenticationService;

  setUp(() {
    mockFirebaseAI = MockFirebaseAI();
    mockGeminiNanoAndroid = MockGeminiNanoAndroid();
    mockRemoteConfigService = MockRemoteConfigService();
    mockAuthenticationService = MockAuthenticationService();

    when(() => mockRemoteConfigService.geminiModelId).thenReturn('gemini-1');

    aiService = AiService(
      remoteConfig: mockRemoteConfigService,
      authentication: mockAuthenticationService,
      remoteModel: mockFirebaseAI,
      localModel: mockGeminiNanoAndroid,
    );
  });

  setUpAll(() {
    registerFallbackValue(GenerationConfig());
    registerFallbackValue(
      SafetySetting(
        HarmCategory.dangerousContent,
        HarmBlockThreshold.none,
        null,
      ),
    );
    registerFallbackValue(Content.text(''));
  });

  group('AiService', () {
    test('generateContentLocal returns null if localModel not available',
        () async {
      when(() => mockGeminiNanoAndroid.isAvailable())
          .thenAnswer((_) async => false);

      final result = await aiService.generateContentLocal(
        textPrompt: const PromptPart(
          type: PromptPartType.text,
          text: 'Hello',
        ),
      );

      expect(result, isNull);
    });

    test('generateContentLocal returns result if localModel available',
        () async {
      when(() => mockGeminiNanoAndroid.isAvailable())
          .thenAnswer((_) async => true);
      when(
        () => mockGeminiNanoAndroid.generate(
          prompt: 'Hello',
        ),
      ).thenAnswer((_) async => ['Generated Response']);

      final result = await aiService.generateContentLocal(
        textPrompt: const PromptPart(
          type: PromptPartType.text,
          text: 'Hello',
        ),
      );

      expect(result, 'Generated Response');
    });
  });
}
