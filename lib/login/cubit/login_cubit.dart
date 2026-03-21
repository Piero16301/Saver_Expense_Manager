import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:saver_expense_manager/app/app.dart';
import 'package:saver_expense_manager/l10n/l10n.dart';

part 'login_state.dart';

class LoginCubit extends Cubit<LoginState> {
  LoginCubit({AuthenticationService? authService})
      : _authService = authService ?? getIt<AuthenticationService>(),
        super(const LoginState());

  final AuthenticationService _authService;

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
      ),
    );
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

  Future<void> loginWithEmail(AppLocalizations l10n) async {
    if (!state.isFormValid) return;
    emit(state.copyWith(status: LoginStatus.loading));
    try {
      await _authService.signInWithEmailAndPassword(
        state.email,
        state.password,
      );
      getIt<AnalyticsService>().logEvent(
        name: 'login',
        parameters: {'method': 'email'},
      );
      final user = _authService.currentUser;
      if (user != null) {
        getIt<AnalyticsService>().setUserId(id: user.uid);
      }
      emit(state.copyWith(status: LoginStatus.success));
    } on Exception catch (_) {
      emit(
        state.copyWith(
          status: LoginStatus.failure,
          errorMessage: l10n.genericError,
        ),
      );
    }
  }

  Future<void> loginWithGoogle(AppLocalizations l10n) async {
    emit(state.copyWith(status: LoginStatus.loading));
    try {
      final userCredential = await _authService.signInWithGoogle();
      if (userCredential != null) {
        getIt<AnalyticsService>().logEvent(
          name: 'login',
          parameters: {'method': 'google'},
        );
        final user = _authService.currentUser;
        if (user != null) {
          getIt<AnalyticsService>().setUserId(id: user.uid);
        }
        emit(state.copyWith(status: LoginStatus.success));
      } else {
        emit(
          state.copyWith(
            status: LoginStatus.initial,
          ),
        );
      }
    } on Exception catch (_) {
      emit(
        state.copyWith(
          status: LoginStatus.failure,
          errorMessage: l10n.genericError,
        ),
      );
    }
  }
}
