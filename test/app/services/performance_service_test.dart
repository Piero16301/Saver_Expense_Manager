import 'package:firebase_performance/firebase_performance.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:saver_expense_manager/app/app.dart';

class MockTrace extends Mock implements Trace {}

class MockPerformanceRepository extends Mock implements PerformanceRepository {}

void main() {
  late PerformanceService service;
  late MockPerformanceRepository mockRepository;

  setUpAll(() {
    registerFallbackValue(MockTrace());
  });

  setUp(() {
    mockRepository = MockPerformanceRepository();
    service = PerformanceService(performanceRepository: mockRepository);
  });

  group('PerformanceService', () {
    test('can be instantiated', () {
      expect(service, isNotNull);
    });
    test('startTrace calls repository', () {
      final mockTrace = MockTrace();
      when(
        () => mockRepository.startTrace(any<String>()),
      ).thenReturn(mockTrace);
      final result = service.startTrace('trace');
      expect(result, equals(mockTrace));
      verify(() => mockRepository.startTrace('trace')).called(1);
    });

    test('stopTrace calls repository', () {
      final mockTrace = MockTrace();
      when(() => mockRepository.stopTrace(any<Trace>())).thenReturn(null);
      service.stopTrace(mockTrace);
      verify(() => mockRepository.stopTrace(mockTrace)).called(1);
    });
  });
}
