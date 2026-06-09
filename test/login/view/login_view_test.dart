import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:mocktail/mocktail.dart';
import 'package:saver_expense_manager/app/app.dart';
import 'package:saver_expense_manager/l10n/l10n.dart';
import 'package:saver_expense_manager/login/login.dart';

class MockLoginCubit extends MockCubit<LoginState> implements LoginCubit {}

class MockAppCubit extends MockCubit<AppState> implements AppCubit {}

class MockAppLocalizations extends Mock implements AppLocalizations {}

void main() {
  late MockLoginCubit mockLoginCubit;
  late MockAppCubit mockAppCubit;

  setUpAll(() async {
    registerFallbackValue(const LoginState());
    registerFallbackValue(const AppState());
    registerFallbackValue(ThemeMode.light);
    registerFallbackValue(MockAppLocalizations());
  });

  setUp(() {
    mockLoginCubit = MockLoginCubit();
    mockAppCubit = MockAppCubit();

    when(() => mockLoginCubit.state).thenReturn(const LoginState());
    when(() => mockLoginCubit.stream).thenAnswer((_) => const Stream.empty());
    when(() => mockLoginCubit.loginWithEmail(any())).thenAnswer((_) async {});
    when(() => mockLoginCubit.loginWithGoogle(any())).thenAnswer((_) async {});
    when(() => mockLoginCubit.emailChanged(any())).thenReturn(null);
    when(() => mockLoginCubit.passwordChanged(any())).thenReturn(null);
    when(() => mockLoginCubit.togglePasswordVisibility()).thenReturn(null);

    when(() => mockAppCubit.state).thenReturn(const AppState());
    when(() => mockAppCubit.stream).thenAnswer((_) => const Stream.empty());
    when(
      () => mockAppCubit.changeTheme(theme: any(named: 'theme')),
    ).thenAnswer((_) async {});
  });

  Widget buildView({GoRouter? router}) {
    final defaultRouter = GoRouter(
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => MultiBlocProvider(
            providers: [
              BlocProvider<AppCubit>.value(value: mockAppCubit),
              BlocProvider<LoginCubit>.value(value: mockLoginCubit),
            ],
            child: const LoginView(),
          ),
        ),
        GoRoute(
          path: AppRoute.register.path,
          builder: (context, state) =>
              const Scaffold(body: Text('Register Page')),
        ),
      ],
    );

    return MaterialApp.router(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      routerConfig: router ?? defaultRouter,
    );
  }

  group('LoginView', () {
    testWidgets('renders all initial widgets', (tester) async {
      await tester.pumpWidget(buildView());
      await tester.pumpAndSettle();

      final l10n = await AppLocalizations.delegate.load(const Locale('en'));

      expect(find.byType(AppLogo), findsOneWidget);
      expect(find.text(l10n.emailLabel), findsOneWidget);
      expect(find.text(l10n.passwordLabel), findsOneWidget);
      expect(find.byType(AppFilledButton), findsOneWidget);
      expect(find.byType(AppOutlinedButton), findsOneWidget);
      expect(find.byType(AppChangeTheme), findsOneWidget);
      expect(find.byType(AppChangeLanguage), findsOneWidget);
    });

    testWidgets('calls emailChanged when typing in email field', (
      tester,
    ) async {
      await tester.pumpWidget(buildView());
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField).first, 'test@example.com');
      verify(() => mockLoginCubit.emailChanged('test@example.com')).called(1);
    });

    testWidgets('calls passwordChanged when typing in password field', (
      tester,
    ) async {
      await tester.pumpWidget(buildView());
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField).last, 'password123');
      verify(() => mockLoginCubit.passwordChanged('password123')).called(1);
    });

    testWidgets('calls togglePasswordVisibility when tapping suffix icon', (
      tester,
    ) async {
      await tester.pumpWidget(buildView());
      await tester.pumpAndSettle();

      await tester.tap(
        find.byWidgetPredicate(
          (widget) =>
              widget is HugeIcon &&
              widget.icon == HugeIcons.strokeRoundedViewOff,
        ),
      );
      verify(() => mockLoginCubit.togglePasswordVisibility()).called(1);
    });

    testWidgets('calls loginWithEmail when pressing login button', (
      tester,
    ) async {
      await tester.pumpWidget(buildView());
      await tester.pumpAndSettle();

      await tester.tap(find.byType(AppFilledButton));
      verify(() => mockLoginCubit.loginWithEmail(any())).called(1);
    });

    testWidgets('calls loginWithGoogle when pressing Google button', (
      tester,
    ) async {
      await tester.pumpWidget(buildView());
      await tester.pumpAndSettle();

      await tester.tap(find.byType(AppOutlinedButton));
      verify(() => mockLoginCubit.loginWithGoogle(any())).called(1);
    });

    testWidgets('renders loading state correctly', (tester) async {
      final l10n = await AppLocalizations.delegate.load(const Locale('en'));
      when(
        () => mockLoginCubit.state,
      ).thenReturn(const LoginState(status: LoginStatus.loading));

      await tester.pumpWidget(buildView());
      await tester.pump();

      expect(find.text(l10n.loginLoading), findsOneWidget);
    });

    testWidgets('shows error snackbar on failure status', (tester) async {
      final stateController = StreamController<LoginState>();
      whenListen(
        mockLoginCubit,
        stateController.stream,
        initialState: const LoginState(),
      );

      await tester.pumpWidget(buildView());

      stateController.add(
        const LoginState(
          status: LoginStatus.failure,
          errorMessage: 'Invalid credentials',
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      expect(find.text('Invalid credentials'), findsWidgets);
      await stateController.close();
    });

    testWidgets('shows success snackbar on success status', (tester) async {
      final l10n = await AppLocalizations.delegate.load(const Locale('en'));
      final stateController = StreamController<LoginState>();
      whenListen(
        mockLoginCubit,
        stateController.stream,
        initialState: const LoginState(),
      );

      await tester.pumpWidget(buildView());

      stateController.add(const LoginState(status: LoginStatus.success));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      expect(find.text(l10n.loginSuccess), findsWidgets);
      await stateController.close();
    });

    testWidgets('navigates to RegisterPage when tapping register button', (
      tester,
    ) async {
      final l10n = await AppLocalizations.delegate.load(const Locale('en'));
      await tester.pumpWidget(buildView());
      await tester.pumpAndSettle();

      final registerButton = find.widgetWithText(
        TextButton,
        l10n.registerButton,
      );
      expect(registerButton, findsOneWidget);

      await tester.tap(registerButton);
      await tester.pumpAndSettle();

      expect(find.text('Register Page'), findsOneWidget);
    });
  });
}
