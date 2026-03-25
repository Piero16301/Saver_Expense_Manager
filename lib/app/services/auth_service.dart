import 'package:saver_expense_manager/app/app.dart';

class AuthService {
  AuthService({required AuthRepository authRepository})
      : _authRepository = authRepository;

  final AuthRepository _authRepository;

  Future<void> initialize() async {
    await _authRepository.initialize();
  }

  Stream<AppUser?> get userChanges => _authRepository.userChanges;
  Stream<AppUser?> get authStateChanges => _authRepository.authStateChanges;
  AppUser? get currentUser => _authRepository.currentUser;
  bool get isLoggedIn => _authRepository.isLoggedIn;

  Future<bool> updateDisplayName(String newName) async {
    return _authRepository.updateDisplayName(newName);
  }

  Future<bool> signOut() => _authRepository.signOut();

  Future<bool> unlinkProvider(String providerId) =>
      _authRepository.unlinkProvider(providerId);

  Future<bool> reloadUser() => _authRepository.reloadUser();

  Future<bool> linkWithGoogle() => _authRepository.linkWithGoogle();

  Future<bool> linkWithEmailPassword({
    required String email,
    required String password,
  }) =>
      _authRepository.linkWithEmailPassword(email: email, password: password);

  Future<bool> signInWithGoogle() => _authRepository.signInWithGoogle();

  Future<bool> signInWithEmailAndPassword(
    String email,
    String password,
  ) =>
      _authRepository.signInWithEmailAndPassword(email, password);

  Future<bool> signUpWithEmailAndPassword(
    String email,
    String password,
  ) =>
      _authRepository.signUpWithEmailAndPassword(email, password);

  Future<bool> updateUserName(String newName) =>
      _authRepository.updateUserName(newName);
}
