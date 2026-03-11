import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:mocktail/mocktail.dart';
import 'package:network_image_mock/network_image_mock.dart';
import 'package:saver_expense_manager/app/app.dart';
import 'package:saver_expense_manager/home/home.dart';
import 'package:saver_expense_manager/l10n/l10n.dart';
import 'package:saver_expense_manager/movement/movement.dart';

import '../../helpers/helpers.dart';

class MockAuthenticationService extends Mock implements AuthenticationService {}

class MockAppCubit extends MockCubit<AppState> implements AppCubit {}

class MockHomeCubit extends MockCubit<HomeState> implements HomeCubit {}

class MockAppUser extends Mock implements AppUser {}

class MockDatabaseService extends Mock implements DatabaseService {}

class MockRemoteConfigService extends Mock implements RemoteConfigService {}

class MockLocalStorageService extends Mock implements LocalStorageService {}

void main() {
  late MockAuthenticationService mockAuthService;
  late MockAppCubit mockAppCubit;
  late MockHomeCubit mockHomeCubit;
  late MockAppUser mockAppUser;
  late MockDatabaseService mockDatabaseService;
  late MockRemoteConfigService mockRemoteConfigService;
  late MockLocalStorageService mockLocalStorageService;

  setUpAll(() {
    TestWidgetsFlutterBinding.ensureInitialized();
    registerFallbackValue(DateTime.now());
    registerFallbackValue(CategoryType.expense);
    AppVariables.useTestFonts = true;
  });

  setUp(() {
    mockAuthService = MockAuthenticationService();
    mockAppCubit = MockAppCubit();
    mockHomeCubit = MockHomeCubit();
    mockAppUser = MockAppUser();
    mockDatabaseService = MockDatabaseService();
    mockRemoteConfigService = MockRemoteConfigService();
    mockLocalStorageService = MockLocalStorageService();

    getIt
      ..registerSingleton<AuthenticationService>(mockAuthService)
      ..registerSingleton<DatabaseService>(mockDatabaseService)
      ..registerSingleton<RemoteConfigService>(mockRemoteConfigService)
      ..registerSingleton<LocalStorageService>(mockLocalStorageService);

    when(() => mockAppCubit.state).thenReturn(const AppState());
    when(() => mockHomeCubit.state)
        .thenReturn(const HomeState(selectedIndex: 0));

    when(() => mockAppUser.photoURL).thenReturn(null);
    when(() => mockAppUser.uid).thenReturn('user123');
    when(() => mockAuthService.authStateChanges)
        .thenAnswer((_) => Stream.value(mockAppUser));
    when(() => mockAuthService.currentUser).thenReturn(mockAppUser);

    when(() => mockDatabaseService.getCategoriesStream())
        .thenAnswer((_) => Stream.value([]));
    when(
      () => mockDatabaseService.getMonthMovementsStream(
        userId: any(named: 'userId'),
        monthSelected: any(named: 'monthSelected'),
        type: any(named: 'type'),
      ),
    ).thenAnswer((_) => Stream.value([]));
    when(
      () => mockDatabaseService.getUserMovementsRangeStream(
        userId: any(named: 'userId'),
        startMonth: any(named: 'startMonth'),
        endMonth: any(named: 'endMonth'),
      ),
    ).thenAnswer((_) => Stream.value([]));
    when(
      () => mockDatabaseService.getMovementsStream(
        userId: any(named: 'userId'),
        limit: any(named: 'limit'),
      ),
    ).thenAnswer((_) => Stream.value([]));
  });

  tearDown(getIt.reset);

  Widget buildSubject() {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AppCubit>.value(value: mockAppCubit),
        BlocProvider<HomeCubit>.value(value: mockHomeCubit),
      ],
      child: const HomeView(categories: []),
    );
  }

  group('HomeView', () {
    testWidgets('renders properly with initial state', (tester) async {
      tester.view.physicalSize = const Size(400, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await mockNetworkImagesFor(() async {
        await tester.pumpApp(buildSubject());
        await tester.pumpAndSettle();

        expect(find.byType(BottomNavigationBarHome), findsOneWidget);
        expect(find.byType(FloatingActionButton), findsOneWidget);
      });
    });

    testWidgets('renders properly with dark theme', (tester) async {
      await mockNetworkImagesFor(() async {
        await tester.pumpWidget(
          MaterialApp(
            theme: ThemeData.dark(),
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: buildSubject(),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.byType(BottomNavigationBarHome), findsOneWidget);
      });
    });

    testWidgets('renders empty SizedBox when user is null', (tester) async {
      when(() => mockAuthService.authStateChanges)
          .thenAnswer((_) => Stream.value(null));
      when(() => mockAuthService.currentUser).thenReturn(null);

      await tester.pumpApp(buildSubject());
      await tester.pump();

      expect(find.byType(Scaffold), findsNothing);
      expect(find.byType(SizedBox), findsOneWidget);
    });

    testWidgets('navigates to settings when settings icon is pressed',
        (tester) async {
      await mockNetworkImagesFor(() async {
        await tester.pumpApp(buildSubject());
        await tester.pumpAndSettle();

        final settingsButton = find.byWidgetPredicate(
          (widget) =>
              widget is HugeIcon &&
              widget.icon == HugeIcons.strokeRoundedSettings02,
        );

        expect(settingsButton, findsOneWidget);
        expect(
          tester
              .widget<IconButton>(
                find.ancestor(
                  of: settingsButton,
                  matching: find.byType(IconButton),
                ),
              )
              .onPressed,
          isNotNull,
        );
      });
    });

    testWidgets('renders user photo when photoURL is not null', (tester) async {
      when(() => mockAppUser.photoURL)
          .thenReturn('https://example.com/photo.png');

      await mockNetworkImagesFor(() async {
        await tester.pumpApp(buildSubject());
        await tester.pumpAndSettle();

        expect(find.byType(ClipRRect), findsOneWidget);
        expect(find.byType(Image), findsNWidgets(2));
      });
    });

    testWidgets('navigates to profile when profile icon is pressed',
        (tester) async {
      await mockNetworkImagesFor(() async {
        await tester.pumpApp(buildSubject());
        await tester.pumpAndSettle();

        final profileButton = find.byWidgetPredicate(
          (widget) =>
              widget is HugeIcon && widget.icon == HugeIcons.strokeRoundedUser,
        );
        expect(profileButton, findsOneWidget);

        expect(
          tester
              .widget<IconButton>(
                find.ancestor(
                  of: profileButton,
                  matching: find.byType(IconButton),
                ),
              )
              .onPressed,
          isNotNull,
        );
      });
    });

    testWidgets('toggles selected index when bottom navigation item is pressed',
        (tester) async {
      when(() => mockHomeCubit.toggleSelectedIndex(any())).thenReturn(null);

      await mockNetworkImagesFor(() async {
        await tester.pumpApp(buildSubject());
        await tester.pumpAndSettle();

        await tester.tap(find.text('Movements'));
        await tester.pump();

        verify(() => mockHomeCubit.toggleSelectedIndex(1)).called(1);
      });
    });

    testWidgets('renders Expenses tab correcty (index 0)', (tester) async {
      when(() => mockHomeCubit.state)
          .thenReturn(const HomeState(selectedIndex: 0));
      await mockNetworkImagesFor(() async {
        await tester.pumpApp(buildSubject());
        await tester.pumpAndSettle();
        expect(find.byType(ExpensesHomePage), findsOneWidget);
        expect(find.byType(FloatingActionButton), findsOneWidget);
      });
    });

    testWidgets('renders Movements tab correcty (index 1)', (tester) async {
      when(() => mockHomeCubit.state)
          .thenReturn(const HomeState(selectedIndex: 1));
      await mockNetworkImagesFor(() async {
        await tester.pumpApp(buildSubject());
        await tester.pumpAndSettle();
        expect(find.byType(MovementsHomePage), findsOneWidget);
        expect(find.byType(FloatingActionButton), findsNothing);
      });
    });

    testWidgets('renders Summary tab correcty (index 2)', (tester) async {
      when(() => mockHomeCubit.state)
          .thenReturn(const HomeState(selectedIndex: 2));
      await mockNetworkImagesFor(() async {
        await tester.pumpApp(buildSubject());
        await tester.pumpAndSettle();
        expect(find.byType(SummaryHomePage), findsOneWidget);
        expect(find.byType(FloatingActionButton), findsNothing);
      });
    });

    testWidgets('renders Income tab correcty (index 3)', (tester) async {
      when(() => mockHomeCubit.state)
          .thenReturn(const HomeState(selectedIndex: 3));
      await mockNetworkImagesFor(() async {
        await tester.pumpApp(buildSubject());
        await tester.pumpAndSettle();
        expect(find.byType(IncomeHomePage), findsOneWidget);
        expect(find.byType(FloatingActionButton), findsOneWidget);
      });
    });

    testWidgets(
        'shows AddMovementBottomSheet when FAB is pressed in Expenses tab',
        (tester) async {
      await mockNetworkImagesFor(() async {
        await tester.pumpApp(buildSubject());
        await tester.pumpAndSettle();

        await tester.tap(find.byType(FloatingActionButton));
        await tester.pumpAndSettle();

        expect(find.byType(AddMovementBottomSheet), findsOneWidget);
        expect(find.text('Add expense'), findsOneWidget);
      });
    });

    testWidgets(
        'shows AddMovementBottomSheet when FAB is pressed in Income tab',
        (tester) async {
      when(() => mockHomeCubit.state)
          .thenReturn(const HomeState(selectedIndex: 3));

      await mockNetworkImagesFor(() async {
        await tester.pumpApp(buildSubject());
        await tester.pumpAndSettle();

        await tester.tap(find.byType(FloatingActionButton));
        await tester.pumpAndSettle();

        expect(find.byType(AddMovementBottomSheet), findsOneWidget);
        expect(find.text('Add income'), findsOneWidget);

        expect(find.text('File'), findsOneWidget);
        expect(find.text('Scan'), findsOneWidget);
        expect(find.text('Enter'), findsOneWidget);
      });
    });

    testWidgets('dismisses bottom sheet and navigates when Enter is pressed',
        (tester) async {
      final router = GoRouter(
        routes: [
          GoRoute(
            path: '/',
            builder: (context, state) => buildSubject(),
          ),
          GoRoute(
            path: '/movement/:type/:screenType',
            name: MovementPage.pageName,
            builder: (context, state) =>
                const Scaffold(body: Text('Movement Page')),
          ),
        ],
      );

      await mockNetworkImagesFor(() async {
        await tester.pumpWidget(
          MaterialApp.router(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            routerConfig: router,
          ),
        );
        await tester.pumpAndSettle();

        await tester.tap(find.byType(FloatingActionButton));
        await tester.pumpAndSettle();

        expect(find.byType(AddMovementBottomSheet), findsOneWidget);

        await tester.tap(find.text('Enter'));
        await tester.pumpAndSettle();
        expect(find.text('Movement Page'), findsOneWidget);
      });
    });

    testWidgets('dismisses bottom sheet when drag handle is tapped',
        (tester) async {
      await mockNetworkImagesFor(() async {
        await tester.pumpApp(buildSubject());
        await tester.pumpAndSettle();

        await tester.tap(find.byType(FloatingActionButton));
        await tester.pumpAndSettle();

        expect(find.byType(AddMovementBottomSheet), findsOneWidget);

        final dragHandle = find.byWidgetPredicate(
          (widget) =>
              widget is Container &&
              widget.constraints?.minWidth == 40 &&
              widget.constraints?.minHeight == 5,
        );

        await tester.tap(dragHandle);
        await tester.pumpAndSettle();

        expect(find.byType(AddMovementBottomSheet), findsNothing);
      });
    });
  });
}
