import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:saver_expense_manager/app/services/analytics_service.dart';

class MockFirebaseAnalytics extends Mock implements FirebaseAnalytics {}

class MockPageRoute extends Mock implements PageRoute<dynamic> {}

void main() {
  late AnalyticsService analyticsService;
  late MockFirebaseAnalytics mockFirebaseAnalytics;

  setUp(() {
    mockFirebaseAnalytics = MockFirebaseAnalytics();
    analyticsService = AnalyticsService(analytics: mockFirebaseAnalytics);

    registerFallbackValue(MockPageRoute());

    when(
      () => mockFirebaseAnalytics.logEvent(
        name: any(named: 'name'),
        parameters: any(named: 'parameters'),
      ),
    ).thenAnswer((_) async {});

    when(
      () => mockFirebaseAnalytics.setUserId(
        id: any(named: 'id'),
      ),
    ).thenAnswer((_) async {});
  });

  group('AnalyticsService', () {
    test('initializes with provided FirebaseAnalytics', () {
      expect(analyticsService.analytics, mockFirebaseAnalytics);
    });

    test('logEvent calls logEvent on FirebaseAnalytics', () async {
      final parameters = {'param1': 'value1'};
      analyticsService.logEvent(
        name: 'test_event',
        parameters: parameters,
      );

      verify(
        () => mockFirebaseAnalytics.logEvent(
          name: 'test_event',
          parameters: parameters,
        ),
      ).called(1);
    });

    test('setCurrentScreen calls logEvent for screen_view', () async {
      analyticsService.setCurrentScreen(screenName: 'HomeScreen');

      verify(
        () => mockFirebaseAnalytics.logEvent(
          name: 'screen_view',
          parameters: {'screen_name': 'HomeScreen'},
        ),
      ).called(1);
    });

    test('setUserId calls setUserId on FirebaseAnalytics', () async {
      analyticsService.setUserId(id: 'user_123');

      verify(
        () => mockFirebaseAnalytics.setUserId(
          id: 'user_123',
        ),
      ).called(1);
    });

    test('getRouteObserver returns an AppRouteObserver', () {
      final observer = analyticsService.getRouteObserver();
      expect(observer, isA<AppRouteObserver>());
    });
  });

  group('AppRouteObserver', () {
    late AppRouteObserver observer;

    setUp(() {
      observer = AppRouteObserver(analyticsService: analyticsService);
    });

    test('didPush logs screen view for PageRoute', () {
      final route = MockPageRoute();
      when(() => route.settings)
          .thenReturn(const RouteSettings(name: 'TestPage'));

      observer.didPush(route, null);

      verify(
        () => mockFirebaseAnalytics.logEvent(
          name: 'screen_view',
          parameters: {'screen_name': 'TestPage'},
        ),
      ).called(1);
    });

    test('didPush does not log screen view if screenName is null', () {
      final route = MockPageRoute();
      when(() => route.settings).thenReturn(const RouteSettings());

      observer.didPush(route, null);

      verifyNever(
        () => mockFirebaseAnalytics.logEvent(
          name: 'screen_view',
          parameters: any(named: 'parameters'),
        ),
      );
    });

    test('didPop logs screen view for previous PageRoute', () {
      final route = MockPageRoute();
      final previousRoute = MockPageRoute();
      when(() => previousRoute.settings)
          .thenReturn(const RouteSettings(name: 'PreviousPage'));

      observer.didPop(route, previousRoute);

      verify(
        () => mockFirebaseAnalytics.logEvent(
          name: 'screen_view',
          parameters: {'screen_name': 'PreviousPage'},
        ),
      ).called(1);
    });

    test('didReplace logs screen view for new PageRoute', () {
      final newRoute = MockPageRoute();
      when(() => newRoute.settings)
          .thenReturn(const RouteSettings(name: 'NewPage'));

      observer.didReplace(newRoute: newRoute);

      verify(
        () => mockFirebaseAnalytics.logEvent(
          name: 'screen_view',
          parameters: {'screen_name': 'NewPage'},
        ),
      ).called(1);
    });

    test('didRemove logs screen view for previous PageRoute', () {
      final previousRoute = MockPageRoute();
      when(() => previousRoute.settings)
          .thenReturn(const RouteSettings(name: 'RemovedPreviousPage'));

      observer.didRemove(MockPageRoute(), previousRoute);

      verify(
        () => mockFirebaseAnalytics.logEvent(
          name: 'screen_view',
          parameters: {'screen_name': 'RemovedPreviousPage'},
        ),
      ).called(1);
    });

    test('didChangeTop logs screen view for top PageRoute', () {
      final topRoute = MockPageRoute();
      when(() => topRoute.settings)
          .thenReturn(const RouteSettings(name: 'TopPage'));

      observer.didChangeTop(topRoute, null);

      verify(
        () => mockFirebaseAnalytics.logEvent(
          name: 'screen_view',
          parameters: {'screen_name': 'TopPage'},
        ),
      ).called(1);
    });
  });
}
