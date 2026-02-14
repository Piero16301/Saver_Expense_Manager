import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:saver_expense_manager/app/app.dart';
import 'package:saver_expense_manager/category/category.dart';
import 'package:saver_expense_manager/home/home.dart';
import 'package:saver_expense_manager/login/login.dart';
import 'package:saver_expense_manager/movement/movement.dart';
import 'package:saver_expense_manager/profile/profile.dart';
import 'package:saver_expense_manager/register/register.dart';
import 'package:saver_expense_manager/settings/settings.dart';
import 'package:user_api/user_api.dart';

GoRouter goRouter() {
  final authService = getIt<AuthenticationService>();

  return GoRouter(
    refreshListenable: GoRouterRefreshStream(authService.userChanges),
    redirect: (context, state) {
      final user = authService.currentUser;
      final isLoggingIn = state.fullPath == LoginPage.pagePath;

      final isRegistering = state.fullPath == RegisterPage.pagePath;

      if (user == null) {
        return (isLoggingIn || isRegistering) ? null : LoginPage.pagePath;
      } else {
        return isLoggingIn ? HomePage.pagePath : null;
      }
    },
    initialLocation: authService.currentUser != null
        ? HomePage.pagePath
        : LoginPage.pagePath,
    routes: [
      GoRoute(
        name: RegisterPage.pageName,
        path: RegisterPage.pagePath,
        builder: (context, state) => const RegisterPage(),
      ),
      GoRoute(
        name: LoginPage.pageName,
        path: LoginPage.pagePath,
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        name: HomePage.pageName,
        path: HomePage.pagePath,
        builder: (context, state) => const HomePage(),
      ),
      GoRoute(
        name: SettingsPage.pageName,
        path: SettingsPage.pagePath,
        builder: (context, state) => const SettingsPage(),
      ),
      GoRoute(
        name: MovementPage.pageName,
        path: MovementPage.pagePath,
        builder: (context, state) {
          final movement = state.extra! as Movement;
          final type = state.pathParameters['type'] ?? 'EXPENSE';
          final screenType = state.pathParameters['screenType'] ?? 'ADD';
          return MovementPage(
            movement: movement,
            type:
                type == 'EXPENSE' ? CategoryType.expense : CategoryType.income,
            screenType: screenType == 'ADD'
                ? MovementScreenType.add
                : MovementScreenType.edit,
          );
        },
      ),
      GoRoute(
        name: CategoryPage.pageName,
        path: CategoryPage.pagePath,
        builder: (context, state) {
          final category = state.extra! as Category;
          return CategoryPage(category: category);
        },
      ),
      GoRoute(
        name: ProfilePage.pageName,
        path: ProfilePage.pagePath,
        builder: (context, state) => const ProfilePage(),
      ),
    ],
    debugLogDiagnostics: true,
  );
}

class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    notifyListeners();
    _subscription = stream.asBroadcastStream().listen(
          (dynamic _) => notifyListeners(),
        );
  }

  late final StreamSubscription<dynamic> _subscription;

  @override
  void dispose() {
    unawaited(_subscription.cancel());
    super.dispose();
  }
}
