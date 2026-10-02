import 'dart:convert';
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
        await mock.generateContentFromTemplate(templateId: 'test'),
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

    group('generateContentFromTemplate', () {
      test('returns null if templateId is empty', () async {
        final result = await repository.generateContentFromTemplate(
          templateId: '',
        );
        expect(result, isNull);
      });

      test('calls templateContentGenerator and returns response text with file '
          'attachment', () async {
        final repo = FirebaseAiRepository(
          templateGenerator: (id, {required inputs}) async {
            expect(id, 'extractor-de-gastos');
            expect(inputs['today'], '17/09/2026');
            expect(
              inputs['receiptUrl'],
              'data:image/png;base64,${base64Encode([1, 2, 3])}',
            );
            expect(inputs['mimeType'], 'image/png');
            return GenerateContentResponse([
              Candidate(
                Content('model', [const TextPart('{"title": "Test"}')]),
                null,
                null,
                null,
                null,
              ),
            ], null);
          },
        );
        final result = await repo.generateContentFromTemplate(
          templateId: 'extractor-de-gastos',
          attachment: PromptPart.file(
            mimeType: 'image/png',
            bytes: Uint8List.fromList([1, 2, 3]),
          ),
          inputs: {'today': '17/09/2026'},
        );
        expect(result, '{"title": "Test"}');
      });

      test('calls templateContentGenerator with text attachment', () async {
        final repo = FirebaseAiRepository(
          templateGenerator: (id, {required inputs}) async {
            expect(inputs['text'], 'hello');
            return GenerateContentResponse([
              Candidate(
                Content('model', [const TextPart('OK')]),
                null,
                null,
                null,
                null,
              ),
            ], null);
          },
        );
        final result = await repo.generateContentFromTemplate(
          templateId: 'extractor-de-gastos',
          attachment: PromptPart.text(text: 'hello'),
        );
        expect(result, 'OK');
      });

      test('records error and rethrows if template generation fails', () async {
        final repo = FirebaseAiRepository(
          templateGenerator: (id, {required inputs}) async {
            throw Exception('Template Fail');
          },
        );

        expect(
          () => repo.generateContentFromTemplate(templateId: 'test'),
          throwsException,
        );

        await Future<void>.delayed(Duration.zero);
        verify(
          () => mockCrashService.recordError(
            any<Object>(),
            any<StackTrace?>(),
            reason: 'AiService generateContentFromTemplate error',
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
