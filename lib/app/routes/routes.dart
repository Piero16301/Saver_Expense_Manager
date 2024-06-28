import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';
import 'package:saver_expense_manager/home/home.dart';
import 'package:saver_expense_manager/login/login.dart';

GoRouter goRouter() {
  const unauthenticatedRoutes = <String>{
    '/login',
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
        name: 'home',
        path: '/',
        builder: (context, state) => const HomePage(),
      ),
    ],
    debugLogDiagnostics: true,
  );
}
