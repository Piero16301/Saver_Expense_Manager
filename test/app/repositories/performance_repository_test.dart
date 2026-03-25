import 'package:firebase_performance/firebase_performance.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:saver_expense_manager/app/repositories/performance_repository.dart';

class MockFirebasePerformance extends Mock implements FirebasePerformance {}

class MockTrace extends Mock implements Trace {}

void main() {
  late MockFirebasePerformance mockPerformance;
  late MockTrace mockTrace;
  late FirebasePerformanceRepository repository;

  setUp(() {
    mockPerformance = MockFirebasePerformance();
    mockTrace = MockTrace();
    repository = FirebasePerformanceRepository(performance: mockPerformance);
  });

  group('MockPerformanceRepository', () {
    test('throws UnimplementedError', () {
      final mock = MockPerformanceRepository();
      expect(() => mock.startTrace('name'), throwsUnimplementedError);
      expect(() => mock.stopTrace(mockTrace), throwsUnimplementedError);
    });
  });

  group('FirebasePerformanceRepository', () {
    test('startTrace starts a new trace', () async {
      when(() => mockPerformance.newTrace(any<String>())).thenReturn(mockTrace);
      when(() => mockTrace.start()).thenAnswer((_) async {});

      final result = repository.startTrace('test_trace');

      expect(result, equals(mockTrace));
      verify(() => mockPerformance.newTrace('test_trace')).called(1);
      await Future<void>.delayed(Duration.zero);
      verify(() => mockTrace.start()).called(1);
    });

    test('stopTrace stops the given trace', () async {
      when(() => mockTrace.stop()).thenAnswer((_) async {});
      repository.stopTrace(mockTrace);
      await Future<void>.delayed(Duration.zero);
      verify(() => mockTrace.stop()).called(1);
    });
  });
}
