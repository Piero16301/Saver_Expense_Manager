import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';
import 'package:saver_expense_manager/app/app.dart';
import 'package:saver_expense_manager/home/home.dart';
import 'package:saver_expense_manager/home/settings/settings.dart';
import 'package:saver_expense_manager/login/login.dart';
import 'package:user_api/user_api.dart';

GoRouter goRouter() {
  const unauthenticatedRoutes = <String>{
    LoginPage.pagePath,
    EmailVerificationPage.pagePath,
  };

  return GoRouter(
    redirect: (context, state) {
      if (FirebaseAuth.instance.currentUser != null) {
        return state.fullPath == LoginPage.pageName ? HomePage.pagePath : null;
      } else {
        if (unauthenticatedRoutes.any(
          (value) {
            if (state.fullPath != HomePage.pagePath) {
              return state.fullPath!.contains(value);
            }
            return false;
          },
        )) {
          return null;
        } else {
          return LoginPage.pagePath;
        }
      }
    },
    routes: [
      GoRoute(
        name: LoginPage.pageName,
        path: LoginPage.pagePath,
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        name: EmailVerificationPage.pageName,
        path: EmailVerificationPage.pagePath,
        builder: (context, state) => const EmailVerificationPage(),
      ),
      GoRoute(
        name: HomePage.pageName,
        path: HomePage.pagePath,
        builder: (context, state) => const HomePage(),
        routes: [
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
                type: type == 'EXPENSE'
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
      ),
    ],
    debugLogDiagnostics: true,
  );
}
