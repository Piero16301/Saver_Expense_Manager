part of 'profile_cubit.dart';

enum ProfileStatus {
  initial,
  loading,
  success,
  failure;

  bool get isInitial => this == ProfileStatus.initial;
  bool get isLoading => this == ProfileStatus.loading;
  bool get isSuccess => this == ProfileStatus.success;
  bool get isFailure => this == ProfileStatus.failure;
}

class ProfileState extends Equatable {
  const ProfileState({
    this.status = ProfileStatus.initial,
  });

  final ProfileStatus status;

  ProfileState copyWith({
    ProfileStatus? status,
  }) {
    return ProfileState(
      status: status ?? this.status,
    );
  }

  @override
  List<Object?> get props => [
        status,
      ];
}
