import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:saver_expense_manager/app/app.dart';
import 'package:saver_expense_manager/l10n/l10n.dart';

part 'profile_state.dart';

class ProfileCubit extends Cubit<ProfileState> {
  ProfileCubit({AuthService? authService})
      : _authService = authService ?? getIt<AuthService>(),
        super(const ProfileState()) {
    _init();
  }

  final AuthService _authService;
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
    emit(state.copyWith(status: ProfileStatus.loading));
    final success = await _authService.updateDisplayName(state.userName.trim());
    if (success) {
      emit(state.copyWith(status: ProfileStatus.success, isEditingName: false));
    } else {
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

  void reset() {
    emit(state.copyWith(status: ProfileStatus.initial));
  }

  Future<void> linkGoogle(AppLocalizations l10n) async {
    emit(state.copyWith(status: ProfileStatus.loading));
    final success = await _authService.linkWithGoogle();
    if (success) {
      emit(state.copyWith(status: ProfileStatus.success));
    } else {
      emit(
        state.copyWith(
          status: ProfileStatus.failure,
          errorMessage: l10n.genericError,
        ),
      );
      emit(state.copyWith(status: ProfileStatus.initial));
    }
  }

  Future<void> linkEmail(
    AppLocalizations l10n, {
    required String email,
    required String password,
  }) async {
    emit(state.copyWith(status: ProfileStatus.loading));
    final success = await _authService.linkWithEmailPassword(
      email: email,
      password: password,
    );
    if (success) {
      emit(state.copyWith(status: ProfileStatus.success));
    } else {
      emit(
        state.copyWith(
          status: ProfileStatus.failure,
          errorMessage: l10n.genericError,
        ),
      );
      emit(state.copyWith(status: ProfileStatus.initial));
    }
  }

  Future<void> unlinkProvider(AppLocalizations l10n, String providerId) async {
    emit(state.copyWith(status: ProfileStatus.loading));
    final success = await _authService.unlinkProvider(providerId);
    if (success) {
      emit(state.copyWith(status: ProfileStatus.success));
    } else {
      emit(
        state.copyWith(
          status: ProfileStatus.failure,
          errorMessage: l10n.genericError,
        ),
      );
      emit(state.copyWith(status: ProfileStatus.initial));
    }
  }

  Future<void> logout(AppLocalizations l10n) async {
    final success = await _authService.signOut();
    if (success) {
      getIt<AnalyticsService>().logEvent(name: 'logout');
    } else {
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
