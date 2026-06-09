import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';
import 'package:saver_expense_manager/app/app.dart';
import 'package:saver_expense_manager/l10n/l10n.dart';
import 'package:saver_expense_manager/profile/profile.dart';

class MockAuthService extends Mock implements AuthService {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('ProfilePage', () {
    late MockAuthService authService;
    late StreamController<AppUser?> userChangesController;

    setUp(() async {
      authService = MockAuthService();
      userChangesController = StreamController<AppUser?>();

      when(
        () => authService.userChanges,
      ).thenAnswer((_) => userChangesController.stream);

      if (getIt.isRegistered<AuthService>()) {
        await getIt.unregister<AuthService>();
      }
      getIt.registerSingleton<AuthService>(authService);
    });

    tearDown(() {
      unawaited(userChangesController.close());
    });

    Future<void> pumpProfilePage(WidgetTester tester) async {
      final router = GoRouter(
        initialLocation: '/profile',
        routes: [
          GoRoute(
            path: '/',
            builder: (context, state) => const Scaffold(body: Text('Home')),
            routes: [
              GoRoute(
                path: 'profile',
                builder: (context, state) => const ProfilePage(),
              ),
            ],
          ),
        ],
      );

      await tester.pumpWidget(
        MaterialApp.router(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          routerConfig: router,
        ),
      );
      await tester.pump();
    }

    testWidgets('renders CircularProgressIndicator when user is null', (
      tester,
    ) async {
      await pumpProfilePage(tester);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('renders ProfileView inside BlocProvider', (tester) async {
      await pumpProfilePage(tester);
      expect(find.byType(ProfileView), findsOneWidget);
    });
  });
}
