import 'package:bloc_test/bloc_test.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:saver_expense_manager/app/app.dart';
import 'package:saver_expense_manager/l10n/l10n.dart';
import 'package:saver_expense_manager/login/cubit/login_cubit.dart';

class MockAuthenticationService extends Mock implements AuthenticationService {}

class MockAppLocalizations extends Mock implements AppLocalizations {}

class MockUserCredential extends Mock implements UserCredential {}

void main() {
  late MockAuthenticationService mockAuthService;
  late MockAppLocalizations mockL10n;

  setUp(() {
    mockAuthService = MockAuthenticationService();
    mockL10n = MockAppLocalizations();
    when(() => mockL10n.genericError).thenReturn('Generic Error');
  });

  group('LoginState', () {
    test('supports value equality', () {
      expect(const LoginState(), equals(const LoginState()));
    });

    test('isFormValid works correctly', () {
      expect(const LoginState().isFormValid, isFalse);

      expect(
        const LoginState(
          email: 'test@test.com',
          password: 'password123',
        ).isFormValid,
        isTrue,
      );

      expect(
        const LoginState(
          email: 'test@test.com',
          password: 'password123',
          isEmailValid: false,
        ).isFormValid,
        isFalse,
      );
    });
  });

  group('LoginCubit', () {
    test('initial state is correct', () {
      expect(
        LoginCubit(authService: mockAuthService).state,
        equals(const LoginState()),
      );
    });

    blocTest<LoginCubit, LoginState>(
      'emailChanged emits valid state for good email',
      build: () => LoginCubit(authService: mockAuthService),
      act: (cubit) => cubit.emailChanged('test@example.com'),
      expect: () => [
        const LoginState(
          email: 'test@example.com',
        ),
      ],
    );

    blocTest<LoginCubit, LoginState>(
      'emailChanged emits invalid state for bad email',
      build: () => LoginCubit(authService: mockAuthService),
      act: (cubit) => cubit.emailChanged('bad_email'),
      expect: () => [
        const LoginState(
          email: 'bad_email',
          isEmailValid: false,
        ),
      ],
    );

    blocTest<LoginCubit, LoginState>(
      'passwordChanged emits valid state for good password',
      build: () => LoginCubit(authService: mockAuthService),
      act: (cubit) => cubit.passwordChanged('Pass123!'),
      expect: () => [
        const LoginState(
          password: 'Pass123!',
        ),
      ],
    );

    blocTest<LoginCubit, LoginState>(
      'passwordChanged emits invalid state for simple password',
      build: () => LoginCubit(authService: mockAuthService),
      act: (cubit) => cubit.passwordChanged('123'),
      expect: () => [
        const LoginState(
          password: '123',
          isPasswordValid: false,
        ),
      ],
    );

    blocTest<LoginCubit, LoginState>(
      'togglePasswordVisibility works correctly',
      build: () => LoginCubit(authService: mockAuthService),
      act: (cubit) => cubit.togglePasswordVisibility(),
      expect: () => [
        const LoginState(isPasswordVisible: true),
      ],
    );

    group('loginWithEmail', () {
      blocTest<LoginCubit, LoginState>(
        'does not emit loading or success if form is invalid',
        build: () => LoginCubit(authService: mockAuthService),
        act: (cubit) => cubit.loginWithEmail(mockL10n),
        expect: () => <LoginState>[],
      );

      blocTest<LoginCubit, LoginState>(
        'emits loading and success when authentication succeeds',
        build: () {
          when(
            () => mockAuthService.signInWithEmailAndPassword(
              'test@test.com',
              'Pass123!',
            ),
          ).thenAnswer((_) async => MockUserCredential());
          return LoginCubit(authService: mockAuthService);
        },
        seed: () => const LoginState(
          email: 'test@test.com',
          password: 'Pass123!',
        ),
        act: (cubit) => cubit.loginWithEmail(mockL10n),
        expect: () => [
          const LoginState(
            email: 'test@test.com',
            password: 'Pass123!',
            status: LoginStatus.loading,
          ),
          const LoginState(
            email: 'test@test.com',
            password: 'Pass123!',
            status: LoginStatus.success,
          ),
        ],
      );

      blocTest<LoginCubit, LoginState>(
        'emits failure when authentication throws',
        build: () {
          when(
            () => mockAuthService.signInWithEmailAndPassword(
              'test@test.com',
              'Pass123!',
            ),
          ).thenThrow(Exception('auth error'));
          return LoginCubit(authService: mockAuthService);
        },
        seed: () => const LoginState(
          email: 'test@test.com',
          password: 'Pass123!',
        ),
        act: (cubit) => cubit.loginWithEmail(mockL10n),
        expect: () => [
          const LoginState(
            email: 'test@test.com',
            password: 'Pass123!',
            status: LoginStatus.loading,
          ),
          const LoginState(
            email: 'test@test.com',
            password: 'Pass123!',
            status: LoginStatus.failure,
            errorMessage: 'Generic Error',
          ),
        ],
      );
    });

    group('loginWithGoogle', () {
      blocTest<LoginCubit, LoginState>(
        'emits loading and success when authentication succeeds',
        build: () {
          when(() => mockAuthService.signInWithGoogle())
              .thenAnswer((_) async => MockUserCredential());
          return LoginCubit(authService: mockAuthService);
        },
        act: (cubit) => cubit.loginWithGoogle(mockL10n),
        expect: () => [
          const LoginState(status: LoginStatus.loading),
          const LoginState(status: LoginStatus.success),
        ],
      );

      blocTest<LoginCubit, LoginState>(
        'emits initial when userCredential is null',
        build: () {
          when(() => mockAuthService.signInWithGoogle())
              .thenAnswer((_) async => null);
          return LoginCubit(authService: mockAuthService);
        },
        act: (cubit) => cubit.loginWithGoogle(mockL10n),
        expect: () => [
          const LoginState(status: LoginStatus.loading),
          const LoginState(),
        ],
      );

      blocTest<LoginCubit, LoginState>(
        'emits failure when authentication throws',
        build: () {
          when(() => mockAuthService.signInWithGoogle())
              .thenThrow(Exception('auth error'));
          return LoginCubit(authService: mockAuthService);
        },
        act: (cubit) => cubit.loginWithGoogle(mockL10n),
        expect: () => [
          const LoginState(status: LoginStatus.loading),
          const LoginState(
            status: LoginStatus.failure,
            errorMessage: 'Generic Error',
          ),
        ],
      );
    });
  });
}
