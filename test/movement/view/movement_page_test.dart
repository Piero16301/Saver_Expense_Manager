import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';
import 'package:saver_expense_manager/app/app.dart';
import 'package:saver_expense_manager/l10n/l10n.dart';
import 'package:saver_expense_manager/movement/movement.dart';

class MockDatabaseService extends Mock implements DatabaseService {}

class MockAuthService extends Mock implements AuthService {}

class MockAppUser extends Mock implements AppUser {}

class MockAppCubit extends MockCubit<AppState> implements AppCubit {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('MovementPage', () {
    late DatabaseService databaseService;
    late AuthService authenticationService;
    late AppUser user;
    late AppCubit appCubit;

    final movement = Movement(
      id: '1',
      title: 'Title',
      description: 'Description',
      date: DateTime.now(),
      category: Category.empty,
      price: 0,
      user: 'user',
    );

    const categories = [
      Category(
        id: '1',
        name: 'Food',
        icon: 'food',
        color: 'red',
        type: CategoryType.expense,
      ),
    ];

    setUpAll(() {
      registerFallbackValue(const MovementState());
      registerFallbackValue(const AppState());
    });

    setUp(() async {
      databaseService = MockDatabaseService();
      authenticationService = MockAuthService();
      user = MockAppUser();
      appCubit = MockAppCubit();

      if (getIt.isRegistered<DatabaseService>()) {
        await getIt.unregister<DatabaseService>();
      }
      getIt.registerSingleton<DatabaseService>(databaseService);

      if (getIt.isRegistered<AuthService>()) {
        getIt.unregister<AuthService>();
      }
      getIt.registerSingleton<AuthService>(authenticationService);

      when(() => user.uid).thenReturn('uid');
      when(() => authenticationService.currentUser).thenReturn(user);
      when(() => appCubit.state).thenReturn(const AppState());
    });

    Future<void> pumpMovementPage(WidgetTester tester) async {
      final router = GoRouter(
        initialLocation: '/movement',
        routes: [
          GoRoute(
            path: '/',
            builder: (context, state) => const Scaffold(body: Text('Home')),
            routes: [
              GoRoute(
                path: 'movement',
                builder: (context, state) => BlocProvider.value(
                  value: appCubit,
                  child: MovementPage(
                    movement: movement,
                    type: CategoryType.expense,
                    screenType: MovementScreenType.add,
                  ),
                ),
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

    testWidgets('renders CircularProgressIndicator when loading categories', (
      tester,
    ) async {
      when(
        () => databaseService.getCategoriesStream(),
      ).thenAnswer((_) => const Stream.empty());

      await pumpMovementPage(tester);

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('renders error text when categories are empty', (tester) async {
      when(
        () => databaseService.getCategoriesStream(),
      ).thenAnswer((_) => Stream.value([]));

      await pumpMovementPage(tester);
      await tester.pumpAndSettle();

      expect(find.text('No categories found'), findsOneWidget);
    });

    testWidgets('renders MovementView when categories are loaded', (
      tester,
    ) async {
      when(
        () => databaseService.getCategoriesStream(),
      ).thenAnswer((_) => Stream.value(categories));

      await pumpMovementPage(tester);
      await tester.pumpAndSettle();

      expect(find.byType(MovementView), findsOneWidget);
    });
  });
}
