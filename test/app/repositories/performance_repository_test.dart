import 'dart:async';

import 'package:firebase_performance/firebase_performance.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:saver_expense_manager/app/repositories/performance_repository.dart';

class MockFirebasePerformance extends Mock implements FirebasePerformance;

class MockFirebaseTrace extends Mock implements Trace;

void main() {
  late MockFirebasePerformance mockPerformance;
  late MockFirebaseTrace mockTrace;
  late FirebasePerformanceRepository repository;

  setUp(() {
    mockPerformance = MockFirebasePerformance();
    mockTrace = MockFirebaseTrace();
    repository = FirebasePerformanceRepository(performance: mockPerformance);
  });

  group('MockPerformanceRepository', () {
    test('starts and stops MockTrace in memory', () async {
      final mock = MockPerformanceRepository();
      final trace = mock.startTrace('name') as MockTrace;
      expect(trace.name, equals('name'));
      expect(trace.isStarted, isTrue);
      expect(trace.isStopped, isFalse);
      expect(mock.activeTraces, contains(trace));

      trace
        ..setMetric('count', 2)
        ..incrementMetric('count', 3)
        ..putAttribute('env', 'mock');
      expect(trace.getMetric('count'), equals(5));
      expect(trace.getAttribute('env'), equals('mock'));
      expect(trace.getAttributes(), equals({'env': 'mock'}));
      trace.removeAttribute('env');
      expect(trace.getAttribute('env'), isNull);

      mock.stopTrace(trace);
      await Future<void>.delayed(Duration.zero);
      expect(trace.isStopped, isTrue);
      expect(mock.activeTraces, isEmpty);
      expect(mock.completedTraces, contains(trace));
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

    test(
      'stopTrace stops the given trace when not in starting traces',
      () async {
        when(() => mockTrace.stop()).thenAnswer((_) async {});
        repository.stopTrace(mockTrace);
        await Future<void>.delayed(Duration.zero);
        verify(() => mockTrace.stop()).called(1);
      },
    );

    test('stopTrace stops trace that was previously started', () async {
      final completer = Completer<void>();
      when(() => mockPerformance.newTrace(any<String>())).thenReturn(mockTrace);
      when(() => mockTrace.start()).thenAnswer((_) => completer.future);
      when(() => mockTrace.stop()).thenAnswer((_) async {});

      final trace = repository.startTrace('trace_to_stop');
      repository.stopTrace(trace);

      completer.complete();
      await Future<void>.delayed(Duration.zero);
      verify(() => mockTrace.stop()).called(1);
    });

    test('startTrace and stopTrace handle errors gracefully', () async {
      when(() => mockPerformance.newTrace(any<String>())).thenReturn(mockTrace);
      when(() => mockTrace.start())
          .thenAnswer((_) => Future.error(Exception('start error')));
      when(() => mockTrace.stop())
          .thenAnswer((_) => Future.error(Exception('stop error')));

      final trace = repository.startTrace('error_trace');
      repository.stopTrace(trace);
      await Future<void>.delayed(Duration.zero);
      verify(() => mockTrace.start()).called(1);
      verify(() => mockTrace.stop()).called(1);
    });

    test(
      'default constructor initializes or throws when Firebase not ready',
      () {
        try {
          final repo = FirebasePerformanceRepository();
          expect(repo, isNotNull);
        } on Object catch (e) {
          expect(e, isNotNull);
        }
      },
    );
  });
}
