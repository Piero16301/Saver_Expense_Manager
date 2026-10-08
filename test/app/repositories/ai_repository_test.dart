import 'dart:typed_data';

import 'package:firebase_ai/firebase_ai.dart';
import 'package:firebase_ai/src/base_model.dart';
import 'package:firebase_ai/src/client.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_performance/firebase_performance.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gemini_nano_android/gemini_nano_android.dart';
import 'package:mocktail/mocktail.dart';
import 'package:saver_expense_manager/app/app.dart';

class MockFirebaseAI extends Mock implements FirebaseAI {}

class MockFirebaseApp extends Mock implements FirebaseApp {}

class MockApiClient extends Mock implements ApiClient {}

class MockGeminiNanoAndroid extends Mock implements GeminiNanoAndroid {}

class MockTrace extends Mock implements Trace {}

class MockPerformanceService extends Mock implements PerformanceService {}

class MockRemoteConfigService extends Mock implements RemoteConfigService {}

class MockCrashService extends Mock implements CrashService {}

void main() {
  late MockFirebaseAI mockRemoteModel;
  late MockGeminiNanoAndroid mockLocalModel;
  late MockTrace mockTrace;

  late MockPerformanceService mockPerformanceService;
  late MockRemoteConfigService mockRemoteConfigService;
  late MockCrashService mockCrashService;

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
    registerFallbackValue(MockTrace());
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

  setUp(() async {
    mockRemoteModel = MockFirebaseAI();
    mockLocalModel = MockGeminiNanoAndroid();
    mockTrace = MockTrace();

    mockPerformanceService = MockPerformanceService();
    mockRemoteConfigService = MockRemoteConfigService();
    mockCrashService = MockCrashService();

    await getIt.reset();
    getIt
      ..registerSingleton<PerformanceService>(mockPerformanceService)
      ..registerSingleton<RemoteConfigService>(mockRemoteConfigService)
      ..registerSingleton<CrashService>(mockCrashService);

    when(
      () => mockPerformanceService.startTrace(any<String>()),
    ).thenReturn(mockTrace);
    when(() => mockPerformanceService.stopTrace(any<Trace>())).thenReturn(null);

    repository = FirebaseAiRepository(
      remoteModel: mockRemoteModel,
      localModel: mockLocalModel,
    );
  });

  group('MockAiRepository', () {
    test('Mock tests for coverage', () async {
      final mock = MockAiRepository();
      await mock.initialize();
      expect(mock.isLocalModelAvailable, isFalse);
      expect(
        await mock.generateContentRemote(
          prompt: [PromptPart.text(text: 'test')],
        ),
        isNull,
      );
      expect(
        await mock.generateContentLocal(
          textPrompt: const PromptPart(text: 't', type: PromptPartType.text),
          imagePrompt: const PromptPart(type: PromptPartType.file),
        ),
        isNull,
      );
    });
  });

  group('FirebaseAiRepository', () {
    test('initialize checks local model availability', () async {
      when(() => mockLocalModel.isAvailable()).thenAnswer((_) async => true);
      await repository.initialize();
      expect(repository.isLocalModelAvailable, isTrue);
    });

    group('generateContentRemote', () {
      test('returns null if prompt is empty', () async {
        final result = await repository.generateContentRemote(prompt: []);
        expect(result, isNull);
      });

      test(
        'calls generativeModel and returns response text with file and text',
        () async {
          when(
            () => mockRemoteConfigService.geminiModelName,
          ).thenReturn('gemini-1.5-flash');
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
          );

          expect(result, '{"title": "Test"}');
          verify(
            () => mockPerformanceService.startTrace('gemini_generate_remote'),
          ).called(1);
          verify(() => mockPerformanceService.stopTrace(mockTrace)).called(1);
        },
      );

      test('returns null when prompt parts are not text or file', () async {
        when(
          () => mockRemoteConfigService.geminiModelName,
        ).thenReturn('gemini-1.5-flash');
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
        );

        expect(result, isNull);
      });

      test('records error and rethrows if remote generation fails', () async {
        when(
          () => mockRemoteConfigService.geminiModelName,
        ).thenReturn('gemini-1.5-flash');
        final mockApiClient = MockApiClient();
        when(
          () => mockApiClient.makeRequest(any(), any()),
        ).thenThrow(Exception('Remote Fail'));
        final testModel = createTestModel(mockApiClient);
        when(
          () => mockRemoteModel.generativeModel(
            model: any(named: 'model'),
            generationConfig: any(named: 'generationConfig'),
            safetySettings: any(named: 'safetySettings'),
          ),
        ).thenReturn(testModel);

        expect(
          () => repository.generateContentRemote(
            prompt: [PromptPart.text(text: 'test')],
          ),
          throwsException,
        );

        await Future<void>.delayed(Duration.zero);
        verify(
          () => mockCrashService.recordError(
            any<Object>(),
            any<StackTrace?>(),
            reason: 'AiService generateContentRemote error',
          ),
        ).called(1);
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

      test('records error and rethrows on local failure', () async {
        when(() => mockLocalModel.isAvailable()).thenAnswer((_) async => true);
        when(
          () => mockLocalModel.generate(
            prompt: any<String>(named: 'prompt'),
            image: any<Uint8List?>(named: 'image'),
          ),
        ).thenThrow(Exception('Local Fail'));

        expect(
          () => repository.generateContentLocal(
            textPrompt: const PromptPart(text: 'p', type: PromptPartType.text),
          ),
          throwsException,
        );

        await Future<void>.delayed(Duration.zero);
        verify(
          () => mockCrashService.recordError(
            any<Object>(),
            any<StackTrace?>(),
            reason: any<dynamic>(named: 'reason'),
          ),
        ).called(1);
      });
    });
  });
}
