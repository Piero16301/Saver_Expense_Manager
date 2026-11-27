import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
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
  Future<bool> deleteAccount({
    void Function(Object error, StackTrace stackTrace)? onCloudFunctionError,
  });
}

class MockAuthRepository implements AuthRepository {
  new({AppUser? initialUser = defaultUser}) : _currentUser = initialUser;

  static const AppUser defaultUser = AppUser(
    uid: '1',
    email: 'demo@saver.app',
    displayName: 'Saver Demo',
    providerData: [
      AppUserInfo(
        uid: '1',
        providerId: AppVariables.emailProvider,
        email: 'demo@saver.app',
        displayName: 'Saver Demo',
      ),
    ],
  );

  final StreamController<AppUser?> _controller =
      StreamController<AppUser?>.broadcast();
  AppUser? _currentUser;
  String _lastDisplayName = 'Saver Demo';

  void _emitUser(AppUser? user) {
    _currentUser = user;
    if (user?.displayName != null && user!.displayName!.isNotEmpty) {
      _lastDisplayName = user.displayName!;
    }
    if (!_controller.isClosed) {
      _controller.add(user);
    }
  }

  @override
  Future<void> initialize() async {}

  @override
  Stream<AppUser?> get userChanges async* {
    yield _currentUser;
    yield* _controller.stream;
  }

  @override
  Stream<AppUser?> get authStateChanges async* {
    yield _currentUser;
    yield* _controller.stream;
  }

  @override
  AppUser? get currentUser => _currentUser;

  @override
  bool get isLoggedIn => _currentUser != null;

  @override
  Future<bool> updateDisplayName(String newName) async {
    final user = _currentUser;
    if (user == null) return false;
    final updatedProviders = user.providerData
        .map(
          (p) => AppUserInfo(
            uid: p.uid,
            providerId: p.providerId,
            email: p.email,
            displayName: newName,
            photoURL: p.photoURL,
            phoneNumber: p.phoneNumber,
          ),
        )
        .toList();
    _emitUser(
      AppUser(
        uid: user.uid,
        email: user.email,
        displayName: newName,
        photoURL: user.photoURL,
        phoneNumber: user.phoneNumber,
        providerData: updatedProviders,
      ),
    );
    return true;
  }

  @override
  Future<bool> signOut() async {
    _emitUser(null);
    return true;
  }

  @override
  Future<bool> unlinkProvider(String providerId) async {
    final user = _currentUser;
    if (user == null) return false;
    final updatedProviders = user.providerData
        .where((p) => p.providerId != providerId)
        .toList();
    _emitUser(
      AppUser(
        uid: user.uid,
        email: user.email,
        displayName: user.displayName,
        photoURL: user.photoURL,
        phoneNumber: user.phoneNumber,
        providerData: updatedProviders,
      ),
    );
    return true;
  }

  @override
  Future<bool> reloadUser() async {
    _emitUser(_currentUser);
    return true;
  }

  @override
  Future<bool> linkWithGoogle() async {
    final user = _currentUser;
    if (user == null) return false;
    final hasGoogle = user.providerData.any(
      (p) => p.providerId == AppVariables.googleProvider,
    );
    if (!hasGoogle) {
      final updatedProviders = List<AppUserInfo>.from(user.providerData)
        ..add(
          AppUserInfo(
            uid: user.uid,
            providerId: AppVariables.googleProvider,
            email: user.email ?? 'demo.google@saver.app',
            displayName: user.displayName ?? _lastDisplayName,
          ),
        );
      _emitUser(
        AppUser(
          uid: user.uid,
          email: user.email,
          displayName: user.displayName,
          photoURL: user.photoURL,
          phoneNumber: user.phoneNumber,
          providerData: updatedProviders,
        ),
      );
    }
    return true;
  }

  @override
  Future<bool> linkWithEmailPassword({
    required String email,
    required String password,
  }) async {
    final user = _currentUser;
    if (user == null) return false;
    final hasEmail = user.providerData.any(
      (p) => p.providerId == AppVariables.emailProvider,
    );
    if (!hasEmail) {
      final updatedProviders = List<AppUserInfo>.from(user.providerData)
        ..add(
          AppUserInfo(
            uid: user.uid,
            providerId: AppVariables.emailProvider,
            email: email,
            displayName: user.displayName ?? _lastDisplayName,
          ),
        );
      _emitUser(
        AppUser(
          uid: user.uid,
          email: user.email ?? email,
          displayName: user.displayName,
          photoURL: user.photoURL,
          phoneNumber: user.phoneNumber,
          providerData: updatedProviders,
        ),
      );
    }
    return true;
  }

  @override
  Future<bool> signInWithGoogle() async {
    _emitUser(
      AppUser(
        uid: '1',
        email: 'demo.google@saver.app',
        displayName: _lastDisplayName,
        providerData: [
          AppUserInfo(
            uid: '1',
            providerId: AppVariables.googleProvider,
            email: 'demo.google@saver.app',
            displayName: _lastDisplayName,
          ),
        ],
      ),
    );
    return true;
  }

  @override
  Future<bool> signInWithEmailAndPassword(String email, String password) async {
    _emitUser(
      AppUser(
        uid: '1',
        email: email,
        displayName: _lastDisplayName,
        providerData: [
          AppUserInfo(
            uid: '1',
            providerId: AppVariables.emailProvider,
            email: email,
            displayName: _lastDisplayName,
          ),
        ],
      ),
    );
    return true;
  }

  @override
  Future<bool> signUpWithEmailAndPassword(String email, String password) async {
    _emitUser(
      AppUser(
        uid: '1',
        email: email,
        displayName: _lastDisplayName,
        providerData: [
          AppUserInfo(
            uid: '1',
            providerId: AppVariables.emailProvider,
            email: email,
            displayName: _lastDisplayName,
          ),
        ],
      ),
    );
    return true;
  }

  @override
  Future<bool> updateUserName(String newName) => updateDisplayName(newName);

  @override
  Future<bool> deleteAccount({
    void Function(Object error, StackTrace stackTrace)? onCloudFunctionError,
  }) async {
    _emitUser(null);
    return true;
  }
}

class FirebaseAuthRepository implements AuthRepository {
  new({FirebaseAuth? auth, GoogleSignIn? googleSignIn, http.Client? httpClient})
    : _auth = auth ?? FirebaseAuth.instance,
      _googleSignIn = googleSignIn ?? GoogleSignIn.instance,
      _httpClient = httpClient ?? http.Client();

  final FirebaseAuth _auth;
  final GoogleSignIn _googleSignIn;
  final http.Client _httpClient;

  @override
  Future<void> initialize() async {
    if (kIsWeb) {
      return;
    }
    await _googleSignIn.initialize(
      serverClientId: DefaultFirebaseOptions.googleClientId,
    );
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
    await _auth.currentUser?.updateDisplayName(newName);
    await _auth.currentUser?.reload();
    return true;
  }

  @override
  Future<bool> signOut() async {
    await _auth.signOut();
    return true;
  }

  @override
  Future<bool> unlinkProvider(String providerId) async {
    await _auth.currentUser?.unlink(providerId);
    await _auth.currentUser?.reload();
    return true;
  }

  @override
  Future<bool> reloadUser() async {
    await _auth.currentUser?.reload();
    return true;
  }

  @override
  Future<bool> linkWithGoogle() async {
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
  }

  @override
  Future<bool> linkWithEmailPassword({
    required String email,
    required String password,
  }) async {
    final credential = EmailAuthProvider.credential(
      email: email,
      password: password,
    );
    await _auth.currentUser?.linkWithCredential(credential);
    return true;
  }

  @override
  Future<bool> signInWithGoogle() async {
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
  }

  @override
  Future<bool> signInWithEmailAndPassword(String email, String password) async {
    await _auth.signInWithEmailAndPassword(email: email, password: password);
    return true;
  }

  @override
  Future<bool> signUpWithEmailAndPassword(String email, String password) async {
    await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    return true;
  }

  @override
  Future<bool> updateUserName(String newName) async {
    await _auth.currentUser?.updateDisplayName(newName);
    await _auth.currentUser?.reload();
    return true;
  }

  @override
  Future<bool> deleteAccount({
    void Function(Object error, StackTrace stackTrace)? onCloudFunctionError,
  }) async {
    final user = _auth.currentUser;

    // 1. Invocar Cloud Function (2ª Gen)
    if (user != null) {
      try {
        final idToken = await user.getIdToken();
        if (idToken != null) {
          final response = await _httpClient
              .post(
                Uri.parse(AppVariables.deleteUserAccountFunctionUrl),
                headers: {
                  'Authorization': 'Bearer $idToken',
                  'Content-Type': 'application/json',
                },
              )
              .timeout(AppVariables.timeoutDuration);

          if (response.statusCode == 200) {
            await _auth.signOut();
            return true;
          }
        }
      } on Object catch (e, stackTrace) {
        onCloudFunctionError?.call(e, stackTrace);
        // Si la Cloud Function aún no está disponible o falla por red,
        // se procede al borrado directo de cuenta en Firebase Auth como
        // fallback.
      }
    }

    await _auth.currentUser?.delete();
    return true;
  }
}
