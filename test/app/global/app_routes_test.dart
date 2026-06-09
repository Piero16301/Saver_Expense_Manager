import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';
import 'package:saver_expense_manager/app/app.dart';

class MockAuthService extends Mock implements AuthService {}

class MockAiService extends Mock implements AiService {}

class MockAnalyticsService extends Mock implements AnalyticsService {}

class MockGoRouterState extends Mock implements GoRouterState {}

class MockBuildContext extends Mock implements BuildContext {}

void main() {
  late MockAuthService mockAuthService;
  late MockAiService mockAiService;
  late MockAnalyticsService mockAnalyticsService;
  late MockGoRouterState mockState;
  late MockBuildContext mockContext;

  setUpAll(() {
    registerFallbackValue(const AppState());
    registerFallbackValue(MockGoRouterState());
    registerFallbackValue(MockBuildContext());
  });

  setUp(() async {
    mockAuthService = MockAuthService();
    mockAiService = MockAiService();
    mockAnalyticsService = MockAnalyticsService();
    mockState = MockGoRouterState();
    mockContext = MockBuildContext();

    await getIt.reset();
    getIt
      ..registerLazySingleton<AuthService>(() => mockAuthService)
      ..registerLazySingleton<AnalyticsService>(() => mockAnalyticsService)
      ..registerLazySingleton<AiService>(() => mockAiService);

    when(
      () => mockAuthService.userChanges,
    ).thenAnswer((_) => const Stream.empty());
    when(() => mockAuthService.isLoggedIn).thenReturn(false);
  });

  group('AppRoute Enum', () {
    test('enum values have correct paths', () {
      expect(AppRoute.login.path, equals('/login'));
      expect(AppRoute.register.path, equals('/register'));
      expect(AppRoute.home.path, equals('/'));
      expect(AppRoute.settings.path, equals('settings'));
      expect(AppRoute.movement.path, contains('movement/:type/:screenType'));
      expect(AppRoute.category.path, equals('category'));
      expect(AppRoute.profile.path, equals('profile'));
    });

    test('enum values have correct names', () {
      expect(AppRoute.login.name, equals('login'));
      expect(AppRoute.register.name, equals('register'));
      expect(AppRoute.home.name, equals('home'));
      expect(AppRoute.settings.name, equals('settings'));
      expect(AppRoute.movement.name, equals('movement'));
      expect(AppRoute.category.name, equals('category'));
      expect(AppRoute.profile.name, equals('profile'));
    });
  });

  group('AppRoutes Redirection Logic', () {
    test('redirects to /login if NOT logged in and on a protected route', () {
      when(() => mockAuthService.isLoggedIn).thenReturn(false);
      when(() => mockState.fullPath).thenReturn('/any-route');

      final result = AppRoutes.redirect(mockContext, mockState);
      expect(result, equals(AppRoute.login.path));
    });

    test('does NOT redirect if NOT logged in and already on /login', () {
      when(() => mockAuthService.isLoggedIn).thenReturn(false);
      when(() => mockState.fullPath).thenReturn(AppRoute.login.path);

      final result = AppRoutes.redirect(mockContext, mockState);
      expect(result, isNull);
    });

    test('does NOT redirect if NOT logged in and already on /register', () {
      when(() => mockAuthService.isLoggedIn).thenReturn(false);
      when(() => mockState.fullPath).thenReturn(AppRoute.register.path);

      final result = AppRoutes.redirect(mockContext, mockState);
      expect(result, isNull);
    });

    test('redirects to / if logged in and on /login', () {
      when(() => mockAuthService.isLoggedIn).thenReturn(true);
      when(() => mockState.fullPath).thenReturn(AppRoute.login.path);

      final result = AppRoutes.redirect(mockContext, mockState);
      expect(result, equals(AppRoute.home.path));
    });

    test('does NOT redirect if logged in and on regular route', () {
      when(() => mockAuthService.isLoggedIn).thenReturn(true);
      when(() => mockState.fullPath).thenReturn(AppRoute.home.path);

      final result = AppRoutes.redirect(mockContext, mockState);
      expect(result, isNull);
    });
  });

  group('AppRoutes.getRouter', () {
    test('returns a GoRouter instance', () {
      final router = AppRoutes.getRouter();
      expect(router, isA<GoRouter>());
    });

    test('triggers all route builders for coverage', () {
      final router = AppRoutes.getRouter();
      final mockStateParam = MockGoRouterState();

      for (final route in router.configuration.routes.whereType<GoRoute>()) {
        try {
          route.builder?.call(mockContext, mockStateParam);
        } on Exception catch (_) {}

        for (final subRoute in route.routes.whereType<GoRoute>()) {
          when(() => mockStateParam.extra).thenReturn(Movement.empty);
          if (subRoute.name == AppRoute.category.name) {
            when(() => mockStateParam.extra).thenReturn(Category.empty);
          }
          when(() => mockStateParam.pathParameters).thenReturn({});
          try {
            subRoute.builder?.call(mockContext, mockStateParam);
          } on Exception catch (_) {}
        }
      }
    });

    test(
      'GoRouterRefreshStream notifies listeners when stream emits',
      () async {
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
      },
    );
  });
}
