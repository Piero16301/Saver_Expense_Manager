import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
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

class MockAuthenticationService extends Mock implements AuthenticationService {}

class MockDatabaseService extends Mock implements DatabaseService {}

void main() {
  setUpAll(() {
    registerFallbackValue(Category.empty);
    registerFallbackValue(DateTime.now());
  });

  group('CategoryView', () {
    late AppCubit appCubit;
    late CategoryCubit categoryCubit;
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
      appCubit = MockAppCubit();
      categoryCubit = MockCategoryCubit();
      mockAuth = MockAuthenticationService();
      mockDatabase = MockDatabaseService();

      when(() => appCubit.state).thenReturn(const AppState());
      when(() => categoryCubit.state)
          .thenReturn(const CategoryState(category: category));
      when(() => mockAuth.currentUser).thenReturn(const AppUser(uid: 'user1'));
      when(
        () => mockDatabase.getTrendChartStream(
          userId: any(named: 'userId'),
          startMonth: any(named: 'startMonth'),
          endMonth: any(named: 'endMonth'),
          category: category,
        ),
      ).thenAnswer((_) => Stream.value([]));

      final instance = FakeFirebaseFirestore();
      final query = instance.collection('movements');
      when(
        () => mockDatabase.getCategoryMovementsQuery(
          userId: any(named: 'userId'),
          category: category,
          monthSelected: any(named: 'monthSelected'),
        ),
      ).thenReturn(query);

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
        () => mockDatabase.getTrendChartStream(
          userId: any(named: 'userId'),
          startMonth: any(named: 'startMonth'),
          endMonth: any(named: 'endMonth'),
          category: any(named: 'category'),
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
        () => mockDatabase.getTrendChartStream(
          userId: any(named: 'userId'),
          startMonth: any(named: 'startMonth'),
          endMonth: any(named: 'endMonth'),
          category: any(named: 'category'),
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
          movementRecap: 'Lunch recap',
        ),
      ];

      when(
        () => mockDatabase.getTrendChartStream(
          userId: any(named: 'userId'),
          startMonth: any(named: 'startMonth'),
          endMonth: any(named: 'endMonth'),
          category: any(named: 'category'),
        ),
      ).thenAnswer((_) => Stream.value(movements));

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      expect(find.byType(LinearChart), findsOneWidget);

      await tester.pump(const Duration(seconds: 3));
    });

    testWidgets('TabMovementsCategory handles month navigation',
        (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pump();
      await tester.tap(find.text('Movements'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 600));

      expect(find.byType(MonthSelector), findsOneWidget);

      await tester.tap(
        find.byType(IconButton).at(1),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));
    });
  });
}
