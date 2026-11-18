import 'package:firebase_performance/firebase_performance.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:saver_expense_manager/app/app.dart';

class MockAiRepository extends Mock implements AiRepository;

class MockTrace extends Mock implements Trace;

class MockPerformanceService extends Mock implements PerformanceService;

class MockRemoteConfigService extends Mock implements RemoteConfigService;

class MockCrashService extends Mock implements CrashService;

void main() {
  late AiService service;
  late MockAiRepository mockRepository;
  late MockTrace mockTrace;
  late MockPerformanceService mockPerformanceService;
  late MockRemoteConfigService mockRemoteConfigService;
  late MockCrashService mockCrashService;

  setUpAll(() {
    registerFallbackValue(MockTrace());
  });

  setUp(() async {
    mockRepository = MockAiRepository();
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
    when(() => mockRemoteConfigService.geminiModelName)
        .thenReturn('gemini-1.5-flash');

    service = AiService(aiRepository: mockRepository);
  });

  group('AiService', () {
    test('can be instantiated', () {
      expect(service, isNotNull);
    });
    test('initialize calls repository initialize', () async {
      when(() => mockRepository.initialize()).thenAnswer((_) async {});
      await service.initialize();
      verify(() => mockRepository.initialize()).called(1);
    });

    test('isLocalModelAvailable returns value from repository', () {
      when(() => mockRepository.isLocalModelAvailable).thenReturn(true);
      expect(service.isLocalModelAvailable, isTrue);
    });

    test('generateContentRemote returns null without calling repository when '
        'prompt is empty', () async {
      final result = await service.generateContentRemote(prompt: []);
      expect(result, isNull);
      verifyNever(
        () => mockRepository.generateContentRemote(
          prompt: any<List<PromptPart>>(named: 'prompt'),
          model: any<String>(named: 'model'),
          responseMimeType: any<String>(named: 'responseMimeType'),
        ),
      );
    });

    test('generateContentRemote calls repository and returns result', () async {
      final prompt = [PromptPart.text(text: 'test')];
      when(
        () => mockRepository.generateContentRemote(
          prompt: any<List<PromptPart>>(named: 'prompt'),
          model: any<String>(named: 'model'),
          responseMimeType: any<String>(named: 'responseMimeType'),
        ),
      ).thenAnswer((_) async => 'result');
      final result = await service.generateContentRemote(prompt: prompt);
      expect(result, equals('result'));
      verify(
        () => mockRepository.generateContentRemote(
          prompt: prompt,
          model: 'gemini-1.5-flash',
        ),
      ).called(1);
      verify(() => mockPerformanceService.startTrace('gemini_generate_remote'))
          .called(1);
      verify(() => mockPerformanceService.stopTrace(mockTrace)).called(1);
    });

    test('generateContentRemote records error, stops trace, and rethrows on '
        'failure', () async {
      final prompt = [PromptPart.text(text: 'test')];
      when(
        () => mockRepository.generateContentRemote(
          prompt: any<List<PromptPart>>(named: 'prompt'),
          model: any<String>(named: 'model'),
          responseMimeType: any<String>(named: 'responseMimeType'),
        ),
      ).thenThrow(Exception('Remote Fail'));

      await expectLater(
        () => service.generateContentRemote(prompt: prompt),
        throwsException,
      );

      verify(
        () => mockCrashService.recordError(
          any<Object>(),
          any<StackTrace?>(),
          reason: 'AiService generateContentRemote error',
        ),
      ).called(1);
      verify(() => mockPerformanceService.stopTrace(mockTrace)).called(1);
    });

    test('generateContentLocal calls repository and returns result', () async {
      final textPrompt = PromptPart.text(text: 'text');
      when(() => mockRepository.generateContentLocal(textPrompt: textPrompt))
          .thenAnswer((_) async => 'result');
      final result = await service.generateContentLocal(textPrompt: textPrompt);
      expect(result, equals('result'));
      verify(() => mockRepository.generateContentLocal(textPrompt: textPrompt))
          .called(1);
      verify(() => mockPerformanceService.startTrace('gemini_generate_local'))
          .called(1);
      verify(() => mockPerformanceService.stopTrace(mockTrace)).called(1);
    });

    test('generateContentLocal records error, stops trace, and rethrows on '
        'failure', () async {
      final textPrompt = PromptPart.text(text: 'text');
      when(() => mockRepository.generateContentLocal(textPrompt: textPrompt))
          .thenThrow(Exception('Local Fail'));

      await expectLater(
        () => service.generateContentLocal(textPrompt: textPrompt),
        throwsException,
      );

      verify(
        () => mockCrashService.recordError(
          any<Object>(),
          any<StackTrace?>(),
          reason: 'AiService generateContentLocal error',
        ),
      ).called(1);
      verify(() => mockPerformanceService.stopTrace(mockTrace)).called(1);
    });
  });
}
