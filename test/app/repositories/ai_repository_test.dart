import 'dart:typed_data';

import 'package:firebase_ai/firebase_ai.dart';
import 'package:firebase_ai/src/base_model.dart';
import 'package:firebase_ai/src/client.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gemini_nano_android/gemini_nano_android.dart';
import 'package:mocktail/mocktail.dart';
import 'package:saver_expense_manager/app/app.dart';

class MockFirebaseAI extends Mock implements FirebaseAI;

class MockFirebaseApp extends Mock implements FirebaseApp;

class MockApiClient extends Mock implements ApiClient;

class MockGeminiNanoAndroid extends Mock implements GeminiNanoAndroid;

void main() {
  late MockFirebaseAI mockRemoteModel;
  late MockGeminiNanoAndroid mockLocalModel;

  late FirebaseAiRepository repository;

  GenerativeModel createTestModel(ApiClient client) {
    final app = MockFirebaseApp();
    when(() => app.name).thenReturn('default');
    when(() => app.options).thenReturn(
      const FirebaseOptions(
        apiKey: 'key',
        appId: 'id',
        messagingSenderId: 'id',
        projectId: 'proj',
      ),
    );
    return createModelWithClient(
      app: app,
      location: 'us-central1',
      model: 'gemini-1.5-flash',
      client: client,
      useAgentPlatform: true,
    );
  }

  setUpAll(() {
    registerFallbackValue(Content.text(''));
    registerFallbackValue(Uri());
    registerFallbackValue(GenerationConfig());
    registerFallbackValue(
      SafetySetting(
        HarmCategory.dangerousContent,
        HarmBlockThreshold.none,
        null,
      ),
    );
  });

  setUp(() {
    mockRemoteModel = MockFirebaseAI();
    mockLocalModel = MockGeminiNanoAndroid();

    repository = FirebaseAiRepository(
      remoteModel: mockRemoteModel,
      localModel: mockLocalModel,
    );
  });

  group('MockAiRepository', () {
    test(
      'returns realistic mock responses for remote and local flows',
      () async {
        final mock = MockAiRepository();
        await mock.initialize();
        expect(mock.isLocalModelAvailable, isTrue);

        expect(
          await mock.generateContentRemote(
            prompt: [],
            model: 'gemini-1.5-flash',
          ),
          isNull,
        );

        final recommendations = await mock.generateContentRemote(
          prompt: [PromptPart.text(text: 'recommendations in es-PE')],
          model: 'gemini-3.5-flash-lite',
        );
        expect(recommendations, isNotNull);
        expect(recommendations!.split('|||'), hasLength(3));

        final receiptJson = await mock.generateContentRemote(
          prompt: [
            PromptPart.text(text: 'extract expense receipt'),
            PromptPart.file(
              mimeType: 'image/png',
              bytes: Uint8List.fromList([1]),
            ),
          ],
          model: 'gemini-3.5-flash-lite',
          responseMimeType: 'application/json',
        );
        expect(receiptJson, contains('"category":"FEEDING"'));

        final localRecommendations = await mock.generateContentLocal(
          textPrompt: const PromptPart(
            text: 'en-US',
            type: PromptPartType.text,
          ),
        );
        expect(localRecommendations, isNotNull);
        expect(localRecommendations!.split('|||'), hasLength(3));

        final localReceiptJson = await mock.generateContentLocal(
          textPrompt: const PromptPart(
            text: 'extract income',
            type: PromptPartType.text,
          ),
          imagePrompt: const PromptPart(type: PromptPartType.file),
        );
        expect(localReceiptJson, contains('"category":"FREELANCE"'));
      },
    );
  });

  group('FirebaseAiRepository', () {
    test('initialize checks local model availability', () async {
      when(() => mockLocalModel.isAvailable()).thenAnswer((_) async => true);
      await repository.initialize();
      expect(repository.isLocalModelAvailable, isTrue);
    });

    test(
      'initialize sets isLocalModelAvailable to false on exception',
      () async {
        when(() => mockLocalModel.isAvailable())
            .thenThrow(Exception('AICore error'));
        await repository.initialize();
        expect(repository.isLocalModelAvailable, isFalse);
      },
    );

    group('generateContentRemote', () {
      test('returns null if prompt is empty', () async {
        final result = await repository.generateContentRemote(
          prompt: [],
          model: 'gemini-1.5-flash',
        );
        expect(result, isNull);
      });

      test(
        'calls generativeModel and returns response text with file and text',
        () async {
          final mockApiClient = MockApiClient();
          when(() => mockApiClient.makeRequest(any(), any())).thenAnswer(
            (_) async => {
              'candidates': [
                {
                  'content': {
                    'role': 'model',
                    'parts': [
                      {'text': '{"title": "Test"}'},
                    ],
                  },
                },
              ],
            },
          );

          final testModel = createTestModel(mockApiClient);
          when(
            () => mockRemoteModel.generativeModel(
              model: any(named: 'model'),
              generationConfig: any(named: 'generationConfig'),
              safetySettings: any(named: 'safetySettings'),
            ),
          ).thenReturn(testModel);

          final result = await repository.generateContentRemote(
            prompt: [
              PromptPart.text(text: 'Extract'),
              PromptPart.file(
                mimeType: 'image/png',
                bytes: Uint8List.fromList([1, 2, 3]),
              ),
            ],
            model: 'gemini-1.5-flash',
          );

          expect(result, '{"title": "Test"}');
        },
      );

      test('returns null when prompt parts are not text or file', () async {
        final mockApiClient = MockApiClient();
        final testModel = createTestModel(mockApiClient);
        when(
          () => mockRemoteModel.generativeModel(
            model: any(named: 'model'),
            generationConfig: any(named: 'generationConfig'),
            safetySettings: any(named: 'safetySettings'),
          ),
        ).thenReturn(testModel);

        final result = await repository.generateContentRemote(
          prompt: [const PromptPart(type: PromptPartType.text)],
          model: 'gemini-1.5-flash',
        );

        expect(result, isNull);
      });

      test('rethrows if remote generation fails', () async {
        final mockApiClient = MockApiClient();
        when(() => mockApiClient.makeRequest(any(), any()))
            .thenThrow(Exception('Remote Fail'));
        final testModel = createTestModel(mockApiClient);
        when(
          () => mockRemoteModel.generativeModel(
            model: any(named: 'model'),
            generationConfig: any(named: 'generationConfig'),
            safetySettings: any(named: 'safetySettings'),
          ),
        ).thenReturn(testModel);

        await expectLater(
          () => repository.generateContentRemote(
            prompt: [PromptPart.text(text: 'test')],
            model: 'gemini-1.5-flash',
          ),
          throwsException,
        );
      });

      test('default constructor initializes correctly', () {
        final repo = FirebaseAiRepository();
        expect(repo, isNotNull);
      });
    });

    group('generateContentLocal', () {
      test('returns null if local model not available', () async {
        when(() => mockLocalModel.isAvailable()).thenAnswer((_) async => false);
        final result = await repository.generateContentLocal(
          textPrompt: const PromptPart(text: 'p', type: PromptPartType.text),
        );
        expect(result, isNull);
      });

      test('returns null if prompt is not text', () async {
        when(() => mockLocalModel.isAvailable()).thenAnswer((_) async => true);
        final result = await repository.generateContentLocal(
          textPrompt: const PromptPart(type: PromptPartType.file),
        );
        expect(result, isNull);
      });

      test('returns null if imagePrompt is not file', () async {
        when(() => mockLocalModel.isAvailable()).thenAnswer((_) async => true);
        final result = await repository.generateContentLocal(
          textPrompt: const PromptPart(text: 'p', type: PromptPartType.text),
          imagePrompt: const PromptPart(type: PromptPartType.text),
        );
        expect(result, isNull);
      });

      test('returns null if image MIME is invalid', () async {
        when(() => mockLocalModel.isAvailable()).thenAnswer((_) async => true);
        final result = await repository.generateContentLocal(
          textPrompt: const PromptPart(text: 'p', type: PromptPartType.text),
          imagePrompt: const PromptPart(
            type: PromptPartType.file,
            mimeType: 'application/pdf',
          ),
        );
        expect(result, isNull);
      });

      test('calls generate and returns first result', () async {
        when(() => mockLocalModel.isAvailable()).thenAnswer((_) async => true);
        when(
          () => mockLocalModel.generate(
            prompt: any<String>(named: 'prompt'),
            image: any<Uint8List?>(named: 'image'),
          ),
        ).thenAnswer((_) async => ['Local Result']);

        final result = await repository.generateContentLocal(
          textPrompt: const PromptPart(text: 'p', type: PromptPartType.text),
        );

        expect(result, equals('Local Result'));
      });

      test('calls generate with imagePrompt and returns result', () async {
        when(() => mockLocalModel.isAvailable()).thenAnswer((_) async => true);
        when(
          () => mockLocalModel.generate(
            prompt: any<String>(named: 'prompt'),
            image: any<Uint8List?>(named: 'image'),
          ),
        ).thenAnswer((_) async => ['Image Result']);

        final result = await repository.generateContentLocal(
          textPrompt: const PromptPart(text: 'p', type: PromptPartType.text),
          imagePrompt: PromptPart.file(
            mimeType: 'image/jpeg',
            bytes: Uint8List(5),
          ),
        );

        expect(result, equals('Image Result'));
        verify(
          () => mockLocalModel.generate(
            prompt: 'p',
            image: any<Uint8List?>(named: 'image'),
          ),
        ).called(1);
      });

      test('returns null if generate response is empty list', () async {
        when(() => mockLocalModel.isAvailable()).thenAnswer((_) async => true);
        when(
          () => mockLocalModel.generate(
            prompt: any<String>(named: 'prompt'),
            image: any<Uint8List?>(named: 'image'),
          ),
        ).thenAnswer((_) async => []);

        final result = await repository.generateContentLocal(
          textPrompt: const PromptPart(text: 'p', type: PromptPartType.text),
        );

        expect(result, isNull);
      });

      test('returns null if first element of response is empty', () async {
        when(() => mockLocalModel.isAvailable()).thenAnswer((_) async => true);
        when(
          () => mockLocalModel.generate(
            prompt: any<String>(named: 'prompt'),
            image: any<Uint8List?>(named: 'image'),
          ),
        ).thenAnswer((_) async => ['']);

        final result = await repository.generateContentLocal(
          textPrompt: const PromptPart(text: 'p', type: PromptPartType.text),
        );

        expect(result, isNull);
      });

      test('rethrows on local failure', () async {
        when(() => mockLocalModel.isAvailable()).thenAnswer((_) async => true);
        when(
          () => mockLocalModel.generate(
            prompt: any<String>(named: 'prompt'),
            image: any<Uint8List?>(named: 'image'),
          ),
        ).thenThrow(Exception('Local Fail'));

        await expectLater(
          () => repository.generateContentLocal(
            textPrompt: const PromptPart(text: 'p', type: PromptPartType.text),
          ),
          throwsException,
        );
      });
    });
  });
}
