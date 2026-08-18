import 'dart:async';

import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:saver_expense_manager/app/app.dart';
import 'package:saver_expense_manager/category/category.dart';
import 'package:saver_expense_manager/home/home.dart';
import 'package:saver_expense_manager/login/login.dart';
import 'package:saver_expense_manager/movement/movement.dart';
import 'package:saver_expense_manager/profile/profile.dart';
import 'package:saver_expense_manager/register/register.dart';
import 'package:saver_expense_manager/settings/settings.dart';

class AppRoutes {
  static GoRouter getRouter() {
    final authService = getIt<AuthService>();

    return GoRouter(
      refreshListenable: GoRouterRefreshStream(authService.userChanges),
      observers: [
        AppRouteObserver(analyticsService: getIt<AnalyticsService>()),
      ],
      redirect: redirect,
      initialLocation: authService.isLoggedIn
          ? AppRoute.home.path
          : AppRoute.login.path,
      routes: [
        GoRoute(
          name: AppRoute.register.name,
          path: AppRoute.register.path,
          builder: (context, state) => const RegisterPage(),
        ),
        GoRoute(
          name: AppRoute.login.name,
          path: AppRoute.login.path,
          builder: (context, state) => const LoginPage(),
        ),
        GoRoute(
          name: AppRoute.home.name,
          path: AppRoute.home.path,
          builder: (context, state) => const HomePage(),
          routes: [
            GoRoute(
              name: AppRoute.settings.name,
              path: AppRoute.settings.path,
              builder: (context, state) => const SettingsPage(),
            ),
            GoRoute(
              name: AppRoute.movement.name,
              path: AppRoute.movement.path,
              builder: (context, state) {
                final movement = _getExtra<Movement>(
                  state,
                  Movement.empty,
                  Movement.fromJson,
                );
                final type =
                    state.pathParameters['type'] ?? CategoryType.expense.value;
                final screenType =
                    state.pathParameters['screenType'] ??
                    MovementScreenType.add.name.toUpperCase();
                return MovementPage(
                  movement: movement,
                  type: type == CategoryType.expense.value
                      ? CategoryType.expense
                      : CategoryType.income,
                  screenType:
                      screenType == MovementScreenType.add.name.toUpperCase()
                      ? MovementScreenType.add
                      : MovementScreenType.edit,
                );
              },
            ),
            GoRoute(
              name: AppRoute.category.name,
              path: AppRoute.category.path,
              builder: (context, state) {
                final category = _getExtra<Category>(
                  state,
                  Category.empty,
                  Category.fromJson,
                );
                return CategoryPage(category: category);
              },
            ),
            GoRoute(
              name: AppRoute.profile.name,
              path: AppRoute.profile.path,
              builder: (context, state) => const ProfilePage(),
            ),
          ],
        ),
      ],
      debugLogDiagnostics: true,
    );
  }

  static T _getExtra<T>(
    GoRouterState state,
    T emptyValue,
    T Function(Map<String, dynamic>) fromJson,
  ) {
    final extra = state.extra;
    if (extra is T) {
      return extra;
    } else if (extra is Map<String, dynamic>) {
      try {
        return fromJson(extra);
      } on Exception catch (_) {
        return emptyValue;
      }
    } else {
      return emptyValue;
    }
  }

  static String? redirect(BuildContext context, GoRouterState state) {
    final authService = getIt<AuthService>();
    final userIsLoggedIn = authService.isLoggedIn;
    final isLoggingIn = state.fullPath == AppRoute.login.path;

    final isRegistering = state.fullPath == AppRoute.register.path;

    if (!userIsLoggedIn) {
      return (isLoggingIn || isRegistering) ? null : AppRoute.login.path;
    } else {
      return isLoggingIn ? AppRoute.home.path : null;
    }
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

enum AppRoute {
  login('/login', 'login'),
  register('/register', 'register'),
  home('/', 'home'),
  settings('settings', 'settings'),
  movement('movement/:type/:screenType', 'movement'),
  category('category', 'category'),
  profile('profile', 'profile');

  const AppRoute(this.path, this.name);
  final String path;
  final String name;
}
