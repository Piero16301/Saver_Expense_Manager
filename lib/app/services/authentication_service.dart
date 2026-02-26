import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:saver_expense_manager/app/models/models.dart';
import 'package:saver_expense_manager/firebase_options.dart';

class AuthenticationService {
  AuthenticationService({
    FirebaseAuth? firebaseAuth,
    GoogleSignIn? googleSignIn,
  })  : _auth = firebaseAuth ?? FirebaseAuth.instance,
        _googleSignIn = googleSignIn ?? GoogleSignIn.instance;

  final FirebaseAuth _auth;
  final GoogleSignIn _googleSignIn;

  FirebaseAuth get auth => _auth;

  Future<void> initialize() async {
    try {
      await _googleSignIn.initialize(
        serverClientId: DefaultFirebaseOptions.googleClientId,
      );
    } on Exception catch (_) {
      rethrow;
    }
  }

  Stream<AppUser?> get userChanges => _auth
      .userChanges()
      .map((u) => u == null ? null : AppUser.fromFirebaseUser(u));
  Stream<AppUser?> get authStateChanges => _auth
      .authStateChanges()
      .map((u) => u == null ? null : AppUser.fromFirebaseUser(u));
  AppUser? get currentUser => _auth.currentUser == null
      ? null
      : AppUser.fromFirebaseUser(_auth.currentUser!);
  bool get isLoggedIn => currentUser != null;

  Future<void> updateDisplayName(String newName) async {
    await _auth.currentUser?.updateDisplayName(newName);
    await _auth.currentUser?.reload();
  }

  Future<void> signOut() => _auth.signOut();

  Future<void> unlinkProvider(String providerId) async {
    await _auth.currentUser?.unlink(providerId);
    await _auth.currentUser?.reload();
  }

  Future<void> reloadUser() async {
    await _auth.currentUser?.reload();
  }

  Future<UserCredential?> linkWithGoogle() async {
    try {
      final googleUser = await _googleSignIn.authenticate();
      final googleAuth = googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        idToken: googleAuth.idToken,
      );
      return await _auth.currentUser?.linkWithCredential(credential);
    } catch (e) {
      rethrow;
    }
  }

  Future<UserCredential?> linkWithEmailPassword({
    required String email,
    required String password,
  }) async {
    final credential =
        EmailAuthProvider.credential(email: email, password: password);
    return await _auth.currentUser?.linkWithCredential(credential);
  }

  Future<UserCredential?> signInWithGoogle() async {
    try {
      final googleUser = await _googleSignIn.authenticate();
      final googleAuth = googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        idToken: googleAuth.idToken,
      );
      return await _auth.signInWithCredential(credential);
    } catch (e) {
      rethrow;
    }
  }

  Future<UserCredential> signInWithEmailAndPassword(
    String email,
    String password,
  ) async {
    return _auth.signInWithEmailAndPassword(email: email, password: password);
  }

  Future<UserCredential> signUpWithEmailAndPassword(
    String email,
    String password,
  ) async {
    return _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
  }
}
