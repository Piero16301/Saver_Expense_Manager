import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:firebase_performance/firebase_performance.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gemini_nano_android/gemini_nano_android.dart';
import 'package:mocktail/mocktail.dart';
import 'package:saver_expense_manager/app/app.dart';

class MockDio extends Mock implements Dio {}

class MockGeminiNanoAndroid extends Mock implements GeminiNanoAndroid {}

class MockTrace extends Mock implements Trace {}

class MockPerformanceService extends Mock implements PerformanceService {}

class MockRemoteConfigService extends Mock implements RemoteConfigService {}

class MockCrashService extends Mock implements CrashService {}

void main() {
  late MockDio mockDio;
  late MockGeminiNanoAndroid mockLocalModel;
  late MockTrace mockTrace;

  late MockPerformanceService mockPerformanceService;
  late MockRemoteConfigService mockRemoteConfigService;
  late MockCrashService mockCrashService;

  late GeminiAiRepository repository;

  setUpAll(() {
    registerFallbackValue(MockTrace());
  });

  setUp(() async {
    mockDio = MockDio();
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
    when(() => mockRemoteConfigService.geminiModelId).thenReturn('gemini-1.5');
    when(() => mockRemoteConfigService.geminiApiKey).thenReturn('test-key');

    repository = GeminiAiRepository(dio: mockDio, localModel: mockLocalModel);
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
          imagePrompt: const PromptPart(type: PromptPartType.file),
        ),
        isNull,
      );
      expect(
        await mock.generateContentRemote(
          prompt: [const PromptPart(text: 't', type: PromptPartType.text)],
        ),
        isNull,
      );
    });
  });

  group('GeminiAiRepository', () {
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

      test('records error and rethrows if post fails', () async {
        when(
          () => mockDio.post<Map<String, dynamic>>(
            any(),
            data: any(named: 'data'),
            options: any(named: 'options'),
          ),
        ).thenThrow(Exception('Remote Fail during post'));

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
            reason: 'AiService generateContentRemote error via HTTP/Dio',
          ),
        ).called(1);
      });

      test('returns text if response is valid', () async {
        when(
          () => mockDio.post<Map<String, dynamic>>(
            any(),
            data: any(named: 'data'),
            options: any(named: 'options'),
          ),
        ).thenAnswer(
          (_) async => Response<Map<String, dynamic>>(
            requestOptions: RequestOptions(),
            statusCode: 200,
            data: {
              'candidates': [
                {
                  'content': {
                    'parts': [
                      {'text': 'Hello Gemini'},
                    ],
                  },
                },
              ],
            },
          ),
        );

        final result = await repository.generateContentRemote(
          prompt: [const PromptPart(text: 'h', type: PromptPartType.text)],
        );

        expect(result, 'Hello Gemini');
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
