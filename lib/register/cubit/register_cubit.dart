import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:saver_expense_manager/app/app.dart';
import 'package:saver_expense_manager/l10n/l10n.dart';

part 'register_state.dart';

class RegisterCubit extends Cubit<RegisterState> {
  RegisterCubit({AuthenticationService? authService})
      : _authService = authService ?? getIt<AuthenticationService>(),
        super(const RegisterState());

  final AuthenticationService _authService;

  void nameChanged(String value) {
    emit(
      state.copyWith(
        name: value,
        isNameValid: _validateName(value),
      ),
    );
  }

  void emailChanged(String value) {
    emit(
      state.copyWith(
        email: value,
        isEmailValid: _validateEmail(value),
      ),
    );
  }

  void passwordChanged(String value) {
    emit(
      state.copyWith(
        password: value,
        isPasswordValid: _validatePassword(value),
        isConfirmPasswordValid: value == state.confirmPassword,
      ),
    );
  }

  void confirmPasswordChanged(String value) {
    emit(
      state.copyWith(
        confirmPassword: value,
        isConfirmPasswordValid: value == state.password,
      ),
    );
  }

  bool _validateName(String name) {
    final nameRegex = RegExp(AppVariables.nameRegExp);
    return nameRegex.hasMatch(name);
  }

  bool _validateEmail(String email) {
    final emailRegex = RegExp(AppVariables.emailRegExp);
    return emailRegex.hasMatch(email);
  }

  bool _validatePassword(String password) {
    final passwordRegex = RegExp(AppVariables.passwordRegExp);
    return passwordRegex.hasMatch(password);
  }

  void togglePasswordVisibility() {
    emit(state.copyWith(isPasswordVisible: !state.isPasswordVisible));
  }

  void toggleConfirmPasswordVisibility() {
    emit(
      state.copyWith(
        isConfirmPasswordVisible: !state.isConfirmPasswordVisible,
      ),
    );
  }

  Future<void> register(AppLocalizations l10n) async {
    if (!state.isFormValid) return;
    emit(state.copyWith(status: RegisterStatus.loading));
    try {
      await _authService.signUpWithEmailAndPassword(
        state.email,
        state.password,
      );
      getIt<AnalyticsService>().logEvent(
        name: 'sign_up',
        parameters: {'method': 'email'},
      );
      final user = _authService.currentUser;
      if (user != null) {
        getIt<AnalyticsService>().setUserId(id: user.uid);
        getIt<CrashService>().setUserIdentifier(user.uid);
      }
      emit(state.copyWith(status: RegisterStatus.success));
      await _authService.updateUserName(state.name);
    } on Exception catch (_) {
      emit(
        state.copyWith(
          status: RegisterStatus.failure,
          errorMessage: l10n.genericError,
        ),
      );
    }
  }
}
