import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:saver_expense_manager/app/repositories/analytics_repository.dart';

class MockFirebaseAnalytics extends Mock implements FirebaseAnalytics {}

void main() {
  late MockFirebaseAnalytics mockAnalytics;
  late FirebaseAnalyticsRepository repository;

  setUp(() {
    mockAnalytics = MockFirebaseAnalytics();
    repository = FirebaseAnalyticsRepository(analytics: mockAnalytics);
  });

  group('MockAnalyticsRepository', () {
    test('does nothing on logEvent', () {
      final _ = MockAnalyticsRepository()
        ..logEvent(name: 'test')
        ..setCurrentScreen(screenName: 'test')
        ..setUserId(id: 'test');
    });
  });

  group('FirebaseAnalyticsRepository', () {
    test('logEvent calls analytics.logEvent', () async {
      when(
        () => mockAnalytics.logEvent(
          name: any<String>(named: 'name'),
          parameters: any<Map<String, Object>?>(named: 'parameters'),
        ),
      ).thenAnswer((_) async {});

      repository.logEvent(name: 'test_event', parameters: {'param': 'value'});

      await Future<void>.delayed(Duration.zero);
      verify(
        () => mockAnalytics.logEvent(
          name: 'test_event',
          parameters: {'param': 'value'},
        ),
      ).called(1);
    });

    test('setCurrentScreen calls analytics.logEvent', () async {
      when(
        () => mockAnalytics.logEvent(
          name: any<String>(named: 'name'),
          parameters: any<Map<String, Object>?>(named: 'parameters'),
        ),
      ).thenAnswer((_) async {});

      repository.setCurrentScreen(screenName: 'TestScreen');

      await Future<void>.delayed(Duration.zero);
      verify(
        () => mockAnalytics.logEvent(
          name: 'screen_view',
          parameters: {'screen_name': 'TestScreen'},
        ),
      ).called(1);
    });

    test('setUserId calls analytics.setUserId', () async {
      when(
        () => mockAnalytics.setUserId(id: any<String?>(named: 'id')),
      ).thenAnswer((_) async {});

      repository.setUserId(id: 'user_123');

      await Future<void>.delayed(Duration.zero);
      verify(() => mockAnalytics.setUserId(id: 'user_123')).called(1);
    });
  });
}
