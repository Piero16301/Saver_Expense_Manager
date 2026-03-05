import 'package:bloc_test/bloc_test.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:saver_expense_manager/app/app.dart';
import 'package:saver_expense_manager/l10n/l10n.dart';

class MockAuthenticationService extends Mock implements AuthenticationService {}

class MockDatabaseService extends Mock implements DatabaseService {}

class MockAppCubit extends MockCubit<AppState> implements AppCubit {}

void main() {
  group('MovementsListChart', () {
    late AuthenticationService mockAuth;
    late DatabaseService mockDatabase;
    late AppCubit appCubit;
    late FakeFirebaseFirestore fakeFirestore;
    late Query<Map<String, dynamic>> query;

    setUpAll(() {
      registerFallbackValue(DateTime.now());
      registerFallbackValue(CategoryType.expense);
    });

    setUp(() async {
      mockAuth = MockAuthenticationService();
      mockDatabase = MockDatabaseService();
      appCubit = MockAppCubit();

      when(() => appCubit.state).thenReturn(const AppState());

      fakeFirestore = FakeFirebaseFirestore();
      query = fakeFirestore
          .collection('movements')
          .where('user', isEqualTo: 'user1');

      if (getIt.isRegistered<AuthenticationService>()) {
        await getIt.unregister<AuthenticationService>();
      }
      if (getIt.isRegistered<DatabaseService>()) {
        getIt.unregister<DatabaseService>();
      }

      getIt
        ..registerSingleton<AuthenticationService>(mockAuth)
        ..registerSingleton<DatabaseService>(mockDatabase);

      when(() => mockAuth.currentUser).thenReturn(const AppUser(uid: 'user1'));
      when(
        () => mockDatabase.getExpenseTypeMovementsQuery(
          userId: any(named: 'userId'),
          monthSelected: any(named: 'monthSelected'),
          expenseType: any(named: 'expenseType'),
        ),
      ).thenReturn(query);
    });

    testWidgets('renders empty state when no data', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: BlocProvider.value(
            value: appCubit,
            child: Scaffold(
              body: Column(
                children: [
                  MovementsListChart(
                    expenseType: CategoryType.expense,
                    monthSelected: DateTime(2024, 3),
                  ),
                ],
              ),
            ),
          ),
        ),
      );

      await tester.pump();
      expect(find.text('No movements registered'), findsOneWidget);
    });

    testWidgets('renders movement items when data is present', (tester) async {
      final movement = Movement(
        id: '1',
        title: 'Lunch',
        description: 'Subway',
        price: 15.5,
        date: DateTime(2024, 3, 10),
        category: const Category(
          id: '1',
          name: 'Food',
          icon: 'food_icon',
          color: 'FF00FF00',
          type: CategoryType.expense,
        ),
        movementRecap: 'Lunch recap',
        user: 'user1',
      );

      await fakeFirestore.collection('movements').add(movement.toJson());

      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: BlocProvider.value(
            value: appCubit,
            child: Scaffold(
              body: Column(
                children: [
                  MovementsListChart(
                    expenseType: CategoryType.expense,
                    monthSelected: DateTime(2024, 3),
                  ),
                ],
              ),
            ),
          ),
        ),
      );

      await tester.pump();
      await tester.pump();

      expect(find.byType(ListMovementsItemHome), findsOneWidget);
      expect(find.text('Lunch'), findsOneWidget);
      expect(find.textContaining('15.50'), findsOneWidget);
    });

    testWidgets('calls DatabaseService with correct parameters',
        (tester) async {
      final month = DateTime(2024, 3);
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: BlocProvider.value(
            value: appCubit,
            child: Scaffold(
              body: Column(
                children: [
                  MovementsListChart(
                    expenseType: CategoryType.expense,
                    monthSelected: month,
                  ),
                ],
              ),
            ),
          ),
        ),
      );

      verify(
        () => mockDatabase.getExpenseTypeMovementsQuery(
          userId: 'user1',
          monthSelected: month,
          expenseType: CategoryType.expense,
        ),
      ).called(1);
    });
  });
}
