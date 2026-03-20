import 'package:firebase_performance/firebase_performance.dart';

class PerformanceService {
  PerformanceService({FirebasePerformance? performance})
      : _performance = performance ?? FirebasePerformance.instance;

  final FirebasePerformance _performance;

  Future<Trace> startTrace(String name) async {
    final trace = _performance.newTrace(name);
    await trace.start();
    return trace;
  }

  Future<void> stopTrace(Trace trace) async {
    await trace.stop();
  }

  Future<HttpMetric> startHttpMetric(String url, HttpMethod httpMethod) async {
    final metric = _performance.newHttpMetric(url, httpMethod);
    await metric.start();
    return metric;
  }

  Future<void> stopHttpMetric(HttpMetric metric) async {
    await metric.stop();
  }
}
