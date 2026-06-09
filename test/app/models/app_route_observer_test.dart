import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:saver_expense_manager/app/app.dart';

class MockAnalyticsService extends Mock implements AnalyticsService {}

class MockPageRoute extends Mock implements PageRoute<dynamic> {}

class MockRoute extends Mock implements Route<dynamic> {}

void main() {
  late MockAnalyticsService mockAnalyticsService;
  late AppRouteObserver observer;

  setUp(() {
    mockAnalyticsService = MockAnalyticsService();
    observer = AppRouteObserver(analyticsService: mockAnalyticsService);
  });

  group('AppRouteObserver', () {
    test('didPush calls setCurrentScreen when route is PageRoute', () {
      final route = MockPageRoute();
      when(
        () => route.settings,
      ).thenReturn(const RouteSettings(name: 'test_screen'));

      observer.didPush(route, null);

      verify(
        () => mockAnalyticsService.setCurrentScreen(screenName: 'test_screen'),
      ).called(1);
    });

    test(
      'didPush does NOT call setCurrentScreen when route is NOT PageRoute',
      () {
        final route = MockRoute();

        observer.didPush(route, null);

        verifyNever(
          () => mockAnalyticsService.setCurrentScreen(
            screenName: any(named: 'screenName'),
          ),
        );
      },
    );

    test('didPush does NOT call setCurrentScreen when screenName is null', () {
      final route = MockPageRoute();
      when(() => route.settings).thenReturn(const RouteSettings());

      observer.didPush(route, null);

      verifyNever(
        () => mockAnalyticsService.setCurrentScreen(
          screenName: any(named: 'screenName'),
        ),
      );
    });

    test('didPop calls setCurrentScreen when previousRoute is PageRoute', () {
      final route = MockPageRoute();
      final previousRoute = MockPageRoute();
      when(
        () => previousRoute.settings,
      ).thenReturn(const RouteSettings(name: 'prev_screen'));

      observer.didPop(route, previousRoute);

      verify(
        () => mockAnalyticsService.setCurrentScreen(screenName: 'prev_screen'),
      ).called(1);
    });

    test(
      'didRemove calls setCurrentScreen when previousRoute is PageRoute',
      () {
        final route = MockRoute();
        final previousRoute = MockPageRoute();
        when(
          () => previousRoute.settings,
        ).thenReturn(const RouteSettings(name: 'removed_prev_screen'));

        observer.didRemove(route, previousRoute);

        verify(
          () => mockAnalyticsService.setCurrentScreen(
            screenName: 'removed_prev_screen',
          ),
        ).called(1);
      },
    );

    test('didReplace calls setCurrentScreen when newRoute is PageRoute', () {
      final newRoute = MockPageRoute();
      when(
        () => newRoute.settings,
      ).thenReturn(const RouteSettings(name: 'new_screen'));

      observer.didReplace(newRoute: newRoute, oldRoute: MockRoute());

      verify(
        () => mockAnalyticsService.setCurrentScreen(screenName: 'new_screen'),
      ).called(1);
    });

    test('didChangeTop calls setCurrentScreen when topRoute is PageRoute', () {
      final topRoute = MockPageRoute();
      when(
        () => topRoute.settings,
      ).thenReturn(const RouteSettings(name: 'top_screen'));

      observer.didChangeTop(topRoute, null);

      verify(
        () => mockAnalyticsService.setCurrentScreen(screenName: 'top_screen'),
      ).called(1);
    });
  });
}
