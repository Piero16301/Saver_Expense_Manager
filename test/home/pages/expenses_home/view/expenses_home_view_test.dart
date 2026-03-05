import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:saver_expense_manager/app/app.dart';
import 'package:saver_expense_manager/home/home.dart';
import 'package:saver_expense_manager/l10n/l10n.dart';

class MockExpensesHomeCubit extends MockCubit<ExpensesHomeState>
    implements ExpensesHomeCubit {}

class MockAppCubit extends MockCubit<AppState> implements AppCubit {}

class MockAuthenticationService extends Mock implements AuthenticationService {}

class MockDatabaseService extends Mock implements DatabaseService {}

void main() {
  group('ExpensesHomeView', () {
    late MockExpensesHomeCubit mockCubit;
    late MockAppCubit mockAppCubit;
    late MockAuthenticationService mockAuth;
    late MockDatabaseService mockDatabase;
    late FakeFirebaseFirestore fakeFirestore;

    setUpAll(() {
      registerFallbackValue(DateTime.now());
      registerFallbackValue(CategoryType.expense);
    });

    setUp(() async {
      mockCubit = MockExpensesHomeCubit();
      mockAppCubit = MockAppCubit();
      mockAuth = MockAuthenticationService();
      mockDatabase = MockDatabaseService();
      fakeFirestore = FakeFirebaseFirestore();

      when(() => mockAppCubit.state).thenReturn(const AppState());

      when(() => mockCubit.state).thenReturn(
        ExpensesHomeState(monthSelected: DateTime(2024, 3)),
      );
      when(() => mockAuth.currentUser)
          .thenReturn(const AppUser(uid: 'user123'));

      when(
        () => mockDatabase.getMonthMovementsStream(
          userId: any(named: 'userId'),
          monthSelected: any(named: 'monthSelected'),
          type: any(named: 'type'),
        ),
      ).thenAnswer((_) => Stream.value([]));

      when(
        () => mockDatabase.getExpenseTypeMovementsQuery(
          userId: any(named: 'userId'),
          monthSelected: any(named: 'monthSelected'),
          expenseType: any(named: 'expenseType'),
        ),
      ).thenReturn(fakeFirestore.collection('movements'));

      if (getIt.isRegistered<AuthenticationService>()) {
        await getIt.unregister<AuthenticationService>();
      }
      if (getIt.isRegistered<DatabaseService>()) {
        getIt.unregister<DatabaseService>();
      }

      getIt
        ..registerSingleton<AuthenticationService>(mockAuth)
        ..registerSingleton<DatabaseService>(mockDatabase);
    });

    tearDown(getIt.reset);

    Widget buildSubject({Orientation orientation = Orientation.portrait}) {
      final size = orientation == Orientation.portrait
          ? const Size(400, 800)
          : const Size(800, 400);
      return MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: MultiBlocProvider(
            providers: [
              BlocProvider<AppCubit>.value(value: mockAppCubit),
              BlocProvider<ExpensesHomeCubit>.value(value: mockCubit),
            ],
            child: MediaQuery(
              data: MediaQueryData(size: size),
              child: const ExpensesHomeView(),
            ),
          ),
        ),
      );
    }

    testWidgets('renders MonthSelector and loading indicator initially',
        (tester) async {
      final controller = StreamController<List<Movement>>();
      when(
        () => mockDatabase.getMonthMovementsStream(
          userId: any(named: 'userId'),
          monthSelected: any(named: 'monthSelected'),
          type: any(named: 'type'),
        ),
      ).thenAnswer((_) => controller.stream);

      await tester.pumpWidget(buildSubject());
      await tester.pump();

      expect(find.byType(MonthSelector), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      await controller.close();
    });

    testWidgets('shows empty state message when no movements', (tester) async {
      when(
        () => mockDatabase.getMonthMovementsStream(
          userId: any(named: 'userId'),
          monthSelected: any(named: 'monthSelected'),
          type: any(named: 'type'),
        ),
      ).thenAnswer((_) => Stream.value([]));

      await tester.pumpWidget(buildSubject());
      await tester.pump();
      await tester.pump();

      expect(find.byType(MonthSelector), findsOneWidget);
      expect(find.textContaining('expenses'), findsWidgets);
    });

    testWidgets('shows chart and list when movements are present',
        (tester) async {
      final movement = Movement(
        id: '1',
        title: 'Lunch',
        description: 'Subway',
        price: 15.5,
        date: DateTime(2024, 3, 10),
        category: const Category(
          id: 'cat1',
          name: 'FEEDING',
          icon: 'food_icon',
          color: 'FF00FF00',
          type: CategoryType.expense,
        ),
        movementRecap: 'Lunch recap',
        user: 'user123',
      );

      when(
        () => mockDatabase.getMonthMovementsStream(
          userId: any(named: 'userId'),
          monthSelected: any(named: 'monthSelected'),
          type: any(named: 'type'),
        ),
      ).thenAnswer((_) => Stream.value([movement]));

      await tester.pumpWidget(buildSubject());
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.byType(MonthSelector), findsOneWidget);
      expect(find.byType(DoughnutCircularChart), findsOneWidget);
      expect(find.byType(TotalSpentChart), findsOneWidget);
    });

    testWidgets('shows landscape layout when in landscape orientation',
        (tester) async {
      final movement = Movement(
        id: '2',
        title: 'Dinner',
        description: 'Restaurant',
        price: 30,
        date: DateTime(2024, 3, 15),
        category: const Category(
          id: 'cat1',
          name: 'FEEDING',
          icon: 'food_icon',
          color: 'FF00FF00',
          type: CategoryType.expense,
        ),
        movementRecap: 'Dinner recap',
        user: 'user123',
      );

      when(
        () => mockDatabase.getMonthMovementsStream(
          userId: any(named: 'userId'),
          monthSelected: any(named: 'monthSelected'),
          type: any(named: 'type'),
        ),
      ).thenAnswer((_) => Stream.value([movement]));

      await tester.pumpWidget(
        buildSubject(orientation: Orientation.landscape),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.byType(Row), findsWidgets);
      expect(find.byType(MonthSelector), findsOneWidget);
    });

    testWidgets('tapping back on MonthSelector calls previousMonth',
        (tester) async {
      when(
        () => mockDatabase.getMonthMovementsStream(
          userId: any(named: 'userId'),
          monthSelected: any(named: 'monthSelected'),
          type: any(named: 'type'),
        ),
      ).thenAnswer((_) => Stream.value([]));

      await tester.pumpWidget(buildSubject());
      await tester.pump();

      final backButton = find.byType(IconButton).first;
      await tester.tap(backButton);

      verify(() => mockCubit.previousMonth()).called(1);
    });

    testWidgets('tapping forward on MonthSelector calls nextMonth',
        (tester) async {
      when(
        () => mockDatabase.getMonthMovementsStream(
          userId: any(named: 'userId'),
          monthSelected: any(named: 'monthSelected'),
          type: any(named: 'type'),
        ),
      ).thenAnswer((_) => Stream.value([]));

      await tester.pumpWidget(buildSubject());
      await tester.pump();

      final forwardButton = find.byType(IconButton).at(1);
      await tester.tap(forwardButton);

      verify(() => mockCubit.nextMonth()).called(1);
    });
  });
}
