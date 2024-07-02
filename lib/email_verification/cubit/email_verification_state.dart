part of 'email_verification_cubit.dart';

enum EmailVerificationStatus {
  initial,
  loading,
  success,
  failure;

  bool get isInitial => this == EmailVerificationStatus.initial;
  bool get isLoading => this == EmailVerificationStatus.loading;
  bool get isSuccess => this == EmailVerificationStatus.success;
  bool get isFailure => this == EmailVerificationStatus.failure;
}

class EmailVerificationState extends Equatable {
  const EmailVerificationState({
    this.status = EmailVerificationStatus.initial,
  });

  final EmailVerificationStatus status;

  EmailVerificationState copyWith({
    EmailVerificationStatus? status,
  }) {
    return EmailVerificationState(
      status: status ?? this.status,
    );
  }

  @override
  List<Object?> get props => [
        status,
      ];
}
