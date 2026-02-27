import 'dart:typed_data';

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
    test('isLocalModelAvailable returns false initially', () {
      expect(aiService.isLocalModelAvailable, isFalse);
    });

    test('initialize updates isLocalModelAvailable based on native call',
        () async {
      when(() => mockGeminiNanoAndroid.isAvailable())
          .thenAnswer((_) async => true);
      await aiService.initialize();
      expect(aiService.isLocalModelAvailable, isTrue);
    });

    group('generateContentRemote', () {
      test('returns null when prompt is empty', () async {
        final result = await aiService.generateContentRemote(prompt: []);
        expect(result, isNull);
      });
    });

    group('generateContentLocal', () {
      setUp(() {
        when(() => mockGeminiNanoAndroid.isAvailable())
            .thenAnswer((_) async => true);
      });

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

      test('returns null if textPrompt is not text', () async {
        final result = await aiService.generateContentLocal(
          textPrompt: const PromptPart(
            type: PromptPartType.file,
          ),
        );
        expect(result, isNull);
      });

      test('returns null if imagePrompt is not a file type', () async {
        final result = await aiService.generateContentLocal(
          textPrompt: const PromptPart(type: PromptPartType.text, text: 'Hi'),
          imagePrompt:
              const PromptPart(type: PromptPartType.text, text: 'Oops'),
        );
        expect(result, isNull);
      });

      test('returns null if imagePrompt mimeType is not jpeg or png', () async {
        final result = await aiService.generateContentLocal(
          textPrompt: const PromptPart(type: PromptPartType.text, text: 'Hi'),
          imagePrompt: const PromptPart(
            type: PromptPartType.file,
            mimeType: 'image/gif',
          ),
        );
        expect(result, isNull);
      });

      test('returns null if generated response is empty', () async {
        when(
          () => mockGeminiNanoAndroid.generate(
            prompt: any(named: 'prompt'),
            image: any(named: 'image'),
          ),
        ).thenAnswer((_) async => ['']);

        final result = await aiService.generateContentLocal(
          textPrompt: const PromptPart(type: PromptPartType.text, text: 'Hi'),
        );
        expect(result, isNull);
      });

      test(
          'generateContentLocal returns result if localModel available with'
          ' image', () async {
        when(
          () => mockGeminiNanoAndroid.generate(
            prompt: 'Hello',
            image: any(named: 'image'),
          ),
        ).thenAnswer((_) async => ['Generated Response']);

        final result = await aiService.generateContentLocal(
          textPrompt: const PromptPart(
            type: PromptPartType.text,
            text: 'Hello',
          ),
          imagePrompt: PromptPart(
            type: PromptPartType.file,
            mimeType: 'image/jpeg',
            bytes: Uint8List.fromList([1, 2, 3]),
          ),
        );

        expect(result, 'Generated Response');
      });
    });
  });
}
