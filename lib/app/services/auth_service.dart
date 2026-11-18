import 'package:saver_expense_manager/app/app.dart';

class AuthService {
  new({required this._authRepository});

  final AuthRepository _authRepository;

  Future<void> initialize() async {
    try {
      await _authRepository.initialize();
    } on Exception catch (e, stackTrace) {
      getIt<CrashService>().recordError(
        e,
        stackTrace,
        reason: 'AuthService initialize error',
      );
      rethrow;
    }
  }

  Stream<AppUser?> get userChanges => _authRepository.userChanges;
  Stream<AppUser?> get authStateChanges => _authRepository.authStateChanges;
  AppUser? get currentUser => _authRepository.currentUser;
  bool get isLoggedIn => _authRepository.isLoggedIn;

  Future<bool> updateDisplayName(String newName) async {
    try {
      return await _authRepository.updateDisplayName(newName);
    } on Exception catch (e, stackTrace) {
      getIt<CrashService>().recordError(
        e,
        stackTrace,
        reason: 'AuthService updateDisplayName error',
      );
      return false;
    }
  }

  Future<bool> signOut() async {
    try {
      try {
        final currentUid = currentUser?.uid;
        if (currentUid != null && getIt.isRegistered<LocalStorageService>()) {
          getIt<LocalStorageService>().clearRecommendations(userId: currentUid);
        }
      } on Object catch (_) {}
      return await _authRepository.signOut();
    } on Exception catch (e, stackTrace) {
      getIt<CrashService>().recordError(
        e,
        stackTrace,
        reason: 'AuthService signOut error',
      );
      return false;
    }
  }

  Future<bool> unlinkProvider(String providerId) async {
    try {
      return await _authRepository.unlinkProvider(providerId);
    } on Exception catch (e, stackTrace) {
      getIt<CrashService>().recordError(
        e,
        stackTrace,
        reason: 'AuthService unlinkProvider error',
      );
      return false;
    }
  }

  Future<bool> reloadUser() async {
    try {
      return await _authRepository.reloadUser();
    } on Exception catch (e, stackTrace) {
      getIt<CrashService>().recordError(
        e,
        stackTrace,
        reason: 'AuthService reloadUser error',
      );
      return false;
    }
  }

  Future<bool> linkWithGoogle() async {
    try {
      return await _authRepository.linkWithGoogle();
    } on Exception catch (e, stackTrace) {
      getIt<CrashService>().recordError(
        e,
        stackTrace,
        reason: 'AuthService linkWithGoogle error',
      );
      return false;
    }
  }

  Future<bool> linkWithEmailPassword({
    required String email,
    required String password,
  }) async {
    try {
      return await _authRepository.linkWithEmailPassword(
        email: email,
        password: password,
      );
    } on Exception catch (e, stackTrace) {
      getIt<CrashService>().recordError(
        e,
        stackTrace,
        reason: 'AuthService linkWithEmailPassword error',
      );
      return false;
    }
  }

  Future<bool> signInWithGoogle() async {
    final performance = getIt<PerformanceService>();
    final trace = performance.startTrace('auth_sign_in_google');
    try {
      return await _authRepository.signInWithGoogle();
    } on Exception catch (e, stackTrace) {
      getIt<CrashService>().recordError(
        e,
        stackTrace,
        reason: 'AuthService signInWithGoogle error',
      );
      return false;
    } finally {
      performance.stopTrace(trace);
    }
  }

  Future<bool> signInWithEmailAndPassword(String email, String password) async {
    final performance = getIt<PerformanceService>();
    final trace = performance.startTrace('auth_sign_in_email');
    try {
      return await _authRepository.signInWithEmailAndPassword(email, password);
    } on Exception catch (e, stackTrace) {
      getIt<CrashService>().recordError(
        e,
        stackTrace,
        reason: 'AuthService signInWithEmailAndPassword error',
      );
      return false;
    } finally {
      performance.stopTrace(trace);
    }
  }

  Future<bool> signUpWithEmailAndPassword(String email, String password) async {
    final performance = getIt<PerformanceService>();
    final trace = performance.startTrace('auth_sign_up_email');
    try {
      return await _authRepository.signUpWithEmailAndPassword(email, password);
    } on Exception catch (e, stackTrace) {
      getIt<CrashService>().recordError(
        e,
        stackTrace,
        reason: 'AuthService signUpWithEmailAndPassword error',
      );
      return false;
    } finally {
      performance.stopTrace(trace);
    }
  }

  Future<bool> updateUserName(String newName) async {
    try {
      return await _authRepository.updateUserName(newName);
    } on Exception catch (e, stackTrace) {
      getIt<CrashService>().recordError(
        e,
        stackTrace,
        reason: 'AuthService updateUserName error',
      );
      return false;
    }
  }

  Future<bool> deleteAccount() async {
    final performance = getIt<PerformanceService>();
    final trace = performance.startTrace('auth_delete_account');
    try {
      final currentUid = currentUser?.uid;
      if (currentUid != null && getIt.isRegistered<LocalStorageService>()) {
        try {
          getIt<LocalStorageService>().clearRecommendations(userId: currentUid);
        } on Object catch (_) {}
      }
      return await _authRepository.deleteAccount(
        onCloudFunctionError: (e, stackTrace) {
          getIt<CrashService>().recordError(
            e,
            stackTrace,
            reason: 'AuthService deleteAccount cloud function fallback',
          );
        },
      );
    } on Exception catch (e, stackTrace) {
      getIt<CrashService>().recordError(
        e,
        stackTrace,
        reason: 'AuthService deleteAccount error',
      );
      return false;
    } finally {
      performance.stopTrace(trace);
    }
  }
}
