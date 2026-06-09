import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:saver_expense_manager/app/app.dart';
import 'package:saver_expense_manager/l10n/l10n.dart';
import 'package:saver_expense_manager/register/cubit/register_cubit.dart';

class MockAuthService extends Mock implements AuthService {}

class MockAppLocalizations extends Mock implements AppLocalizations {}

class MockAnalyticsService extends Mock implements AnalyticsService {}

class MockCrashService extends Mock implements CrashService {}

void main() {
  late MockAuthService mockAuthService;
  late MockAppLocalizations mockAppLocalizations;
  late RegisterCubit registerCubit;
  late MockAnalyticsService mockAnalyticsService;
  late MockCrashService mockCrashService;

  setUp(() async {
    mockAuthService = MockAuthService();
    mockAppLocalizations = MockAppLocalizations();
    mockAnalyticsService = MockAnalyticsService();
    mockCrashService = MockCrashService();

    if (getIt.isRegistered<AnalyticsService>()) {
      await getIt.unregister<AnalyticsService>();
    }
    getIt.registerSingleton<AnalyticsService>(mockAnalyticsService);

    if (getIt.isRegistered<CrashService>()) {
      await getIt.unregister<CrashService>();
    }
    getIt.registerSingleton<CrashService>(mockCrashService);

    when(
      () => mockCrashService.recordError(
        any<dynamic>(),
        any<StackTrace?>(),
        reason: any<dynamic>(named: 'reason'),
      ),
    ).thenAnswer((_) async {});

    when(
      () => mockCrashService.setUserIdentifier(any<String>()),
    ).thenAnswer((_) async {});

    when(
      () => mockAnalyticsService.logEvent(
        name: any<String>(named: 'name'),
        parameters: any<Map<String, Object>?>(named: 'parameters'),
      ),
    ).thenAnswer((_) {});

    when(() => mockAppLocalizations.genericError).thenReturn('Error');
    when(() => mockAuthService.currentUser).thenReturn(null);

    when(
      () => mockAnalyticsService.setUserId(id: any<String>(named: 'id')),
    ).thenAnswer((_) {});

    registerCubit = RegisterCubit(authService: mockAuthService);
  });

  tearDown(() {
    unawaited(registerCubit.close());
  });

  group('RegisterCubit', () {
    test('initial state is correct', () {
      expect(registerCubit.state, const RegisterState());
    });

    blocTest<RegisterCubit, RegisterState>(
      'emits correct state on emailChanged (invalid)',
      build: () => registerCubit,
      act: (cubit) => cubit.emailChanged('invalid'),
      expect: () => [
        const RegisterState(email: 'invalid', isEmailValid: false),
      ],
    );

    blocTest<RegisterCubit, RegisterState>(
      'emits correct state on emailChanged (valid)',
      build: () => registerCubit,
      act: (cubit) => cubit.emailChanged('test@test.com'),
      expect: () => [const RegisterState(email: 'test@test.com')],
    );

    blocTest<RegisterCubit, RegisterState>(
      'emits correct state on passwordChanged (invalid)',
      build: () => registerCubit,
      act: (cubit) => cubit.passwordChanged('123'),
      expect: () => [
        const RegisterState(
          password: '123',
          isPasswordValid: false,
          isConfirmPasswordValid: false,
        ),
      ],
    );

    blocTest<RegisterCubit, RegisterState>(
      'emits correct state on confirmPasswordChanged',
      build: () => registerCubit,
      seed: () => const RegisterState(password: 'Pass123!'),
      act: (cubit) => cubit.confirmPasswordChanged('Pass123!'),
      expect: () => [
        const RegisterState(password: 'Pass123!', confirmPassword: 'Pass123!'),
      ],
    );

    blocTest<RegisterCubit, RegisterState>(
      'emits correct state on togglePasswordVisibility',
      build: () => registerCubit,
      act: (cubit) => cubit.togglePasswordVisibility(),
      expect: () => [const RegisterState(isPasswordVisible: true)],
    );

    blocTest<RegisterCubit, RegisterState>(
      'emits correct state on toggleConfirmPasswordVisibility',
      build: () => registerCubit,
      act: (cubit) => cubit.toggleConfirmPasswordVisibility(),
      expect: () => [const RegisterState(isConfirmPasswordVisible: true)],
    );

    blocTest<RegisterCubit, RegisterState>(
      'register emits nothing if form is invalid',
      build: () => registerCubit,
      seed: () => const RegisterState(),
      act: (cubit) => cubit.register(mockAppLocalizations),
      expect: () => const <RegisterState>[],
    );

    blocTest<RegisterCubit, RegisterState>(
      'register emits [loading, success] on successful auth',
      build: () => registerCubit,
      seed: () => const RegisterState(
        name: 'Piero',
        email: 'test@test.com',
        password: 'Password123!',
        confirmPassword: 'Password123!',
      ),
      setUp: () {
        when(
          () => mockAuthService.signUpWithEmailAndPassword(
            any<String>(),
            any<String>(),
          ),
        ).thenAnswer((_) async => true);
        when(
          () => mockAuthService.updateUserName(any<String>()),
        ).thenAnswer((_) async => true);
      },
      act: (cubit) => cubit.register(mockAppLocalizations),
      expect: () => const [
        RegisterState(
          name: 'Piero',
          email: 'test@test.com',
          password: 'Password123!',
          confirmPassword: 'Password123!',
          status: RegisterStatus.loading,
        ),
        RegisterState(
          name: 'Piero',
          email: 'test@test.com',
          password: 'Password123!',
          confirmPassword: 'Password123!',
          status: RegisterStatus.success,
        ),
      ],
    );
  });
}
