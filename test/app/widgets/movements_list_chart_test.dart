import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:saver_expense_manager/app/app.dart';
import 'package:saver_expense_manager/l10n/l10n.dart';

class MockAuthenticationService extends Mock implements AuthenticationService {}

class MockDatabaseService extends Mock implements DatabaseService {}

void main() {
  group('MovementsListChart', () {
    late AuthenticationService mockAuth;
    late DatabaseService mockDatabase;
    late Query<Map<String, dynamic>> query;

    setUpAll(() {
      registerFallbackValue(DateTime.now());
      registerFallbackValue(CategoryType.expense);
    });

    setUp(() async {
      mockAuth = MockAuthenticationService();
      mockDatabase = MockDatabaseService();

      final fakeFirestore = FakeFirebaseFirestore();
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

    testWidgets('renders normally', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
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
      );

      expect(find.byType(MovementsListChart), findsOneWidget);
    });
  });
}
