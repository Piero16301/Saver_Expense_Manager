import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';
import 'package:saver_expense_manager/app/app.dart';
import 'package:saver_expense_manager/l10n/l10n.dart';
import 'package:saver_expense_manager/register/register.dart';

class MockRegisterCubit extends MockCubit<RegisterState>
    implements RegisterCubit {}

class MockAppCubit extends MockCubit<AppState> implements AppCubit {}

class MockAppLocalizations extends Mock implements AppLocalizations {}

void main() {
  late MockRegisterCubit mockRegisterCubit;
  late MockAppCubit mockAppCubit;

  setUpAll(() {
    registerFallbackValue(const RegisterState());
    registerFallbackValue(const AppState());
    registerFallbackValue(ThemeMode.light);
    registerFallbackValue(MockAppLocalizations());
  });

  setUp(() {
    mockRegisterCubit = MockRegisterCubit();
    mockAppCubit = MockAppCubit();

    when(() => mockRegisterCubit.state).thenReturn(const RegisterState());
    when(
      () => mockRegisterCubit.stream,
    ).thenAnswer((_) => const Stream.empty());
    when(() => mockRegisterCubit.register(any())).thenAnswer((_) async {});
    when(() => mockRegisterCubit.togglePasswordVisibility()).thenReturn(null);
    when(
      () => mockRegisterCubit.toggleConfirmPasswordVisibility(),
    ).thenReturn(null);

    when(() => mockAppCubit.state).thenReturn(const AppState());
    when(() => mockAppCubit.stream).thenAnswer((_) => const Stream.empty());
  });

  Widget buildView({GoRouter? router}) {
    final defaultRouter = GoRouter(
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => MultiBlocProvider(
            providers: [
              BlocProvider<AppCubit>.value(value: mockAppCubit),
              BlocProvider<RegisterCubit>.value(value: mockRegisterCubit),
            ],
            child: const RegisterView(),
          ),
        ),
        GoRoute(
          name: AppRoute.login.name,
          path: AppRoute.login.path,
          builder: (context, state) => const Scaffold(body: Text('Login Page')),
        ),
      ],
    );

    return MaterialApp.router(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      routerConfig: router ?? defaultRouter,
    );
  }

  group('RegisterView', () {
    testWidgets('renders all initial widgets', (tester) async {
      await tester.pumpWidget(buildView());
      await tester.pumpAndSettle();

      final l10n = await AppLocalizations.delegate.load(const Locale('en'));

      expect(find.byType(AppLogo), findsOneWidget);
      expect(find.text(l10n.registerTitle), findsOneWidget);
      expect(find.text(l10n.nameLabel), findsOneWidget);
      expect(find.text(l10n.emailLabel), findsOneWidget);
      expect(find.text(l10n.passwordLabel), findsOneWidget);
      expect(find.text(l10n.confirmPasswordLabel), findsOneWidget);
      expect(find.byType(AppFilledButton), findsOneWidget);
      expect(find.text(l10n.registerButton), findsWidgets);
      expect(find.text(l10n.haveAccount), findsOneWidget);
      expect(find.text(l10n.loginButton), findsOneWidget);
    });

    testWidgets('calls nameChanged when typing in name field', (tester) async {
      await tester.pumpWidget(buildView());
      await tester.pumpAndSettle();

      final field = find.widgetWithText(
        AppTextField,
        (await AppLocalizations.delegate.load(const Locale('en'))).nameLabel,
      );
      await tester.enterText(
        find.descendant(of: field, matching: find.byType(TextField)),
        'John Doe',
      );
      verify(() => mockRegisterCubit.nameChanged('John Doe')).called(1);
    });

    testWidgets('calls emailChanged when typing in email field', (
      tester,
    ) async {
      await tester.pumpWidget(buildView());
      await tester.pumpAndSettle();

      final field = find.widgetWithText(
        AppTextField,
        (await AppLocalizations.delegate.load(const Locale('en'))).emailLabel,
      );
      await tester.enterText(
        find.descendant(of: field, matching: find.byType(TextField)),
        'test@example.com',
      );
      verify(
        () => mockRegisterCubit.emailChanged('test@example.com'),
      ).called(1);
    });

    testWidgets('calls passwordChanged when typing in password field', (
      tester,
    ) async {
      await tester.pumpWidget(buildView());
      await tester.pumpAndSettle();

      final field = find.widgetWithText(
        AppTextField,
        (await AppLocalizations.delegate.load(
          const Locale('en'),
        ))
            .passwordLabel,
      );
      await tester.enterText(
        find.descendant(of: field, matching: find.byType(TextField)),
        'password123',
      );
      verify(() => mockRegisterCubit.passwordChanged('password123')).called(1);
    });

    testWidgets(
      'calls confirmPasswordChanged when typing in confirm password field',
      (tester) async {
        await tester.pumpWidget(buildView());
        await tester.pumpAndSettle();

        final l10n = await AppLocalizations.delegate.load(const Locale('en'));
        final field = find.widgetWithText(
          AppTextField,
          l10n.confirmPasswordLabel,
        );
        await tester.ensureVisible(field);
        await tester.enterText(
          find.descendant(of: field, matching: find.byType(TextField)),
          'password123',
        );
        verify(
          () => mockRegisterCubit.confirmPasswordChanged('password123'),
        ).called(1);
      },
    );

    testWidgets(
      'calls togglePasswordVisibility when tapping password suffix icon',
      (tester) async {
        await tester.pumpWidget(buildView());
        await tester.pumpAndSettle();

        final l10n = await AppLocalizations.delegate.load(const Locale('en'));
        final field = find.widgetWithText(AppTextField, l10n.passwordLabel);
        await tester.tap(
          find.descendant(of: field, matching: find.byType(IconButton)),
        );
        verify(() => mockRegisterCubit.togglePasswordVisibility()).called(1);
      },
    );

    testWidgets(
      'calls toggleConfirmPasswordVisibility when tapping confirm password '
      'suffix icon',
      (tester) async {
        await tester.pumpWidget(buildView());
        await tester.pumpAndSettle();

        final l10n = await AppLocalizations.delegate.load(const Locale('en'));
        final field = find.widgetWithText(
          AppTextField,
          l10n.confirmPasswordLabel,
        );
        await tester.ensureVisible(field);
        await tester.tap(
          find.descendant(of: field, matching: find.byType(IconButton)),
        );
        verify(
          () => mockRegisterCubit.toggleConfirmPasswordVisibility(),
        ).called(1);
      },
    );

    testWidgets('calls register when pressing register button', (tester) async {
      await tester.pumpWidget(buildView());
      await tester.pumpAndSettle();

      final button = find.byType(AppFilledButton);
      await tester.ensureVisible(button);
      await tester.tap(button);
      verify(() => mockRegisterCubit.register(any())).called(1);
    });

    testWidgets('renders loading state correctly', (tester) async {
      final l10n = await AppLocalizations.delegate.load(const Locale('en'));
      when(
        () => mockRegisterCubit.state,
      ).thenReturn(const RegisterState(status: RegisterStatus.loading));

      await tester.pumpWidget(buildView());
      await tester.pump();

      expect(find.text(l10n.loading), findsOneWidget);
    });

    testWidgets('shows error snackbar on failure status', (tester) async {
      final stateController = StreamController<RegisterState>();
      whenListen(
        mockRegisterCubit,
        stateController.stream,
        initialState: const RegisterState(),
      );

      await tester.pumpWidget(buildView());

      stateController.add(
        const RegisterState(
          status: RegisterStatus.failure,
          errorMessage: 'Registration failed',
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      expect(find.text('Registration failed'), findsWidgets);
      await stateController.close();
    });

    testWidgets('shows success snackbar on success status', (tester) async {
      final l10n = await AppLocalizations.delegate.load(const Locale('en'));
      final stateController = StreamController<RegisterState>();
      whenListen(
        mockRegisterCubit,
        stateController.stream,
        initialState: const RegisterState(),
      );

      await tester.pumpWidget(buildView());

      stateController.add(const RegisterState(status: RegisterStatus.success));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      expect(find.text(l10n.registerSuccess), findsWidgets);
      await stateController.close();
    });

    testWidgets('navigates to LoginPage when tapping login button', (
      tester,
    ) async {
      final l10n = await AppLocalizations.delegate.load(const Locale('en'));
      await tester.pumpWidget(buildView());
      await tester.pumpAndSettle();

      final loginButton = find.widgetWithText(TextButton, l10n.loginButton);
      expect(loginButton, findsOneWidget);

      await tester.ensureVisible(loginButton);
      await tester.tap(loginButton);
      await tester.pumpAndSettle();

      expect(find.text('Login Page'), findsOneWidget);
    });
  });
}
