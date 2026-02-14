part of 'profile_cubit.dart';

enum ProfileStatus { initial, loading, success, failure }

class ProfileState extends Equatable {
  const ProfileState({
    this.status = ProfileStatus.initial,
    this.user,
    this.userName = '',
    this.isEditingName = false,
    this.errorMessage,
  });

  final ProfileStatus status;
  final User? user;
  final String userName;
  final bool isEditingName;
  final String? errorMessage;

  ProfileState copyWith({
    ProfileStatus? status,
    User? user,
    String? userName,
    bool? isEditingName,
    String? errorMessage,
  }) {
    return ProfileState(
      status: status ?? this.status,
      user: user ?? this.user,
      userName: userName ?? this.userName,
      isEditingName: isEditingName ?? this.isEditingName,
      errorMessage: errorMessage,
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
