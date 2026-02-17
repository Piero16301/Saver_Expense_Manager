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

GoRouter goRouter() {
  final authService = getIt<AuthenticationService>();

  return GoRouter(
    refreshListenable: GoRouterRefreshStream(authService.userChanges),
    redirect: handleRedirect,
    initialLocation:
        authService.isLoggedIn ? HomePage.pagePath : LoginPage.pagePath,
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
          final type =
              state.pathParameters['type'] ?? CategoryType.expense.value;
          final screenType = state.pathParameters['screenType'] ?? 'ADD';
          return MovementPage(
            movement: movement,
            type: type == CategoryType.expense.value
                ? CategoryType.expense
                : CategoryType.income,
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

String? handleRedirect(BuildContext context, GoRouterState state) {
  final authService = getIt<AuthenticationService>();
  final userIsLoggedIn = authService.isLoggedIn;
  final isLoggingIn = state.fullPath == LoginPage.pagePath;

  final isRegistering = state.fullPath == RegisterPage.pagePath;

  if (!userIsLoggedIn) {
    return (isLoggingIn || isRegistering) ? null : LoginPage.pagePath;
  } else {
    return isLoggingIn ? HomePage.pagePath : null;
  }
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
