import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:mocktail/mocktail.dart';
import 'package:saver_expense_manager/app/app.dart';
import 'package:saver_expense_manager/home/home.dart';
import 'package:saver_expense_manager/l10n/l10n.dart';

class MockExpensesHomeCubit extends MockCubit<ExpensesHomeState>
    implements ExpensesHomeCubit {}

class MockAppCubit extends MockCubit<AppState> implements AppCubit {}

class MockAuthService extends Mock implements AuthService {}

class MockDatabaseService extends Mock implements DatabaseService {}

class MockRemoteConfigService extends Mock implements RemoteConfigService {}

void main() {
  group('ExpensesHomeView', () {
    late MockExpensesHomeCubit mockCubit;
    late MockAppCubit mockAppCubit;
    late MockAuthService mockAuth;
    late MockDatabaseService mockDatabase;
    late MockRemoteConfigService mockRemoteConfigService;

    setUpAll(() {
      registerFallbackValue(DateTime.now());
      registerFallbackValue(CategoryType.expense);
    });

    setUp(() async {
      mockCubit = MockExpensesHomeCubit();
      mockAppCubit = MockAppCubit();
      mockAuth = MockAuthService();
      mockDatabase = MockDatabaseService();
      mockRemoteConfigService = MockRemoteConfigService();
      when(() => mockRemoteConfigService.paginationLimit).thenReturn(10);

      when(() => mockAppCubit.state).thenReturn(const AppState());

      when(
        () => mockCubit.state,
      ).thenReturn(ExpensesHomeState(monthSelected: DateTime(2024, 3)));
      when(
        () => mockAuth.currentUser,
      ).thenReturn(const AppUser(uid: 'user123'));

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
        ..registerSingleton<DatabaseService>(mockDatabase)
        ..registerSingleton<RemoteConfigService>(mockRemoteConfigService);
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

    testWidgets('renders MonthSelector and loading indicator initially', (
      tester,
    ) async {
      final controller = StreamController<List<Movement>>();
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
      ).thenAnswer((_) => controller.stream);

      await tester.pumpWidget(buildSubject());
      await tester.pump();

      expect(find.byType(MonthSelector), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      await controller.close();
    });

    testWidgets('shows empty state message when no movements', (tester) async {
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

      await tester.pumpWidget(buildSubject());
      await tester.pump();
      await tester.pump();

      expect(find.byType(MonthSelector), findsOneWidget);
      expect(find.textContaining('expenses'), findsWidgets);
    });

    testWidgets('shows chart and list when movements are present', (
      tester,
    ) async {
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
        user: 'user123',
      );

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
      ).thenAnswer((_) => Stream.value([movement]));

      await tester.pumpWidget(buildSubject());
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.byType(MonthSelector), findsOneWidget);
      expect(find.byType(DoughnutCircularChart), findsOneWidget);
      expect(find.byType(TotalSpentChart), findsOneWidget);
    });

    testWidgets('shows landscape layout when in landscape orientation', (
      tester,
    ) async {
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
        user: 'user123',
      );

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
      ).thenAnswer((_) => Stream.value([movement]));

      await tester.pumpWidget(buildSubject(orientation: Orientation.landscape));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.byType(Row), findsWidgets);
      expect(find.byType(MonthSelector), findsOneWidget);
    });

    testWidgets('tapping back on MonthSelector calls previousMonth', (
      tester,
    ) async {
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

      await tester.pumpWidget(buildSubject());
      await tester.pump();

      final backButton = find.byType(IconButton).first;
      await tester.tap(backButton);

      verify(() => mockCubit.previousMonth()).called(1);
    });

    testWidgets('tapping forward on MonthSelector calls nextMonth', (
      tester,
    ) async {
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

      await tester.pumpWidget(buildSubject());
      await tester.pump();

      final forwardButton = find.byType(IconButton).at(1);
      await tester.tap(forwardButton);

      verify(() => mockCubit.nextMonth()).called(1);
    });
  });
}
