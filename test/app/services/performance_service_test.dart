import 'package:firebase_performance/firebase_performance.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:saver_expense_manager/app/services/performance_service.dart';

class MockFirebasePerformance extends Mock implements FirebasePerformance {}

class MockTrace extends Mock implements Trace {}

class MockHttpMetric extends Mock implements HttpMetric {}

void main() {
  late PerformanceService performanceService;
  late MockFirebasePerformance mockPerformance;
  late MockTrace mockTrace;
  late MockHttpMetric mockHttpMetric;

  setUp(() {
    mockPerformance = MockFirebasePerformance();
    mockTrace = MockTrace();
    mockHttpMetric = MockHttpMetric();
    performanceService = PerformanceService(performance: mockPerformance);
  });

  group('PerformanceService', () {
    test('startTrace starts and returns a trace', () async {
      when(() => mockPerformance.newTrace('test_trace')).thenReturn(mockTrace);
      when(() => mockTrace.start()).thenAnswer((_) async {});

      final result = await performanceService.startTrace('test_trace');

      expect(result, mockTrace);
      verify(() => mockPerformance.newTrace('test_trace')).called(1);
      verify(() => mockTrace.start()).called(1);
    });

    test('stopTrace calls stop on trace', () async {
      when(() => mockTrace.stop()).thenAnswer((_) async {});

      await performanceService.stopTrace(mockTrace);

      verify(() => mockTrace.stop()).called(1);
    });

    test('startHttpMetric starts and returns a metric', () async {
      const url = 'https://example.com';
      const method = HttpMethod.Get;
      when(() => mockPerformance.newHttpMetric(url, method))
          .thenReturn(mockHttpMetric);
      when(() => mockHttpMetric.start()).thenAnswer((_) async {});

      final result = await performanceService.startHttpMetric(url, method);

      expect(result, mockHttpMetric);
      verify(() => mockPerformance.newHttpMetric(url, method)).called(1);
      verify(() => mockHttpMetric.start()).called(1);
    });

    test('stopHttpMetric calls stop on metric', () async {
      when(() => mockHttpMetric.stop()).thenAnswer((_) async {});

      await performanceService.stopHttpMetric(mockHttpMetric);

      verify(() => mockHttpMetric.stop()).called(1);
    });
  });
}
