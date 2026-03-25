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
    this.user,
    this.userName = '',
    this.isEditingName = false,
    this.errorMessage,
  });

  final ProfileStatus status;
  final AppUser? user;
  final String userName;
  final bool isEditingName;
  final String? errorMessage;

  ProfileState copyWith({
    ProfileStatus? status,
    AppUser? user,
    String? userName,
    bool? isEditingName,
    String? errorMessage,
  }) {
    return ProfileState(
      status: status ?? this.status,
      user: user ?? this.user,
      userName: userName ?? this.userName,
      isEditingName: isEditingName ?? this.isEditingName,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
        status,
        user,
        userName,
        isEditingName,
        errorMessage,
      ];
}
