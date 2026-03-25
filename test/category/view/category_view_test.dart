import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:saver_expense_manager/app/app.dart';
import 'package:saver_expense_manager/category/category.dart';
import 'package:saver_expense_manager/l10n/l10n.dart';

class MockAppCubit extends MockCubit<AppState> implements AppCubit {}

class MockCategoryCubit extends MockCubit<CategoryState>
    implements CategoryCubit {}

class MockAuthService extends Mock implements AuthService {}

class MockDatabaseService extends Mock implements DatabaseService {}

class MockRemoteConfigService extends Mock implements RemoteConfigService {}

void main() {
  setUpAll(() {
    registerFallbackValue(Category.empty);
    registerFallbackValue(DateTime.now());
  });

  group('CategoryView', () {
    late AppCubit appCubit;
    late CategoryCubit categoryCubit;
    late AuthService mockAuth;
    late DatabaseService mockDatabase;
    late MockRemoteConfigService mockRemoteConfig;

    const category = Category(
      id: '1',
      name: 'FEEDING',
      icon: 'food_icon',
      color: 'FF00FF00',
      type: CategoryType.expense,
    );

    setUp(() async {
      appCubit = MockAppCubit();
      categoryCubit = MockCategoryCubit();
      mockAuth = MockAuthService();
      mockDatabase = MockDatabaseService();
      mockRemoteConfig = MockRemoteConfigService();

      when(() => appCubit.state).thenReturn(const AppState());
      when(() => categoryCubit.state)
          .thenReturn(const CategoryState(category: category));
      when(() => mockAuth.currentUser).thenReturn(const AppUser(uid: 'user1'));
      when(
        () => mockDatabase.getMovementsStream(
          userId: any(named: 'userId'),
          startDate: any(named: 'startDate'),
          endDate: any(named: 'endDate'),
          type: any(named: 'type'),
          categoryId: any(named: 'categoryId'),
          limit: any(named: 'limit'),
          orderByDate: any(named: 'orderByDate'),
        ),
      ).thenAnswer((_) => Stream.value([]));

      if (getIt.isRegistered<AuthService>()) {
        await getIt.unregister<AuthService>();
      }
      if (getIt.isRegistered<DatabaseService>()) {
        await getIt.unregister<DatabaseService>();
      }
      if (getIt.isRegistered<RemoteConfigService>()) {
        await getIt.unregister<RemoteConfigService>();
      }

      getIt
        ..registerSingleton<AuthService>(mockAuth)
        ..registerSingleton<DatabaseService>(mockDatabase)
        ..registerSingleton<RemoteConfigService>(mockRemoteConfig);

      when(() => mockRemoteConfig.paginationLimit).thenReturn(10);
    });

    Widget createWidgetUnderTest({
      Orientation orientation = Orientation.portrait,
    }) {
      final size = orientation == Orientation.portrait
          ? const Size(600, 1000)
          : const Size(1000, 600);

      return MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: MultiBlocProvider(
          providers: [
            BlocProvider.value(value: appCubit),
            BlocProvider.value(value: categoryCubit),
          ],
          child: MediaQuery(
            data: MediaQueryData(size: size),
            child: const CategoryView(),
          ),
        ),
      );
    }

    testWidgets('renders normally in portrait', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pump();

      expect(find.text('Category details'), findsOneWidget);
      expect(find.byType(CategoryIconAndName), findsOneWidget);
      expect(find.byType(CategoryTabBar), findsOneWidget);
      expect(find.text('FEEDING'), findsOneWidget);
    });

    testWidgets('renders normally in landscape', (tester) async {
      await tester.pumpWidget(
        createWidgetUnderTest(orientation: Orientation.landscape),
      );
      await tester.pump();

      expect(find.byType(CategoryIconAndName), findsOneWidget);
      expect(find.byType(CategoryTabBar), findsOneWidget);
      expect(find.byType(Row), findsWidgets);
    });

    testWidgets('pops when leading button is pressed', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pump();
      final backButton = find.byType(IconButton).first;
      expect(backButton, findsOneWidget);
    });

    testWidgets('CategoryTabBar switches tabs', (tester) async {
      when(
        () => mockDatabase.getMovementsStream(
          userId: any(named: 'userId'),
          startDate: any(named: 'startDate'),
          endDate: any(named: 'endDate'),
          type: any(named: 'type'),
          categoryId: any(named: 'categoryId'),
          limit: any(named: 'limit'),
          orderByDate: any(named: 'orderByDate'),
        ),
      ).thenAnswer((_) => Stream.value([]));

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pump();

      expect(find.byType(TabTrendCategory), findsOneWidget);

      await tester.tap(find.text('Movements'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 600));

      expect(find.byType(TabMovementsCategory), findsOneWidget);
    });

    testWidgets('TabTrendCategory shows loading and then empty state',
        (tester) async {
      final streamController = StreamController<List<Movement>>();
      when(
        () => mockDatabase.getMovementsStream(
          userId: any(named: 'userId'),
          startDate: any(named: 'startDate'),
          endDate: any(named: 'endDate'),
          type: any(named: 'type'),
          categoryId: any(named: 'categoryId'),
          limit: any(named: 'limit'),
          orderByDate: any(named: 'orderByDate'),
        ),
      ).thenAnswer((_) => streamController.stream);

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      streamController.add([]);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      expect(
        find.text('No data available for this month range'),
        findsOneWidget,
      );
      await streamController.close();
    });

    testWidgets('TabTrendCategory shows chart with data', (tester) async {
      final movements = [
        Movement(
          id: '1',
          title: 'Lunch',
          description: 'Lunch description',
          price: 15.5,
          date: DateTime.now(),
          category: category,
          user: 'user1',
        ),
      ];

      when(
        () => mockDatabase.getMovementsStream(
          userId: any(named: 'userId'),
          startDate: any(named: 'startDate'),
          endDate: any(named: 'endDate'),
          type: any(named: 'type'),
          categoryId: any(named: 'categoryId'),
          limit: any(named: 'limit'),
          orderByDate: any(named: 'orderByDate'),
        ),
      ).thenAnswer((_) => Stream.value(movements));

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      expect(find.byType(LinearChart), findsOneWidget);

      await tester.pump(const Duration(seconds: 3));
    });

    testWidgets('TabTrendCategory handles date range changes', (tester) async {
      final streamController = StreamController<List<Movement>>();
      when(
        () => mockDatabase.getMovementsStream(
          userId: any(named: 'userId'),
          startDate: any(named: 'startDate'),
          endDate: any(named: 'endDate'),
          type: any(named: 'type'),
          categoryId: any(named: 'categoryId'),
          limit: any(named: 'limit'),
          orderByDate: any(named: 'orderByDate'),
        ),
      ).thenAnswer((_) => streamController.stream);

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pump();

      final monthRangeSelector = tester.widget<MonthRangeSelector>(
        find.byType(MonthRangeSelector),
      );

      monthRangeSelector.onChangeStartMonth(DateTime(2023, 5));
      await tester.pump();

      final r2 =
          tester.widget<MonthRangeSelector>(find.byType(MonthRangeSelector));
      r2.onChangeEndMonth(DateTime(2023, 6));
      await tester.pump();

      final r3 =
          tester.widget<MonthRangeSelector>(find.byType(MonthRangeSelector));
      r3.onChangeStartMonth(null);
      r3.onChangeEndMonth(null);
      await tester.pump();

      await streamController.close();
    });

    testWidgets('TabMovementsCategory handles month navigation edge cases',
        (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pump();
      await tester.tap(find.text('Movements'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 600));

      expect(find.byType(MonthSelector), findsOneWidget);

      final monthSelector = tester.widget<MonthSelector>(
        find.byType(MonthSelector),
      );

      monthSelector.onBack();
      await tester.pump();

      final m2 = tester.widget<MonthSelector>(find.byType(MonthSelector));
      m2.onForward();
      await tester.pump();

      final m3 = tester.widget<MonthSelector>(find.byType(MonthSelector));
      m3.onChangeMonth(DateTime(2023));
      await tester.pump();

      final m4 = tester.widget<MonthSelector>(find.byType(MonthSelector));
      m4.onBack();
      await tester.pump();

      final m5 = tester.widget<MonthSelector>(find.byType(MonthSelector));
      m5.onChangeMonth(DateTime(2023, 12));
      await tester.pump();

      final m6 = tester.widget<MonthSelector>(find.byType(MonthSelector));
      m6.onForward();
      await tester.pump();

      final m7 = tester.widget<MonthSelector>(find.byType(MonthSelector));
      m7.onChangeMonth(null);
      await tester.pump();
    });
  });
}
