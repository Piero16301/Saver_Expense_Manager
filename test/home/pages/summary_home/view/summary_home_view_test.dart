import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:material_ui/material_ui.dart';
import 'package:mocktail/mocktail.dart';
import 'package:saver_expense_manager/app/app.dart';
import 'package:saver_expense_manager/home/home.dart';
import 'package:saver_expense_manager/l10n/l10n.dart';

class MockSummaryHomeCubit extends MockCubit<SummaryHomeState>
    implements SummaryHomeCubit {}

class MockAppCubit extends MockCubit<AppState> implements AppCubit {}

class MockDatabaseService extends Mock implements DatabaseService {}

class MockRemoteConfigService extends Mock implements RemoteConfigService {}

class MockAuthService extends Mock implements AuthService {}

void main() {
  late MockDatabaseService mockDatabaseService;
  late MockRemoteConfigService mockRemoteConfigService;
  late MockAuthService mockAuthService;
  late MockAppCubit mockAppCubit;
  late MockSummaryHomeCubit mockSummaryHomeCubit;

  final testCategories = [
    const Category(
      id: '1',
      name: 'FEEDING',
      icon: 'pizza',
      color: '#FF0000',
      type: CategoryType.expense,
    ),
    const Category(
      id: '2',
      name: 'SALARY',
      icon: 'money',
      color: '#00FF00',
      type: CategoryType.income,
    ),
  ];

  setUpAll(() {
    registerFallbackValue(DateTime.now());
    registerFallbackValue(ResumeItemType.income);
  });

  setUp(() async {
    mockDatabaseService = MockDatabaseService();
    mockRemoteConfigService = MockRemoteConfigService();
    when(() => mockRemoteConfigService.paginationLimit).thenReturn(10);
    when(() => mockRemoteConfigService.summaryLastMonths).thenReturn(4);
    mockAuthService = MockAuthService();
    mockAppCubit = MockAppCubit();
    mockSummaryHomeCubit = MockSummaryHomeCubit();
    when(
      () => mockAuthService.currentUser,
    ).thenReturn(const AppUser(uid: 'user123'));

    when(() => mockAppCubit.state).thenReturn(const AppState());

    if (getIt.isRegistered<DatabaseService>()) {
      await getIt.unregister<DatabaseService>();
    }
    if (getIt.isRegistered<RemoteConfigService>()) {
      getIt.unregister<RemoteConfigService>();
    }
    if (getIt.isRegistered<AuthService>()) {
      getIt.unregister<AuthService>();
    }

    getIt
      ..registerSingleton<DatabaseService>(mockDatabaseService)
      ..registerSingleton<RemoteConfigService>(mockRemoteConfigService)
      ..registerSingleton<AuthService>(mockAuthService);
  });

  tearDown(getIt.reset);

  group('SummaryHomePage', () {
    Widget buildPage() {
      return MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: BlocProvider<AppCubit>.value(
          value: mockAppCubit,
          child: const SummaryHomePage(),
        ),
      );
    }

    testWidgets('renders CircularProgressIndicator when loading categories', (
      tester,
    ) async {
      when(
        () => mockDatabaseService.getCategoriesStream(),
      ).thenAnswer((_) => const Stream.empty());

      await tester.pumpWidget(buildPage());

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('renders error message when category stream fails', (
      tester,
    ) async {
      when(
        () => mockDatabaseService.getCategoriesStream(),
      ).thenAnswer((_) => Stream.error('Error'));

      await tester.pumpWidget(buildPage());
      await tester.pump();

      expect(find.text('Error loading categories'), findsOneWidget);
    });

    testWidgets('renders no categories found message when list is empty', (
      tester,
    ) async {
      when(
        () => mockDatabaseService.getCategoriesStream(),
      ).thenAnswer((_) => Stream.value([]));

      await tester.pumpWidget(buildPage());
      await tester.pump();

      expect(find.text('No categories found'), findsOneWidget);
    });

    testWidgets('renders SummaryHomeView when categories are loaded', (
      tester,
    ) async {
      when(
        () => mockDatabaseService.getCategoriesStream(),
      ).thenAnswer((_) => Stream.value(testCategories));
      when(
        () => mockDatabaseService.getMovementsStream(
          userId: any(named: 'userId'),
          startDate: any(named: 'startDate'),
          endDate: any(named: 'endDate'),
          type: any(named: 'type'),
          categoryId: any(named: 'categoryId'),
          limit: any(named: 'limit'),
          orderByDate: any(named: 'orderByDate'),
        ),
      ).thenAnswer((_) => Stream.value([]));

      await tester.pumpWidget(buildPage());
      await tester.pumpAndSettle();

      expect(find.byType(SummaryHomeView), findsOneWidget);
    });
  });

  group('SummaryHomeView', () {
    late SummaryHomeState initialState;

    setUp(() {
      initialState = SummaryHomeState.initial();
    });

    Widget buildView({
      List<Category>? categories,
      SummaryHomeState? state,
      Size size = const Size(400, 800),
    }) {
      when(() => mockSummaryHomeCubit.state).thenReturn(state ?? initialState);
      return MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: MediaQuery(
          data: MediaQueryData(
            size: size,
            textScaler: const TextScaler.linear(0.8),
          ),
          child: MultiBlocProvider(
            providers: [
              BlocProvider<AppCubit>.value(value: mockAppCubit),
              BlocProvider<SummaryHomeCubit>.value(value: mockSummaryHomeCubit),
            ],
            child: Scaffold(
              body: SummaryHomeView(categories: categories ?? testCategories),
            ),
          ),
        ),
      );
    }

    testWidgets('renders CircularProgressIndicator when loading movements', (
      tester,
    ) async {
      when(
        () => mockDatabaseService.getMovementsStream(
          userId: any(named: 'userId'),
          startDate: any(named: 'startDate'),
          endDate: any(named: 'endDate'),
          type: any(named: 'type'),
          categoryId: any(named: 'categoryId'),
          limit: any(named: 'limit'),
          orderByDate: any(named: 'orderByDate'),
        ),
      ).thenAnswer((_) => const Stream.empty());

      await tester.pumpWidget(buildView());

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('renders no movements message when list is empty', (
      tester,
    ) async {
      when(
        () => mockDatabaseService.getMovementsStream(
          userId: any(named: 'userId'),
          startDate: any(named: 'startDate'),
          endDate: any(named: 'endDate'),
          type: any(named: 'type'),
          categoryId: any(named: 'categoryId'),
          limit: any(named: 'limit'),
          orderByDate: any(named: 'orderByDate'),
        ),
      ).thenAnswer((_) => Stream.value([]));

      await tester.pumpWidget(buildView());
      await tester.pumpAndSettle();

      expect(find.text('No movements registered'), findsOneWidget);
    });

    testWidgets('renders components correctly in portrait mode', (
      tester,
    ) async {
      final movements = <Movement>[
        Movement(
          id: '1',
          title: 'Lunch',
          description: 'Subway',
          price: 15,
          date: DateTime.now(),
          category: testCategories.first,
          user: 'user123',
        ),
      ];

      when(
        () => mockDatabaseService.getMovementsStream(
          userId: any(named: 'userId'),
          startDate: any(named: 'startDate'),
          endDate: any(named: 'endDate'),
          type: any(named: 'type'),
          categoryId: any(named: 'categoryId'),
          limit: any(named: 'limit'),
          orderByDate: any(named: 'orderByDate'),
        ),
      ).thenAnswer((_) => Stream.value(movements));

      await tester.pumpWidget(buildView());
      await tester.pumpAndSettle();

      expect(find.byType(MonthRangeSelector), findsOneWidget);
      expect(find.byType(ResumeMovementsChart), findsOneWidget);
      expect(find.byType(IncomesAndExpensesChart), findsOneWidget);
      expect(find.byType(CategoriesResumeCards), findsOneWidget);
    });

    testWidgets('renders components correctly in landscape mode', (
      tester,
    ) async {
      final movements = <Movement>[
        Movement(
          id: '1',
          title: 'Lunch',
          description: 'Subway',
          price: 15,
          date: DateTime.now(),
          category: testCategories.first,
          user: 'user123',
        ),
      ];

      when(
        () => mockDatabaseService.getMovementsStream(
          userId: any(named: 'userId'),
          startDate: any(named: 'startDate'),
          endDate: any(named: 'endDate'),
          type: any(named: 'type'),
          categoryId: any(named: 'categoryId'),
          limit: any(named: 'limit'),
          orderByDate: any(named: 'orderByDate'),
        ),
      ).thenAnswer((_) => Stream.value(movements));

      await tester.pumpWidget(buildView(size: const Size(800, 400)));
      await tester.pumpAndSettle();

      expect(find.byType(MonthRangeSelector), findsOneWidget);
      expect(find.byType(ResumeMovementsChart), findsOneWidget);
      expect(find.byType(IncomesAndExpensesChart), findsOneWidget);
      expect(find.byType(CategoriesResumeCards), findsOneWidget);
    });

    testWidgets('can toggle resume items', (tester) async {
      final movements = <Movement>[
        Movement(
          id: '1',
          title: 'Lunch',
          description: 'Subway',
          price: 15,
          date: DateTime.now(),
          category: testCategories.first,
          user: 'user123',
        ),
      ];

      when(
        () => mockDatabaseService.getMovementsStream(
          userId: any(named: 'userId'),
          startDate: any(named: 'startDate'),
          endDate: any(named: 'endDate'),
          type: any(named: 'type'),
          categoryId: any(named: 'categoryId'),
          limit: any(named: 'limit'),
          orderByDate: any(named: 'orderByDate'),
        ),
      ).thenAnswer((_) => Stream.value(movements));

      await tester.pumpWidget(buildView());
      await tester.pumpAndSettle();

      final incomeCard = find.descendant(
        of: find.byType(ResumeMovementsChart),
        matching: find.byType(ResumeItemCardMovements).first,
      );

      await tester.tap(incomeCard);
      await tester.pumpAndSettle();

      verify(() => mockSummaryHomeCubit.toggleResumeItem(any())).called(1);
    });

    testWidgets('can change month range', (tester) async {
      final movements = <Movement>[
        Movement(
          id: '1',
          title: 'Lunch',
          description: 'Subway',
          price: 15,
          date: DateTime.now(),
          category: testCategories.first,
          user: 'user123',
        ),
      ];

      when(
        () => mockDatabaseService.getMovementsStream(
          userId: any(named: 'userId'),
          startDate: any(named: 'startDate'),
          endDate: any(named: 'endDate'),
          type: any(named: 'type'),
          categoryId: any(named: 'categoryId'),
          limit: any(named: 'limit'),
          orderByDate: any(named: 'orderByDate'),
        ),
      ).thenAnswer((_) => Stream.value(movements));

      await tester.pumpWidget(buildView());
      await tester.pumpAndSettle();

      final calendarButton = find
          .descendant(
            of: find.byType(MonthRangeSelector),
            matching: find.byType(IconButton),
          )
          .first;

      await tester.tap(calendarButton);
      await tester.pumpAndSettle();

      expect(find.byType(MonthPickerDialog), findsOneWidget);
    });

    testWidgets(
      'switches between Expense and Income in CategoriesResumeCards',
      (tester) async {
        final movements = <Movement>[
          Movement(
            id: '1',
            title: 'Lunch',
            description: 'Subway',
            price: 15,
            date: DateTime.now(),
            category: testCategories.first,
            user: 'user123',
          ),
          Movement(
            id: '2',
            title: 'Salary',
            description: 'Company',
            price: 1000,
            date: DateTime.now(),
            category: testCategories.last,
            user: 'user123',
          ),
        ];

        when(
          () => mockDatabaseService.getMovementsStream(
            userId: any(named: 'userId'),
            startDate: any(named: 'startDate'),
            endDate: any(named: 'endDate'),
            type: any(named: 'type'),
            categoryId: any(named: 'categoryId'),
            limit: any(named: 'limit'),
            orderByDate: any(named: 'orderByDate'),
          ),
        ).thenAnswer((_) => Stream.value(movements));

        await tester.pumpWidget(buildView());
        await tester.pumpAndSettle();

        final segmentedButton = find.byType(SegmentedButton<CategoryType>);
        expect(segmentedButton, findsOneWidget);

        await tester.tap(
          find.descendant(
            of: segmentedButton,
            matching: find.byWidgetPredicate(
              (widget) =>
                  widget is HugeIcon &&
                  widget.icon == HugeIcons.strokeRoundedMoneyAdd01,
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text('Salary'), findsOneWidget);
      },
    );
  });
}
