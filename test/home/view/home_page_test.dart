import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:network_image_mock/network_image_mock.dart';
import 'package:saver_expense_manager/app/app.dart';
import 'package:saver_expense_manager/home/home.dart';

import '../../helpers/helpers.dart';

class MockDatabaseService extends Mock implements DatabaseService {}

class MockAuthenticationService extends Mock implements AuthenticationService {}

class MockRemoteConfigService extends Mock implements RemoteConfigService {}

class MockAppUser extends Mock implements AppUser {}

class MockAppCubit extends MockCubit<AppState> implements AppCubit {}

void main() {
  late MockDatabaseService mockDatabaseService;
  late MockAuthenticationService mockAuthService;
  late MockRemoteConfigService mockRemoteConfigService;
  late MockAppUser mockAppUser;
  late MockAppCubit mockAppCubit;

  setUpAll(() {
    registerFallbackValue(DateTime.now());
    registerFallbackValue(CategoryType.expense);
  });

  setUp(() {
    mockDatabaseService = MockDatabaseService();
    mockAuthService = MockAuthenticationService();
    mockRemoteConfigService = MockRemoteConfigService();
    mockAppUser = MockAppUser();
    mockAppCubit = MockAppCubit();

    getIt
      ..registerSingleton<DatabaseService>(mockDatabaseService)
      ..registerSingleton<AuthenticationService>(mockAuthService)
      ..registerSingleton<RemoteConfigService>(mockRemoteConfigService);

    when(() => mockAuthService.authStateChanges)
        .thenAnswer((_) => Stream.value(mockAppUser));
    when(() => mockAuthService.currentUser).thenReturn(mockAppUser);
    when(() => mockAppUser.photoURL).thenReturn(null);
    when(() => mockAppUser.uid).thenReturn('user123');
    when(() => mockRemoteConfigService.homeInitialTab).thenReturn('EXPENSES');
    when(() => mockAppCubit.state).thenReturn(const AppState());

    when(
      () => mockDatabaseService.getMonthMovementsStream(
        userId: any(named: 'userId'),
        monthSelected: any(named: 'monthSelected'),
        type: any(named: 'type'),
      ),
    ).thenAnswer((_) => Stream.value([]));
  });

  tearDown(getIt.reset);

  Widget buildSubject(Widget child) {
    return BlocProvider<AppCubit>.value(
      value: mockAppCubit,
      child: child,
    );
  }

  group('HomePage', () {
    testWidgets('renders CircularProgressIndicator when loading categories',
        (tester) async {
      when(() => mockDatabaseService.getCategoriesStream())
          .thenAnswer((_) => const Stream.empty());

      await tester.pumpApp(buildSubject(const HomePage()));

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('renders no categories found message when list is empty',
        (tester) async {
      when(() => mockDatabaseService.getCategoriesStream())
          .thenAnswer((_) => Stream.value([]));

      await tester.pumpApp(buildSubject(const HomePage()));
      await tester.pump();

      expect(find.text('No categories found'), findsOneWidget);
    });

    testWidgets('renders HomeView when categories are loaded', (tester) async {
      final categories = [
        const Category(
          id: '1',
          name: 'Food',
          type: CategoryType.expense,
          icon: '',
          color: '#FF0000',
        ),
      ];
      when(() => mockDatabaseService.getCategoriesStream())
          .thenAnswer((_) => Stream<List<Category>>.value(categories));

      await mockNetworkImagesFor(() async {
        await tester.pumpApp(buildSubject(const HomePage()));
        await tester.pumpAndSettle();

        expect(find.byType(HomeView), findsOneWidget);
      });
    });
  });
}
