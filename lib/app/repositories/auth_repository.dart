import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:saver_expense_manager/app/app.dart';
import 'package:saver_expense_manager/firebase_options.dart';

abstract class AuthRepository {
  Future<void> initialize();
  Stream<AppUser?> get userChanges;
  Stream<AppUser?> get authStateChanges;
  AppUser? get currentUser;
  bool get isLoggedIn;
  Future<bool> updateDisplayName(String newName);
  Future<bool> signOut();
  Future<bool> unlinkProvider(String providerId);
  Future<bool> reloadUser();
  Future<bool> linkWithGoogle();
  Future<bool> linkWithEmailPassword({
    required String email,
    required String password,
  });
  Future<bool> signInWithGoogle();
  Future<bool> signInWithEmailAndPassword(String email, String password);
  Future<bool> signUpWithEmailAndPassword(String email, String password);
  Future<bool> updateUserName(String newName);
}

class MockAuthRepository implements AuthRepository {
  @override
  Future<void> initialize() async {}

  @override
  Stream<AppUser?> get userChanges => Stream.value(const AppUser(uid: '1'));

  @override
  Stream<AppUser?> get authStateChanges =>
      Stream.value(const AppUser(uid: '1'));

  @override
  AppUser? get currentUser => const AppUser(uid: '1');

  @override
  bool get isLoggedIn => true;

  @override
  Future<bool> updateDisplayName(String newName) async => true;

  @override
  Future<bool> signOut() async => true;

  @override
  Future<bool> unlinkProvider(String providerId) async => true;

  @override
  Future<bool> reloadUser() async => true;

  @override
  Future<bool> linkWithGoogle() async => true;

  @override
  Future<bool> linkWithEmailPassword({
    required String email,
    required String password,
  }) async => true;

  @override
  Future<bool> signInWithGoogle() async => true;

  @override
  Future<bool> signInWithEmailAndPassword(
    String email,
    String password,
  ) async => true;

  @override
  Future<bool> signUpWithEmailAndPassword(
    String email,
    String password,
  ) async => true;

  @override
  Future<bool> updateUserName(String newName) async => true;
}

class FirebaseAuthRepository implements AuthRepository {
  FirebaseAuthRepository({FirebaseAuth? auth, GoogleSignIn? googleSignIn})
    : _auth = auth ?? FirebaseAuth.instance,
      _googleSignIn = googleSignIn ?? GoogleSignIn.instance;

  final FirebaseAuth _auth;
  final GoogleSignIn _googleSignIn;

  @override
  Future<void> initialize() async {
    if (kIsWeb) {
      return;
    }
    try {
      await _googleSignIn.initialize(
        serverClientId: DefaultFirebaseOptions.googleClientId,
      );
    } on Exception catch (e, stackTrace) {
      getIt<CrashService>().recordError(
        e,
        stackTrace,
        reason: 'AuthService initialize error',
      );
      rethrow;
    }
  }

  @override
  Stream<AppUser?> get userChanges => _auth.userChanges().map(
    (u) => u == null ? null : AppUser.fromFirebaseUser(u),
  );

  @override
  Stream<AppUser?> get authStateChanges => _auth.authStateChanges().map(
    (u) => u == null ? null : AppUser.fromFirebaseUser(u),
  );

  @override
  AppUser? get currentUser => _auth.currentUser == null
      ? null
      : AppUser.fromFirebaseUser(_auth.currentUser!);

  @override
  bool get isLoggedIn => currentUser != null;

  @override
  Future<bool> updateDisplayName(String newName) async {
    try {
      await _auth.currentUser?.updateDisplayName(newName);
      await _auth.currentUser?.reload();
      return true;
    } on Exception catch (e, stackTrace) {
      getIt<CrashService>().recordError(
        e,
        stackTrace,
        reason: 'AuthService updateDisplayName error',
      );
      return false;
    }
  }

  @override
  Future<bool> signOut() async {
    try {
      await _auth.signOut();
      return true;
    } on Exception catch (e, stackTrace) {
      getIt<CrashService>().recordError(
        e,
        stackTrace,
        reason: 'AuthService signOut error',
      );
      return false;
    }
  }

  @override
  Future<bool> unlinkProvider(String providerId) async {
    try {
      await _auth.currentUser?.unlink(providerId);
      await _auth.currentUser?.reload();
      return true;
    } on Exception catch (e, stackTrace) {
      getIt<CrashService>().recordError(
        e,
        stackTrace,
        reason: 'AuthService unlinkProvider error',
      );
      return false;
    }
  }

  @override
  Future<bool> reloadUser() async {
    try {
      await _auth.currentUser?.reload();
      return true;
    } on Exception catch (e, stackTrace) {
      getIt<CrashService>().recordError(
        e,
        stackTrace,
        reason: 'AuthService reloadUser error',
      );
      return false;
    }
  }

  @override
  Future<bool> linkWithGoogle() async {
    try {
      if (kIsWeb) {
        final googleProvider = GoogleAuthProvider();
        await _auth.currentUser?.linkWithPopup(googleProvider);
        return true;
      }

      await _googleSignIn.signOut();
      final googleUser = await _googleSignIn.authenticate();
      final googleAuth = googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        idToken: googleAuth.idToken,
      );
      await _auth.currentUser?.linkWithCredential(credential);
      return true;
    } on Exception catch (e, stackTrace) {
      getIt<CrashService>().recordError(
        e,
        stackTrace,
        reason: 'AuthService linkWithGoogle error',
      );
      return false;
    }
  }

  @override
  Future<bool> linkWithEmailPassword({
    required String email,
    required String password,
  }) async {
    try {
      final credential = EmailAuthProvider.credential(
        email: email,
        password: password,
      );
      await _auth.currentUser?.linkWithCredential(credential);
      return true;
    } on Exception catch (e, stackTrace) {
      getIt<CrashService>().recordError(
        e,
        stackTrace,
        reason: 'AuthService linkWithEmailPassword error',
      );
      return false;
    }
  }

  @override
  Future<bool> signInWithGoogle() async {
    final performance = getIt<PerformanceService>();
    final trace = performance.startTrace('auth_sign_in_google');
    try {
      if (kIsWeb) {
        final googleProvider = GoogleAuthProvider();
        await _auth.signInWithPopup(googleProvider);
        return true;
      }

      await _googleSignIn.signOut();
      final googleUser = await _googleSignIn.authenticate();
      final googleAuth = googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        idToken: googleAuth.idToken,
      );
      await _auth.signInWithCredential(credential);
      return true;
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

  @override
  Future<bool> signInWithEmailAndPassword(String email, String password) async {
    final performance = getIt<PerformanceService>();
    final trace = performance.startTrace('auth_sign_in_email');
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      return true;
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

  @override
  Future<bool> signUpWithEmailAndPassword(String email, String password) async {
    final performance = getIt<PerformanceService>();
    final trace = performance.startTrace('auth_sign_up_email');
    try {
      await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      return true;
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

  @override
  Future<bool> updateUserName(String newName) async {
    try {
      await _auth.currentUser?.updateDisplayName(newName);
      await _auth.currentUser?.reload();
      return true;
    } on Exception catch (e, stackTrace) {
      getIt<CrashService>().recordError(
        e,
        stackTrace,
        reason: 'AuthService updateUserName error',
      );
      return false;
    }
  }
}
