import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:network_image_mock/network_image_mock.dart';
import 'package:saver_expense_manager/app/app.dart';
import 'package:saver_expense_manager/home/home.dart';

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

    when(() => mockRemoteConfigService.isHomeSummaryCardsVisible)
        .thenReturn(false);
    when(() => mockRemoteConfigService.isHomeTopCategoriesVisible)
        .thenReturn(false);
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

    testWidgets('renders properly in landscape mode', (tester) async {
      tester.view.physicalSize = const Size(800, 400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await mockNetworkImagesFor(() async {
        await tester.pumpApp(buildSubject());
        await tester.pumpAndSettle();

        expect(find.byType(NavigationRailHome), findsOneWidget);
        expect(find.byType(FloatingActionButton), findsOneWidget);
      });
    });

    testWidgets('renders correct body based on selected index', (tester) async {
      tester.view.physicalSize = const Size(400, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      when(() => mockHomeCubit.state)
          .thenReturn(const HomeState(selectedIndex: 1));

      await mockNetworkImagesFor(() async {
        await tester.pumpApp(buildSubject());
        await tester.pumpAndSettle();

        expect(find.byType(FloatingActionButton), findsNothing);
      });
    });
  });
}
