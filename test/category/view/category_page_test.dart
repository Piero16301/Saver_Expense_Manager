import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:saver_expense_manager/app/app.dart';
import 'package:saver_expense_manager/category/category.dart';
import 'package:saver_expense_manager/l10n/l10n.dart';

class MockAppCubit extends MockCubit<AppState> implements AppCubit {}

class MockAuthenticationService extends Mock implements AuthenticationService {}

class MockDatabaseService extends Mock implements DatabaseService {}

void main() {
  setUpAll(() {
    registerFallbackValue(Category.empty);
  });

  group('CategoryPage', () {
    late AppCubit mockAppCubit;
    late AuthenticationService mockAuth;
    late DatabaseService mockDatabase;

    const category = Category(
      id: '1',
      name: 'FEEDING',
      icon: 'food_icon',
      color: 'FF00FF00',
      type: CategoryType.expense,
    );

    setUp(() async {
      mockAppCubit = MockAppCubit();
      mockAuth = MockAuthenticationService();
      mockDatabase = MockDatabaseService();

      when(() => mockAppCubit.state).thenReturn(const AppState());
      when(() => mockAuth.currentUser).thenReturn(const AppUser(uid: 'user1'));
      when(
        () => mockDatabase.getTrendChartStream(
          userId: any(named: 'userId'),
          startMonth: any(named: 'startMonth'),
          endMonth: any(named: 'endMonth'),
          category: category,
        ),
      ).thenAnswer((_) => Stream.value([]));

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

    testWidgets('renders normally and provides CategoryCubit', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: BlocProvider.value(
            value: mockAppCubit,
            child: const CategoryPage(category: category),
          ),
        ),
      );

      expect(find.text('FEEDING'), findsOneWidget);
      expect(find.byType(BlocProvider<CategoryCubit>), findsOneWidget);
    });
  });
}
