import 'dart:async';

import 'package:firebase_performance/firebase_performance.dart';

abstract class PerformanceRepository {
  Trace startTrace(String name);
  void stopTrace(Trace trace);
}

class MockPerformanceRepository implements PerformanceRepository {
  @override
  Trace startTrace(String name) {
    throw UnimplementedError();
  }

  @override
  void stopTrace(Trace trace) {
    throw UnimplementedError();
  }
}

class FirebasePerformanceRepository implements PerformanceRepository {
  FirebasePerformanceRepository({FirebasePerformance? performance})
    : _performance = performance ?? FirebasePerformance.instance;

  final FirebasePerformance _performance;
  final Map<Trace, Future<void>> _startingTraces = {};

  @override
  Trace startTrace(String name) {
    final trace = _performance.newTrace(name);
    final startFuture = trace.start().catchError((_) {});
    _startingTraces[trace] = startFuture;
    return trace;
  }

  @override
  void stopTrace(Trace trace) {
    final startFuture = _startingTraces.remove(trace);
    if (startFuture != null) {
      unawaited(
        startFuture.then((_) {
          unawaited(trace.stop().catchError((_) {}));
        }),
      );
    } else {
      unawaited(trace.stop().catchError((_) {}));
    }
  }
}
