import 'dart:typed_data';

import 'package:firebase_ai/firebase_ai.dart';
import 'package:firebase_performance/firebase_performance.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gemini_nano_android/gemini_nano_android.dart';
import 'package:mocktail/mocktail.dart';
import 'package:saver_expense_manager/app/app.dart';

class MockFirebaseAI extends Mock implements FirebaseAI {}

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

  setUpAll(() {
    registerFallbackValue(Content.text(''));
    registerFallbackValue(MockTrace());
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

    when(() => mockPerformanceService.startTrace(any<String>()))
        .thenReturn(mockTrace);
    when(() => mockPerformanceService.stopTrace(any<Trace>())).thenReturn(null);
    when(() => mockRemoteConfigService.geminiModelId).thenReturn('gemini-1.5');

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
      expect(await mock.generateContentRemote(prompt: []), isNull);
      expect(
        await mock.generateContentLocal(
          textPrompt: const PromptPart(text: 't', type: PromptPartType.text),
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

      test('records error and rethrows if generativeModel fails', () async {
        when(
          () => mockRemoteModel.generativeModel(
            model: any<String>(named: 'model'),
            safetySettings: any<List<SafetySetting>?>(named: 'safetySettings'),
            generationConfig: any<GenerationConfig?>(named: 'generationConfig'),
          ),
        ).thenThrow(Exception('Remote Fail'));

        expect(
          () => repository.generateContentRemote(
            prompt: [const PromptPart(text: 'h', type: PromptPartType.text)],
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
