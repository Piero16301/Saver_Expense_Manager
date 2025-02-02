import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';
import 'package:saver_expense_manager/app/app.dart';
import 'package:saver_expense_manager/home/home.dart';
import 'package:saver_expense_manager/login/login.dart';
import 'package:user_api/user_api.dart';

GoRouter goRouter() {
  const unauthenticatedRoutes = <String>{
    '/login',
    '/email-verification',
  };

  return GoRouter(
    redirect: (context, state) {
      if (FirebaseAuth.instance.currentUser != null) {
        return state.fullPath == 'login' ? '/' : null;
      } else {
        if (unauthenticatedRoutes.any(
          (value) {
            if (state.fullPath != '/') return state.fullPath!.contains(value);
            return false;
          },
        )) {
          return null;
        } else {
          return '/login';
        }
      }
    },
    routes: [
      GoRoute(
        name: 'login',
        path: '/login',
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        name: 'email-verification',
        path: '/email-verification',
        builder: (context, state) => const EmailVerificationPage(),
      ),
      GoRoute(
        name: 'home',
        path: '/',
        builder: (context, state) => const HomePage(),
        routes: [
          GoRoute(
            name: 'enter-movement',
            path: 'enter-movement/:type/:screenType',
            builder: (context, state) {
              final movement = state.extra! as Movement;
              final type = state.pathParameters['type'] ?? 'EXPENSE';
              final screenType = state.pathParameters['screenType'] ?? 'ADD';
              return EnterMovementPage(
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
            name: 'profile',
            path: 'profile',
            builder: (context, state) => const ProfilePage(),
          ),
        ],
      ),
    ],
    debugLogDiagnostics: true,
  );
}
