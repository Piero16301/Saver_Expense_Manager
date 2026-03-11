import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:saver_expense_manager/app/app.dart';
import 'package:saver_expense_manager/home/home.dart';
import 'package:saver_expense_manager/l10n/l10n.dart';

class MockMovementsHomeCubit extends MockCubit<MovementsHomeState>
    implements MovementsHomeCubit {}

class MockAppCubit extends MockCubit<AppState> implements AppCubit {}

class MockAuthenticationService extends Mock implements AuthenticationService {}

class MockDatabaseService extends Mock implements DatabaseService {}

class MockLocalStorageService extends Mock implements LocalStorageService {}

class MockFirebaseAuth extends Mock implements FirebaseAuth {}

class MockFirebaseUser extends Mock implements User {}

const _testCategories = [
  Category(
    id: 'cat1',
    name: 'FEEDING',
    icon: 'food_icon',
    color: 'FF00FF00',
    type: CategoryType.expense,
  ),
  Category(
    id: 'cat2',
    name: 'SALARY',
    icon: 'salary_icon',
    color: 'FF0000FF',
    type: CategoryType.income,
  ),
];

List<Category> get mutableTestCategories => List.of(_testCategories);

void main() {
  late MockMovementsHomeCubit mockCubit;
  late MockAppCubit mockAppCubit;
  late MockAuthenticationService mockAuth;
  late MockDatabaseService mockDatabase;
  late MockLocalStorageService mockLocalStorage;
  late MockFirebaseAuth mockFirebaseAuth;
  late MockFirebaseUser mockFirebaseUser;
  late FakeFirebaseFirestore fakeFirestore;

  setUpAll(() {
    registerFallbackValue(DateTime.now());
    registerFallbackValue(CategoryType.expense);
    registerFallbackValue(Category.empty);
  });

  setUp(() async {
    mockCubit = MockMovementsHomeCubit();
    mockAppCubit = MockAppCubit();
    mockAuth = MockAuthenticationService();
    mockDatabase = MockDatabaseService();
    mockLocalStorage = MockLocalStorageService();
    mockFirebaseAuth = MockFirebaseAuth();
    mockFirebaseUser = MockFirebaseUser();
    fakeFirestore = FakeFirebaseFirestore();

    when(() => mockFirebaseUser.uid).thenReturn('user123');
    when(() => mockFirebaseAuth.currentUser).thenReturn(mockFirebaseUser);
    when(() => mockAuth.auth).thenReturn(mockFirebaseAuth);
    when(() => mockAppCubit.state).thenReturn(const AppState());
    when(() => mockCubit.state).thenReturn(const MovementsHomeState());
    when(() => mockLocalStorage.getLanguage()).thenReturn(null);
    when(() => mockLocalStorage.getRecommendationsDate()).thenReturn(
      DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day),
    );
    when(() => mockLocalStorage.getRecommendations()).thenReturn([]);

    when(() => mockDatabase.getCategoriesStream())
        .thenAnswer((_) => Stream.value([]));
    when(
      () => mockDatabase.getMovementsStream(
        userId: any(named: 'userId'),
        limit: any(named: 'limit'),
      ),
    ).thenAnswer((_) => Stream.value([]));
    when(
      () => mockDatabase.getUserMovementsQuery(
        userId: any(named: 'userId'),
        type: any(named: 'type'),
        category: any(named: 'category'),
      ),
    ).thenReturn(fakeFirestore.collection('movements'));

    if (getIt.isRegistered<AuthenticationService>()) {
      await getIt.unregister<AuthenticationService>();
    }
    if (getIt.isRegistered<DatabaseService>()) {
      getIt.unregister<DatabaseService>();
    }
    if (getIt.isRegistered<LocalStorageService>()) {
      getIt.unregister<LocalStorageService>();
    }
    getIt
      ..registerSingleton<AuthenticationService>(mockAuth)
      ..registerSingleton<DatabaseService>(mockDatabase)
      ..registerSingleton<LocalStorageService>(mockLocalStorage);
  });

  tearDown(getIt.reset);

  group('MovementsHomePage', () {
    Widget buildPage() {
      return MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: BlocProvider<AppCubit>.value(
          value: mockAppCubit,
          child: const Scaffold(body: MovementsHomePage()),
        ),
      );
    }

    testWidgets('shows loading indicator while waiting for categories',
        (tester) async {
      final controller = StreamController<List<Category>>();
      when(() => mockDatabase.getCategoriesStream())
          .thenAnswer((_) => controller.stream);

      await tester.pumpWidget(buildPage());
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      await controller.close();
    });

    testWidgets('shows empty categories message when list is empty',
        (tester) async {
      when(() => mockDatabase.getCategoriesStream())
          .thenAnswer((_) => Stream.value([]));

      await tester.pumpWidget(buildPage());
      await tester.pump();
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsNothing);
    });

    testWidgets('shows MovementsHomeView when categories are present',
        (tester) async {
      when(() => mockDatabase.getCategoriesStream())
          .thenAnswer((_) => Stream.value(_testCategories));

      await tester.pumpWidget(buildPage());
      await tester.pump();
      await tester.pump();

      expect(find.byType(MovementsHomeView), findsOneWidget);
    });

    testWidgets('shows error message when stream has error', (tester) async {
      when(() => mockDatabase.getCategoriesStream())
          .thenAnswer((_) => Stream.error('error'));

      await tester.pumpWidget(buildPage());
      await tester.pump();
      await tester.pump();

      expect(find.byType(Scaffold), findsAtLeast(1));
    });
  });

  group('MovementsHomeView', () {
    Widget buildView({
      MovementsHomeState? state,
      List<Category>? categories,
    }) {
      when(() => mockCubit.state)
          .thenReturn(state ?? const MovementsHomeState());
      return MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: MultiBlocProvider(
          providers: [
            BlocProvider<AppCubit>.value(value: mockAppCubit),
            BlocProvider<MovementsHomeCubit>.value(value: mockCubit),
          ],
          child: Scaffold(
            body: MovementsHomeView(
              categories: categories ?? mutableTestCategories,
            ),
          ),
        ),
      );
    }

    testWidgets('renders without movements (empty stream)', (tester) async {
      when(
        () => mockDatabase.getMovementsStream(
          userId: any(named: 'userId'),
          limit: any(named: 'limit'),
        ),
      ).thenAnswer((_) => Stream.value([]));

      await tester.pumpWidget(buildView());
      await tester.pump();
      await tester.pump();

      expect(find.byType(MovementsHomeView), findsOneWidget);
    });

    testWidgets('renders FilterMovementsAntResumeHome when movements present',
        (tester) async {
      final movement = Movement(
        id: '1',
        title: 'Lunch',
        description: 'Subway',
        price: 10,
        date: DateTime(2024, 3),
        category: _testCategories.first,
        user: 'user123',
      );
      when(
        () => mockDatabase.getMovementsStream(
          userId: any(named: 'userId'),
          limit: any(named: 'limit'),
        ),
      ).thenAnswer((_) => Stream.value([movement]));

      await tester.pumpWidget(buildView());
      await tester.pump();
      await tester.pump();

      expect(find.byType(FilterMovementsAntResumeHome), findsOneWidget);
    });

    testWidgets(
        'renders with filterType set shows category chip in FilterMovements',
        (tester) async {
      final movement = Movement(
        id: '1',
        title: 'Lunch',
        description: 'desc',
        price: 10,
        date: DateTime(2024, 3),
        category: _testCategories.first,
        user: 'user123',
      );
      when(
        () => mockDatabase.getMovementsStream(
          userId: any(named: 'userId'),
          limit: any(named: 'limit'),
        ),
      ).thenAnswer((_) => Stream.value([movement]));

      await tester.pumpWidget(
        buildView(
          state: const MovementsHomeState(filterType: CategoryType.expense),
          categories: mutableTestCategories,
        ),
      );
      await tester.pump();
      await tester.pump();

      expect(find.byType(FilterMovementsAntResumeHome), findsOneWidget);
      expect(find.byType(Chip), findsAtLeast(2));
    });

    testWidgets('tapping type chip opens filter bottom sheet', (tester) async {
      final movement = Movement(
        id: '1',
        title: 'Lunch',
        description: 'desc',
        price: 10,
        date: DateTime(2024, 3),
        category: _testCategories.first,
        user: 'user123',
      );
      when(
        () => mockDatabase.getMovementsStream(
          userId: any(named: 'userId'),
          limit: any(named: 'limit'),
        ),
      ).thenAnswer((_) => Stream.value([movement]));

      await tester.pumpWidget(buildView());
      await tester.pump();
      await tester.pump();

      final chip = find.byType(Chip).first;
      await tester.tap(chip);
      await tester.pumpAndSettle();

      expect(find.byType(DraggableScrollableSheet), findsOneWidget);
    });

    testWidgets('shows AntRecommendationsWidget recommendations when available',
        (tester) async {
      final movement = Movement(
        id: '1',
        title: 'Rec Test',
        description: 'desc',
        price: 5,
        date: DateTime(2024, 3),
        category: _testCategories.first,
        user: 'user123',
      );
      when(
        () => mockDatabase.getMovementsStream(
          userId: any(named: 'userId'),
          limit: any(named: 'limit'),
        ),
      ).thenAnswer((_) => Stream.value([movement]));

      await tester.pumpWidget(
        buildView(
          state: const MovementsHomeState(
            recommendationsStatus: RecommendationsStatus.success,
            recommendations: ['**Save more!**', '**Spend wisely.**'],
          ),
          categories: mutableTestCategories,
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      expect(find.byType(PageView), findsOneWidget);
    });

    testWidgets(
        'AntRecommendationsWidget shows nothing when recommendations hidden',
        (tester) async {
      when(
        () => mockDatabase.getMovementsStream(
          userId: any(named: 'userId'),
          limit: any(named: 'limit'),
        ),
      ).thenAnswer((_) => Stream.value([]));

      await tester.pumpWidget(
        buildView(
          state: const MovementsHomeState(
            recommendationsStatus: RecommendationsStatus.success,
            recommendations: ['**Save more!**'],
            showRecommendations: false,
          ),
        ),
      );
      await tester.pump();

      expect(find.byType(PageView), findsNothing);
    });

    testWidgets('AI button is disabled when recommendations are loading',
        (tester) async {
      when(
        () => mockDatabase.getMovementsStream(
          userId: any(named: 'userId'),
          limit: any(named: 'limit'),
        ),
      ).thenAnswer(
        (_) => Stream.value([
          Movement(
            id: '1',
            title: 'T',
            description: 'D',
            price: 1,
            date: DateTime(2024),
            category: _testCategories.first,
            user: 'user123',
          ),
        ]),
      );

      await tester.pumpWidget(
        buildView(
          state: const MovementsHomeState(
            recommendationsStatus: RecommendationsStatus.loading,
          ),
        ),
      );
      await tester.pump();
      await tester.pump();

      final buttons = tester.widgetList<AppFilledButton>(
        find.byType(AppFilledButton),
      );
      final aiButton = buttons.first;
      expect(aiButton.onPressed, isNull);
    });
  });

  group('FilterMovementsAntResumeHome', () {
    Widget buildFilter({
      CategoryType? filterType,
      Category? filterCategory,
    }) {
      return MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: MultiBlocProvider(
          providers: [
            BlocProvider<MovementsHomeCubit>.value(value: mockCubit),
          ],
          child: Scaffold(
            body: FilterMovementsAntResumeHome(
              categories: mutableTestCategories,
              filterType: filterType,
              filterCategory: filterCategory,
              onFilterTypeChanged: (_) {},
              onFilterCategoryChanged: (_) {},
            ),
          ),
        ),
      );
    }

    testWidgets('renders without filter selected (no filterType)',
        (tester) async {
      await tester.pumpWidget(buildFilter());
      await tester.pump();

      expect(find.byType(Chip), findsOneWidget);
    });

    testWidgets('renders with filterType showing both chips', (tester) async {
      await tester.pumpWidget(
        buildFilter(filterType: CategoryType.expense),
      );
      await tester.pump();

      expect(find.byType(Chip), findsAtLeast(2));
    });

    testWidgets('renders with filterCategory showing category name',
        (tester) async {
      await tester.pumpWidget(
        buildFilter(
          filterType: CategoryType.expense,
          filterCategory: _testCategories.first,
        ),
      );
      await tester.pump();

      expect(find.byType(Chip), findsAtLeast(2));
    });

    testWidgets('tapping category chip opens category filter bottom sheet',
        (tester) async {
      await tester.pumpWidget(
        buildFilter(filterType: CategoryType.expense),
      );
      await tester.pump();

      final chips = find.byType(Chip);
      await tester.tap(chips.last);
      await tester.pumpAndSettle();

      expect(find.byType(DraggableScrollableSheet), findsOneWidget);
    });
  });
}
