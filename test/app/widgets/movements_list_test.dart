import 'package:bloc_test/bloc_test.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';
import 'package:saver_expense_manager/app/app.dart';
import 'package:saver_expense_manager/l10n/l10n.dart';

class MockAppCubit extends MockCubit<AppState> implements AppCubit {}

class MockAuthService extends Mock implements AuthService {}

class MockDatabaseService extends Mock implements DatabaseService {}

class MockRemoteConfigService extends Mock implements RemoteConfigService {}

void main() {
  group('MovementsList', () {
    late AppCubit appCubit;
    late AuthService mockAuth;
    late DatabaseService mockDatabase;
    late MockRemoteConfigService mockRemoteConfig;
    late FakeFirebaseFirestore fakeFirestore;
    late Query<Map<String, dynamic>> query;

    const testCategory = Category(
      id: '1',
      name: 'FOOD',
      color: '#FF0000',
      icon: 'food',
      type: CategoryType.expense,
    );

    setUpAll(() {
      registerFallbackValue(DateTime.now());
      registerFallbackValue(testCategory);
    });

    setUp(() async {
      appCubit = MockAppCubit();
      mockAuth = MockAuthService();
      mockDatabase = MockDatabaseService();
      mockRemoteConfig = MockRemoteConfigService();
      fakeFirestore = FakeFirebaseFirestore();

      query = fakeFirestore
          .collection(AppVariables.movementsCollection)
          .where('user', isEqualTo: 'user1');

      when(() => appCubit.state).thenReturn(const AppState());

      final getIt = GetIt.instance;
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
      ).thenAnswer(
        (_) => query.snapshots().map(
              (snapshot) => snapshot.docs
                  .map((doc) => Movement.fromJson(doc.data()))
                  .toList(),
            ),
      );
    });

    Widget createWidgetUnderTest({DateTime? monthSelected}) {
      final router = GoRouter(
        routes: [
          GoRoute(
            path: '/',
            builder: (context, state) => BlocProvider.value(
              value: appCubit,
              child: Scaffold(
                body: Column(
                  children: [
                    MovementsList(
                      filterCategory: testCategory,
                      monthSelected: monthSelected ?? DateTime(2024, 3),
                    ),
                  ],
                ),
              ),
            ),
          ),
          GoRoute(
            name: AppRoute.movement.name,
            path: '/movement/:type/:screenType',
            builder: (context, state) =>
                const Scaffold(body: Text('Movement Page')),
          ),
        ],
      );

      return MaterialApp.router(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        routerConfig: router,
      );
    }

    testWidgets('renders normally and shows empty message', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      expect(find.byType(MovementsList), findsOneWidget);
      expect(find.text('No elements registered'), findsOneWidget);
    });

    testWidgets('renders list items and triggers navigation', (tester) async {
      final date = DateTime(2024, 3, 15);
      final movement = Movement(
        id: 'm1',
        title: 'Lunch',
        description: 'Healthy lunch',
        price: 15.5,
        date: date,
        category: testCategory,
        user: 'user1',
      );

      await fakeFirestore
          .collection(AppVariables.movementsCollection)
          .add(movement.toJson());

      await tester.pumpWidget(createWidgetUnderTest(monthSelected: date));
      await tester.pumpAndSettle();

      expect(find.text('Lunch'), findsOneWidget);
      expect(find.text('Healthy lunch'), findsOneWidget);
      expect(find.textContaining('15.5'), findsOneWidget);

      await tester.tap(find.text('Lunch'));
      await tester.pumpAndSettle();

      expect(find.text('Movement Page'), findsOneWidget);
    });
  });
}
