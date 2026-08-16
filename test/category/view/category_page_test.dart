import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:mocktail/mocktail.dart';
import 'package:saver_expense_manager/app/app.dart';
import 'package:saver_expense_manager/category/category.dart';
import 'package:saver_expense_manager/l10n/l10n.dart';

class MockAppCubit extends MockCubit<AppState> implements AppCubit {}

class MockAuthService extends Mock implements AuthService {}

class MockDatabaseService extends Mock implements DatabaseService {}

void main() {
  setUpAll(() {
    registerFallbackValue(Category.empty);
  });

  group('CategoryPage', () {
    late AppCubit mockAppCubit;
    late AuthService mockAuth;
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
      mockAuth = MockAuthService();
      mockDatabase = MockDatabaseService();

      when(() => mockAppCubit.state).thenReturn(const AppState());
      when(() => mockAuth.currentUser).thenReturn(const AppUser(uid: 'user1'));
      when(
        () => mockDatabase.getMovementsStream(
          userId: any(named: 'userId'),
          startDate: any<DateTime?>(named: 'startDate'),
          endDate: any<DateTime?>(named: 'endDate'),
          type: any<CategoryType?>(named: 'type'),
          categoryId: any<String?>(named: 'categoryId'),
          limit: any<int>(named: 'limit'),
          orderByDate: any<bool>(named: 'orderByDate'),
        ),
      ).thenAnswer((_) => Stream.value([]));

      if (getIt.isRegistered<AuthService>()) {
        await getIt.unregister<AuthService>();
      }
      if (getIt.isRegistered<DatabaseService>()) {
        getIt.unregister<DatabaseService>();
      }

      getIt
        ..registerSingleton<AuthService>(mockAuth)
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

      expect(find.text('Feeding'), findsOneWidget);
      expect(find.byType(BlocProvider<CategoryCubit>), findsOneWidget);
    });
  });
}
