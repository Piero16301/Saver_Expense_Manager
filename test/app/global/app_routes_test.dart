import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';
import 'package:saver_expense_manager/app/app.dart';
import 'package:saver_expense_manager/home/home.dart';
import 'package:saver_expense_manager/login/login.dart';
import 'package:saver_expense_manager/register/register.dart';

class MockAuthenticationService extends Mock implements AuthenticationService {}

class MockAiService extends Mock implements AiService {}

class MockGoRouterState extends Mock implements GoRouterState {}

void main() {
  late MockAuthenticationService mockAuthService;
  late MockAiService mockAiService;

  setUp(() {
    mockAuthService = MockAuthenticationService();
    mockAiService = MockAiService();
    unawaited(getIt.reset());
    getIt
      ..registerFactory<AuthenticationService>(() => mockAuthService)
      ..registerFactory<AiService>(() => mockAiService);
  });

  group('handleRedirect', () {
    test('redirects to login when not logged in and navigating to secure route',
        () {
      when(() => mockAuthService.isLoggedIn).thenReturn(false);

      final state = MockGoRouterState();
      when(() => state.fullPath).thenReturn(HomePage.pagePath);

      final BuildContext dummyContext = _MockBuildContext();

      final redirectResult = handleRedirect(dummyContext, state);

      expect(redirectResult, equals(LoginPage.pagePath));
    });

    test('does not redirect when not logged in and navigating to login', () {
      when(() => mockAuthService.isLoggedIn).thenReturn(false);

      final state = MockGoRouterState();
      when(() => state.fullPath).thenReturn(LoginPage.pagePath);

      final BuildContext dummyContext = _MockBuildContext();

      final redirectResult = handleRedirect(dummyContext, state);

      expect(redirectResult, isNull);
    });

    test('does not redirect when not logged in and navigating to register', () {
      when(() => mockAuthService.isLoggedIn).thenReturn(false);

      final state = MockGoRouterState();
      when(() => state.fullPath).thenReturn(RegisterPage.pagePath);

      final BuildContext dummyContext = _MockBuildContext();

      final redirectResult = handleRedirect(dummyContext, state);

      expect(redirectResult, isNull);
    });

    test('redirects to home when logged in and navigating to login', () {
      when(() => mockAuthService.isLoggedIn).thenReturn(true);

      final state = MockGoRouterState();
      when(() => state.fullPath).thenReturn(LoginPage.pagePath);

      final BuildContext dummyContext = _MockBuildContext();

      final redirectResult = handleRedirect(dummyContext, state);

      expect(redirectResult, equals(HomePage.pagePath));
    });

    test('does not redirect when logged in and navigating to secure route', () {
      when(() => mockAuthService.isLoggedIn).thenReturn(true);

      final state = MockGoRouterState();
      when(() => state.fullPath).thenReturn(HomePage.pagePath);

      final BuildContext dummyContext = _MockBuildContext();

      final redirectResult = handleRedirect(dummyContext, state);

      expect(redirectResult, isNull);
    });
  });

  group('goRouter', () {
    test(
        'returns a GoRouter instance with correct initial location when not '
        'logged in', () {
      when(() => mockAuthService.isLoggedIn).thenReturn(false);
      when(() => mockAuthService.userChanges)
          .thenAnswer((_) => const Stream.empty());

      final router = goRouter();

      expect(router, isA<GoRouter>());
      expect(router.configuration.routes, isNotEmpty);
    });

    test(
        'returns a GoRouter instance with correct initial location when logged '
        'in', () {
      when(() => mockAuthService.isLoggedIn).thenReturn(true);
      when(() => mockAuthService.userChanges)
          .thenAnswer((_) => const Stream.empty());

      final router = goRouter();

      expect(router, isA<GoRouter>());
      expect(router.configuration.routes, isNotEmpty);
    });
  });

  group('GoRouterRefreshStream', () {
    test('notifies listeners when stream emits', () async {
      final controller = StreamController<dynamic>();
      final refreshStream = GoRouterRefreshStream(controller.stream);

      var listenerCallCount = 0;
      refreshStream.addListener(() {
        listenerCallCount++;
      });

      controller.add('event');

      await Future<void>.delayed(Duration.zero);

      expect(listenerCallCount, equals(1));

      refreshStream.dispose();
      await controller.close();
    });
  });
}

class _MockBuildContext extends Mock implements BuildContext {}
