import 'package:flutter_test/flutter_test.dart';
import 'package:saver_expense_manager/register/cubit/register_cubit.dart';

void main() {
  group('RegisterState', () {
    test('supports value equality', () {
      expect(const RegisterState(), equals(const RegisterState()));
    });

    test('props are correct', () {
      expect(
        const RegisterState().props,
        equals(<Object?>[
          '',
          '',
          '',
          '',
          RegisterStatus.initial,
          null,
          false,
          false,
          true,
          true,
          true,
          true,
        ]),
      );
    });

    test('copyWith returns object with updated properties', () {
      const state = RegisterState();
      expect(
        state.copyWith(
          email: 'test',
          password: '123',
          confirmPassword: '123',
          status: RegisterStatus.success,
          errorMessage: 'error',
          isPasswordVisible: true,
          isConfirmPasswordVisible: true,
          isEmailValid: false,
          isPasswordValid: false,
          isConfirmPasswordValid: false,
        ),
        equals(
          const RegisterState(
            email: 'test',
            password: '123',
            confirmPassword: '123',
            status: RegisterStatus.success,
            errorMessage: 'error',
            isPasswordVisible: true,
            isConfirmPasswordVisible: true,
            isEmailValid: false,
            isPasswordValid: false,
            isConfirmPasswordValid: false,
          ),
        ),
      );
    });

    test('copyWith returns original object when properties are null', () {
      expect(const RegisterState().copyWith(), equals(const RegisterState()));
    });
  });

  group('RegisterStatus', () {
    test('getters are correct', () {
      expect(RegisterStatus.initial.isInitial, isTrue);
      expect(RegisterStatus.loading.isLoading, isTrue);
      expect(RegisterStatus.success.isSuccess, isTrue);
      expect(RegisterStatus.failure.isFailure, isTrue);
    });
  });
}
