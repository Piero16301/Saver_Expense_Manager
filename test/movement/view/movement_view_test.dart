import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:mocktail/mocktail.dart';
import 'package:saver_expense_manager/app/app.dart';
import 'package:saver_expense_manager/l10n/l10n.dart';
import 'package:saver_expense_manager/movement/movement.dart';

class MockMovementCubit extends MockCubit<MovementState>
    implements MovementCubit {}

class MockAuthService extends Mock implements AuthService {}

class MockAppUser extends Mock implements AppUser {}

class MockAppCubit extends MockCubit<AppState> implements AppCubit {}

class FakeAppLocalizations extends Fake implements AppLocalizations {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('MovementView', () {
    late MovementCubit movementCubit;
    late AuthService authenticationService;
    late AppUser user;
    late AppCubit appCubit;

    const category = Category(
      id: '1',
      name: 'Food',
      icon: 'food',
      color: 'red',
      type: CategoryType.expense,
    );

    final initialState = MovementState(
      id: '1',
      title: 'Title',
      description: 'Description',
      date: DateTime.now(),
      categories: const [category],
      category: category,
      price: 10,
      company: 'Company',
      formKey: GlobalKey<FormState>(),
    );

    setUpAll(() {
      registerFallbackValue(const MovementState());
      registerFallbackValue(const AppState());
      registerFallbackValue(FakeAppLocalizations());
    });

    setUp(() async {
      movementCubit = MockMovementCubit();
      authenticationService = MockAuthService();
      user = MockAppUser();
      appCubit = MockAppCubit();

      when(() => user.uid).thenReturn('uid');
      when(() => authenticationService.currentUser).thenReturn(user);
      when(() => appCubit.state).thenReturn(const AppState());

      if (getIt.isRegistered<AuthService>()) {
        await getIt.unregister<AuthService>();
      }
      getIt.registerSingleton<AuthService>(authenticationService);

      when(() => movementCubit.state).thenReturn(initialState);
    });

    Widget buildSubject({
      CategoryType type = CategoryType.expense,
      MovementScreenType screenType = MovementScreenType.add,
    }) {
      return MultiBlocProvider(
        providers: [
          BlocProvider.value(value: appCubit),
          BlocProvider.value(value: movementCubit),
        ],
        child: MovementView(type: type, screenType: screenType),
      );
    }

    Future<void> pumpMovementView(
      WidgetTester tester, {
      CategoryType type = CategoryType.expense,
      MovementScreenType screenType = MovementScreenType.add,
    }) async {
      final router = GoRouter(
        initialLocation: '/movement',
        routes: [
          GoRoute(
            path: '/',
            builder: (context, state) => const Scaffold(body: Text('Home')),
            routes: [
              GoRoute(
                path: 'movement',
                builder: (context, state) =>
                    buildSubject(type: type, screenType: screenType),
              ),
            ],
          ),
        ],
      );

      await tester.pumpWidget(
        MaterialApp.router(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          routerConfig: router,
        ),
      );
      await tester.pumpAndSettle();
    }

    testWidgets('renders correct UI elements', (tester) async {
      await pumpMovementView(tester);

      expect(find.text('Title').first, findsOneWidget);
      expect(find.text('Description').first, findsOneWidget);
      expect(find.text('10.00'), findsOneWidget);
      expect(find.text('Company').first, findsOneWidget);
    });

    testWidgets('calls titleChanged when title changes', (tester) async {
      await pumpMovementView(tester);
      await tester.enterText(find.byType(AppTextField).first, 'New Title');
      verify(() => movementCubit.titleChanged('New Title')).called(1);
    });

    testWidgets('calls saveMovement when FAB is pressed', (tester) async {
      when(
        () => movementCubit.saveMovement(any(), any()),
      ).thenAnswer((_) async => true);

      await pumpMovementView(tester);
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();

      verify(() => movementCubit.saveMovement('uid', any())).called(1);
      expect(find.text('Home'), findsOneWidget);
    });

    testWidgets(
      'shows delete dialog and calls removeMovement when delete button '
      'is pressed',
      (tester) async {
        when(
          () => movementCubit.removeMovement(),
        ).thenAnswer((_) async => true);

        await pumpMovementView(tester, screenType: MovementScreenType.edit);

        final deleteButton = find.byWidgetPredicate(
          (widget) =>
              widget is HugeIcon &&
              widget.icon == HugeIcons.strokeRoundedDelete02,
        );
        expect(deleteButton, findsOneWidget);

        await tester.tap(deleteButton);
        await tester.pumpAndSettle();

        expect(find.byType(AppAlertDialog), findsOneWidget);

        await tester.tap(find.text('Delete'));
        await tester.pumpAndSettle();

        verify(() => movementCubit.removeMovement()).called(1);
        expect(find.text('Home'), findsOneWidget);
      },
    );

    testWidgets('renders MovementMetadata in debug mode', (tester) async {
      await pumpMovementView(tester);
      expect(find.byType(MovementMetadata), findsOneWidget);
    });

    testWidgets('shows warning dialog when date is old and cancels save',
        (tester) async {
      final oldDateState = MovementState(
        id: '1',
        title: 'Title',
        description: 'Description',
        date: DateTime.now().subtract(const Duration(days: 40)),
        categories: const [category],
        category: category,
        price: 10,
        company: 'Company',
        formKey: GlobalKey<FormState>(),
      );
      when(() => movementCubit.state).thenReturn(oldDateState);

      await pumpMovementView(tester);
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();

      expect(find.byType(AppAlertDialog), findsOneWidget);

      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      verifyNever(() => movementCubit.saveMovement(any(), any()));
    });

    testWidgets('shows warning dialog when date is old and confirms save',
        (tester) async {
      when(() => movementCubit.saveMovement(any(), any()))
          .thenAnswer((_) async => true);
      final oldDateState = MovementState(
        id: '1',
        title: 'Title',
        description: 'Description',
        date: DateTime.now().subtract(const Duration(days: 40)),
        categories: const [category],
        category: category,
        price: 10,
        company: 'Company',
        formKey: GlobalKey<FormState>(),
      );
      when(() => movementCubit.state).thenReturn(oldDateState);

      await pumpMovementView(tester);
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();

      expect(find.byType(AppAlertDialog), findsOneWidget);

      await tester.tap(find.text('Confirm'));
      await tester.pumpAndSettle();

      verify(() => movementCubit.saveMovement('uid', any())).called(1);
    });

    testWidgets('cancels delete movement when cancel button is pressed',
        (tester) async {
      await pumpMovementView(tester, screenType: MovementScreenType.edit);

      final deleteButton = find.byWidgetPredicate(
        (widget) =>
            widget is HugeIcon &&
            widget.icon == HugeIcons.strokeRoundedDelete02,
      );
      expect(deleteButton, findsOneWidget);

      await tester.tap(deleteButton);
      await tester.pumpAndSettle();

      expect(find.byType(AppAlertDialog), findsOneWidget);

      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      verifyNever(() => movementCubit.removeMovement());
    });
  });
}
