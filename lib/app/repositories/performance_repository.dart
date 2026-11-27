import 'dart:async';

import 'package:firebase_performance/firebase_performance.dart';

abstract class PerformanceRepository {
  Trace startTrace(String name);
  void stopTrace(Trace trace);
}

class MockTrace implements Trace {
  new(this.name);

  final String name;
  bool _isStarted = false;
  bool _isStopped = false;
  final Map<String, int> _metrics = {};
  final Map<String, String> _attributes = {};

  bool get isStarted => _isStarted;
  bool get isStopped => _isStopped;

  @override
  Future<void> start() async {
    _isStarted = true;
  }

  @override
  Future<void> stop() async {
    _isStopped = true;
  }

  @override
  void incrementMetric(String name, int value) {
    if (!_isStarted || _isStopped) return;
    _metrics[name] = (_metrics[name] ?? 0) + value;
  }

  @override
  void setMetric(String name, int value) {
    if (!_isStarted || _isStopped) return;
    _metrics[name] = value;
  }

  @override
  int getMetric(String name) => _metrics[name] ?? 0;

  @override
  void putAttribute(String name, String value) {
    if (_isStopped) return;
    _attributes[name] = value;
  }

  @override
  void removeAttribute(String name) {
    if (_isStopped) return;
    _attributes.remove(name);
  }

  @override
  String? getAttribute(String name) => _attributes[name];

  @override
  Map<String, String> getAttributes() => Map.unmodifiable(_attributes);
}

class MockPerformanceRepository implements PerformanceRepository {
  final List<MockTrace> _activeTraces = [];
  final List<MockTrace> _completedTraces = [];

  List<MockTrace> get activeTraces => List.unmodifiable(_activeTraces);
  List<MockTrace> get completedTraces => List.unmodifiable(_completedTraces);

  @override
  Trace startTrace(String name) {
    final trace = MockTrace(name);
    unawaited(trace.start());
    _activeTraces.add(trace);
    return trace;
  }

  @override
  void stopTrace(Trace trace) {
    unawaited(trace.stop());
    if (trace is MockTrace) {
      _activeTraces.remove(trace);
      _completedTraces.add(trace);
    }
  }
}

class FirebasePerformanceRepository implements PerformanceRepository {
  new({FirebasePerformance? performance})
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
