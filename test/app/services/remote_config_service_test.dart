import 'package:firebase_performance/firebase_performance.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:saver_expense_manager/app/app.dart';

class MockRemoteConfigRepository extends Mock implements RemoteConfigRepository;

class MockCrashService extends Mock implements CrashService;

class MockTrace extends Mock implements Trace;

class MockPerformanceService extends Mock implements PerformanceService;

void main() {
  late RemoteConfigService service;
  late MockRemoteConfigRepository mockRepository;
  late MockCrashService mockCrashService;
  late MockTrace mockTrace;
  late MockPerformanceService mockPerformanceService;

  setUpAll(() {
    registerFallbackValue(MockTrace());
  });

  setUp(() async {
    mockRepository = MockRemoteConfigRepository();
    mockCrashService = MockCrashService();
    mockTrace = MockTrace();
    mockPerformanceService = MockPerformanceService();

    await getIt.reset();
    getIt
      ..registerSingleton<CrashService>(mockCrashService)
      ..registerSingleton<PerformanceService>(mockPerformanceService);

    when(() => mockPerformanceService.startTrace(any<String>()))
        .thenReturn(mockTrace);
    when(() => mockPerformanceService.stopTrace(any<Trace>())).thenReturn(null);

    service = RemoteConfigService(remoteConfigRepository: mockRepository);
  });

  group('RemoteConfigService', () {
    test('can be instantiated', () {
      expect(service, isNotNull);
    });

    test('initialize calls repository initialize', () async {
      when(() => mockRepository.initialize()).thenAnswer((_) async {});
      await service.initialize();
      verify(() => mockRepository.initialize()).called(1);
      verify(() => mockPerformanceService.startTrace('remote_config_init'))
          .called(1);
      verify(() => mockPerformanceService.stopTrace(mockTrace)).called(1);
    });

    test('initialize records error on failure and does not rethrow', () async {
      when(() => mockRepository.initialize())
          .thenThrow(Exception('Config Fail'));

      await service.initialize();

      verify(
        () => mockCrashService.recordError(
          any<Object>(),
          any<StackTrace?>(),
          reason: 'RemoteConfig initialization failed',
        ),
      ).called(1);
      verify(() => mockPerformanceService.stopTrace(mockTrace)).called(1);
    });

    test('homeInitialTab returns from repository', () {
      when(() => mockRepository.homeInitialTab).thenReturn('home');
      expect(service.homeInitialTab, equals('home'));
    });

    test('geminiModelName returns from repository', () {
      when(() => mockRepository.geminiModelName)
          .thenReturn('gemini-3.5-flash-lite');
      expect(service.geminiModelName, equals('gemini-3.5-flash-lite'));
    });

    test('geminiPromptExtractReceiptData returns from repository', () {
      when(() => mockRepository.geminiPromptExtractReceiptData)
          .thenReturn('prompt1');
      expect(service.geminiPromptExtractReceiptData, equals('prompt1'));
    });

    test('geminiPromptDetectAntExpense returns from repository', () {
      when(() => mockRepository.geminiPromptDetectAntExpense)
          .thenReturn('prompt2');
      expect(service.geminiPromptDetectAntExpense, equals('prompt2'));
    });

    test('geminiAntLookbackDays returns from repository', () {
      when(() => mockRepository.geminiAntLookbackDays).thenReturn(30);
      expect(service.geminiAntLookbackDays, equals(30));
    });

    test('paginationLimit returns from repository', () {
      when(() => mockRepository.paginationLimit).thenReturn(20);
      expect(service.paginationLimit, equals(20));
    });

    test('summaryLastMonths returns from repository', () {
      when(() => mockRepository.summaryLastMonths).thenReturn(4);
      expect(service.summaryLastMonths, equals(4));
    });
  });
}
