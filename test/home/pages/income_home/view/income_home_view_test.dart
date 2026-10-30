import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:expressive_kit/expressive_kit.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:mocktail/mocktail.dart';
import 'package:saver_expense_manager/app/app.dart';
import 'package:saver_expense_manager/home/home.dart';
import 'package:saver_expense_manager/l10n/l10n.dart';

class MockIncomeHomeCubit extends MockCubit<IncomeHomeState>
    implements IncomeHomeCubit {}

class MockAppCubit extends MockCubit<AppState> implements AppCubit {}

class MockAuthService extends Mock implements AuthService {}

class MockDatabaseService extends Mock implements DatabaseService {}

class MockRemoteConfigService extends Mock implements RemoteConfigService {}

void main() {
  group('IncomeHomePage', () {
    late MockAppCubit mockAppCubit;
    late MockAuthService mockAuth;
    late MockDatabaseService mockDatabase;
    late MockRemoteConfigService mockRemoteConfigService;

    setUpAll(() {
      registerFallbackValue(DateTime.now());
      registerFallbackValue(CategoryType.income);
    });

    setUp(() async {
      mockAppCubit = MockAppCubit();
      mockAuth = MockAuthService();
      mockDatabase = MockDatabaseService();
      mockRemoteConfigService = MockRemoteConfigService();
      when(() => mockRemoteConfigService.paginationLimit).thenReturn(10);

      when(() => mockAppCubit.state).thenReturn(const AppState());
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

    testWidgets('renders IncomeHomeView', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: MultiBlocProvider(
            providers: [
              BlocProvider<AppCubit>.value(value: mockAppCubit),
              BlocProvider<IncomeHomeCubit>(
                create: (_) => IncomeHomeCubit()..init(),
              ),
            ],
            child: const MediaQuery(
              data: MediaQueryData(size: Size(400, 800)),
              child: IncomeHomePage(),
            ),
          ),
        ),
      );
      await tester.pump();

      expect(find.byType(IncomeHomeView), findsOneWidget);
    });
  });

  group('IncomeHomeView', () {
    late MockIncomeHomeCubit mockCubit;
    late MockAppCubit mockAppCubit;
    late MockAuthService mockAuth;
    late MockDatabaseService mockDatabase;
    late MockRemoteConfigService mockRemoteConfigService;

    setUpAll(() {
      registerFallbackValue(DateTime.now());
      registerFallbackValue(CategoryType.income);
    });

    setUp(() async {
      mockCubit = MockIncomeHomeCubit();
      mockAppCubit = MockAppCubit();
      mockAuth = MockAuthService();
      mockDatabase = MockDatabaseService();
      mockRemoteConfigService = MockRemoteConfigService();
      when(() => mockRemoteConfigService.paginationLimit).thenReturn(10);

      when(() => mockAppCubit.state).thenReturn(const AppState());
      when(
        () => mockCubit.state,
      ).thenReturn(IncomeHomeState(monthSelected: DateTime(2024, 3)));
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
              BlocProvider<IncomeHomeCubit>.value(value: mockCubit),
            ],
            child: MediaQuery(
              data: MediaQueryData(size: size),
              child: const IncomeHomeView(),
            ),
          ),
        ),
      );
    }

    testWidgets('renders loading indicator initially', (tester) async {
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

      expect(find.byType(ExpressiveCircularProgressIndicator), findsOneWidget);

      await controller.close();
    });

    testWidgets('shows empty state message when no income movements', (
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
      await tester.pump();

      expect(find.textContaining('income'), findsWidgets);
    });

    testWidgets('shows chart and list when income movements are present', (
      tester,
    ) async {
      final movement = Movement(
        id: '1',
        title: 'Salary',
        description: 'Monthly salary',
        price: 3000,
        date: DateTime(2024, 3),
        category: const Category(
          id: 'cat1',
          name: 'SALARY',
          icon: 'salary_icon',
          color: 'FF0000FF',
          type: CategoryType.income,
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

      expect(find.byType(CategorySummaryCard), findsOneWidget);
      expect(find.byType(IncomeHomeMobileView), findsOneWidget);
      expect(find.byType(IncomeHomeWebView), findsNothing);
    });

    testWidgets('shows landscape layout when in landscape orientation', (
      tester,
    ) async {
      final movement = Movement(
        id: '2',
        title: 'Freelance',
        description: 'Project payment',
        price: 500,
        date: DateTime(2024, 3, 15),
        category: const Category(
          id: 'cat2',
          name: 'FREELANCE',
          icon: 'freelance_icon',
          color: 'FF0000FF',
          type: CategoryType.income,
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
      expect(find.byType(IncomeHomeWebView), findsOneWidget);
      expect(find.byType(IncomeHomeMobileView), findsNothing);
    });
  });
}
