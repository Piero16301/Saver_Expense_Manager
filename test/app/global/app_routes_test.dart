import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';
import 'package:saver_expense_manager/app/app.dart';
import 'package:saver_expense_manager/home/home.dart';
import 'package:saver_expense_manager/login/login.dart';
import 'package:saver_expense_manager/register/register.dart';

class MockAuthenticationService extends Mock implements AuthenticationService {}

class MockGoRouterState extends Mock implements GoRouterState {}

class MockBuildContext extends Mock implements BuildContext {}

void main() {
  late MockAuthenticationService mockAuthService;

  setUpAll(() {
    registerFallbackValue(MockBuildContext());
    registerFallbackValue(MockGoRouterState());
  });

  setUp(() async {
    await GetIt.I.reset();
    mockAuthService = MockAuthenticationService();
    GetIt.I.registerSingleton<AuthenticationService>(mockAuthService);

    // Default stubs
    when(() => mockAuthService.userChanges)
        .thenAnswer((_) => const Stream.empty());
  });

  group('handleRedirect', () {
    test('redirects to Login when user is NOT logged in', () {
      when(() => mockAuthService.isLoggedIn).thenReturn(false);

      final context = MockBuildContext();
      final state = MockGoRouterState();

      // 1. Random path -> Login
      when(() => state.fullPath).thenReturn('/random');
      expect(handleRedirect(context, state), LoginPage.pagePath);

      // 2. Login path -> null (allowed)
      when(() => state.fullPath).thenReturn(LoginPage.pagePath);
      expect(handleRedirect(context, state), null);

      // 3. Register path -> null (allowed)
      when(() => state.fullPath).thenReturn(RegisterPage.pagePath);
      expect(handleRedirect(context, state), null);
    });

    test('redirects to Home when user is logged in', () {
      when(() => mockAuthService.isLoggedIn).thenReturn(true);

      final context = MockBuildContext();
      final state = MockGoRouterState();

      // 1. Random path -> null (allowed)
      when(() => state.fullPath).thenReturn('/random');
      expect(handleRedirect(context, state), null);

      // 2. Login path -> Home
      when(() => state.fullPath).thenReturn(LoginPage.pagePath);
      expect(handleRedirect(context, state), HomePage.pagePath);

      // 3. Home path -> null (allowed)
      when(() => state.fullPath).thenReturn(HomePage.pagePath);
      expect(handleRedirect(context, state), null);
    });
  });

  group('goRouter', () {
    test('verifies routes configuration', () {
      when(() => mockAuthService.isLoggedIn).thenReturn(false);

      final router = goRouter();
      final routes = router.configuration.routes.whereType<GoRoute>();

      // Verify existence of key routes
      expect(routes.any((r) => r.path == LoginPage.pagePath), isTrue);
      expect(routes.any((r) => r.path == RegisterPage.pagePath), isTrue);
      expect(routes.any((r) => r.path == HomePage.pagePath), isTrue);

      // Verify named routes
      expect(routes.any((r) => r.name == LoginPage.pageName), isTrue);
      expect(routes.any((r) => r.name == HomePage.pageName), isTrue);
    });
  });
}
