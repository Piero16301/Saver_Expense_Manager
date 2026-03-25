part of 'login_cubit.dart';

enum LoginStatus {
  initial,
  loading,
  success,
  failure;

  bool get isInitial => this == LoginStatus.initial;
  bool get isLoading => this == LoginStatus.loading;
  bool get isSuccess => this == LoginStatus.success;
  bool get isFailure => this == LoginStatus.failure;
}

class LoginState extends Equatable {
  const LoginState({
    this.status = LoginStatus.initial,
    this.email = '',
    this.password = '',
    this.isPasswordVisible = false,
    this.isEmailValid = true,
    this.isPasswordValid = true,
    this.errorMessage,
  });

  final LoginStatus status;
  final String email;
  final String password;
  final bool isPasswordVisible;
  final bool isEmailValid;
  final bool isPasswordValid;
  final String? errorMessage;

  bool get isFormValid =>
      isEmailValid &&
      isPasswordValid &&
      email.isNotEmpty &&
      password.isNotEmpty;

  LoginState copyWith({
    LoginStatus? status,
    String? email,
    String? password,
    bool? isPasswordVisible,
    bool? isEmailValid,
    bool? isPasswordValid,
    String? errorMessage,
  }) {
    return LoginState(
      status: status ?? this.status,
      email: email ?? this.email,
      password: password ?? this.password,
      isPasswordVisible: isPasswordVisible ?? this.isPasswordVisible,
      isEmailValid: isEmailValid ?? this.isEmailValid,
      isPasswordValid: isPasswordValid ?? this.isPasswordValid,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
        status,
        email,
        password,
        isPasswordVisible,
        isEmailValid,
        isPasswordValid,
        errorMessage,
      ];
}
