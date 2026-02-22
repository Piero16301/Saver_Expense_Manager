import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:saver_expense_manager/app/app.dart';
import 'package:saver_expense_manager/l10n/l10n.dart';

part 'profile_state.dart';

class ProfileCubit extends Cubit<ProfileState> {
  ProfileCubit({AuthenticationService? authService})
      : _authService = authService ?? getIt<AuthenticationService>(),
        super(const ProfileState()) {
    _init();
  }

  final AuthenticationService _authService;
  StreamSubscription<AppUser?>? _userSubscription;

  void _init() {
    _userSubscription = _authService.userChanges.listen((user) {
      emit(
        state.copyWith(
          user: user,
          userName: user?.displayName ?? '',
          status: ProfileStatus.success,
        ),
      );
    });
  }

  void nameChanged(String name) {
    emit(state.copyWith(userName: name));
  }

  Future<void> saveName(AppLocalizations l10n) async {
    if (state.userName.trim().isEmpty) return;
    try {
      emit(state.copyWith(status: ProfileStatus.loading));
      await _authService.updateDisplayName(state.userName.trim());
      emit(
        state.copyWith(
          status: ProfileStatus.success,
          isEditingName: false,
        ),
      );
    } on Exception catch (_) {
      emit(
        state.copyWith(
          status: ProfileStatus.failure,
          errorMessage: l10n.genericError,
        ),
      );
    }
  }

  void toggleEditingName() {
    final isEditing = !state.isEditingName;
    emit(
      state.copyWith(
        isEditingName: isEditing,
        userName: isEditing ? state.user?.displayName ?? '' : '',
      ),
    );
  }

  Future<void> linkGoogle(AppLocalizations l10n) async {
    try {
      emit(state.copyWith(status: ProfileStatus.loading));
      await _authService.linkWithGoogle();
      emit(state.copyWith(status: ProfileStatus.success));
    } on Exception catch (_) {
      emit(
        state.copyWith(
          status: ProfileStatus.failure,
          errorMessage: l10n.genericError,
        ),
      );
    }
  }

  Future<void> linkEmail(
    AppLocalizations l10n, {
    required String email,
    required String password,
  }) async {
    try {
      emit(state.copyWith(status: ProfileStatus.loading));
      await _authService.linkWithEmailPassword(
        email: email,
        password: password,
      );
      emit(state.copyWith(status: ProfileStatus.success));
    } on Exception catch (_) {
      emit(
        state.copyWith(
          status: ProfileStatus.failure,
          errorMessage: l10n.genericError,
        ),
      );
    }
  }

  Future<void> unlinkProvider(AppLocalizations l10n, String providerId) async {
    try {
      emit(state.copyWith(status: ProfileStatus.loading));
      await _authService.unlinkProvider(providerId);
      emit(state.copyWith(status: ProfileStatus.success));
    } on Exception catch (_) {
      emit(
        state.copyWith(
          status: ProfileStatus.failure,
          errorMessage: l10n.genericError,
        ),
      );
    }
  }

  Future<void> logout(AppLocalizations l10n) async {
    try {
      await _authService.signOut();
    } on Exception catch (_) {
      emit(
        state.copyWith(
          status: ProfileStatus.failure,
          errorMessage: l10n.genericError,
        ),
      );
    }
  }

  @override
  Future<void> close() async {
    await _userSubscription?.cancel();
    return super.close();
  }
}
