import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:mocktail/mocktail.dart';
import 'package:saver_expense_manager/app/app.dart';
import 'package:saver_expense_manager/firebase_options.dart';

class MockFirebaseAuth extends Mock implements FirebaseAuth {}

class MockGoogleSignIn extends Mock implements GoogleSignIn {}

class MockUser extends Mock implements User {}

class MockUserCredential extends Mock implements UserCredential {}

class MockGoogleSignInAccount extends Mock implements GoogleSignInAccount {}

class MockGoogleSignInAuthentication extends Mock
    implements GoogleSignInAuthentication {}

void main() {
  late AuthenticationService authenticationService;
  late MockFirebaseAuth mockFirebaseAuth;
  late MockGoogleSignIn mockGoogleSignIn;
  late MockUser mockUser;

  setUp(() {
    mockFirebaseAuth = MockFirebaseAuth();
    mockGoogleSignIn = MockGoogleSignIn();
    mockUser = MockUser();

    when(() => mockFirebaseAuth.currentUser).thenReturn(mockUser);

    authenticationService = AuthenticationService(
      firebaseAuth: mockFirebaseAuth,
      googleSignIn: mockGoogleSignIn,
    );
  });

  setUpAll(() {
    registerFallbackValue(
      const AuthCredential(
        providerId: 'google.com',
        signInMethod: 'google.com',
      ),
    );
  });

  group('AuthenticationService', () {
    test('auth returns FirebaseAuth instance', () {
      expect(authenticationService.auth, mockFirebaseAuth);
    });

    test('isLoggedIn returns true when currentUser is not null', () {
      when(() => mockFirebaseAuth.currentUser).thenReturn(mockUser);
      when(() => mockUser.uid).thenReturn('123');
      when(() => mockUser.displayName).thenReturn('User');
      when(() => mockUser.email).thenReturn('user@example.com');
      when(() => mockUser.photoURL).thenReturn('url');
      when(() => mockUser.providerData).thenReturn(<UserInfo>[]);

      expect(authenticationService.isLoggedIn, isTrue);
    });

    test('isLoggedIn returns false when currentUser is null', () {
      when(() => mockFirebaseAuth.currentUser).thenReturn(null);
      expect(authenticationService.isLoggedIn, isFalse);
    });

    test('updateDisplayName calls updateDisplayName and reload on user',
        () async {
      when(() => mockUser.updateDisplayName(any())).thenAnswer((_) async {});
      when(() => mockUser.reload()).thenAnswer((_) async {});

      await authenticationService.updateDisplayName('New Name');

      verify(() => mockUser.updateDisplayName('New Name')).called(1);
      verify(() => mockUser.reload()).called(1);
    });

    test('signOut calls signOut on FirebaseAuth', () async {
      when(() => mockFirebaseAuth.signOut()).thenAnswer((_) async {});

      await authenticationService.signOut();

      verify(() => mockFirebaseAuth.signOut()).called(1);
    });

    test('unlinkProvider calls unlink and reload', () async {
      when(() => mockUser.unlink(any())).thenAnswer((_) async => mockUser);
      when(() => mockUser.reload()).thenAnswer((_) async {});

      await authenticationService.unlinkProvider('google.com');

      verify(() => mockUser.unlink('google.com')).called(1);
      verify(() => mockUser.reload()).called(1);
    });

    test('reloadUser calls reload on currentUser', () async {
      when(() => mockUser.reload()).thenAnswer((_) async {});

      await authenticationService.reloadUser();

      verify(() => mockUser.reload()).called(1);
    });

    test('signInWithEmailAndPassword calls FirebaseAuth', () async {
      final mockCredential = MockUserCredential();
      when(
        () => mockFirebaseAuth.signInWithEmailAndPassword(
          email: 'test@example.com',
          password: 'password123',
        ),
      ).thenAnswer((_) async => mockCredential);

      final result = await authenticationService.signInWithEmailAndPassword(
        'test@example.com',
        'password123',
      );

      expect(result, mockCredential);
      verify(
        () => mockFirebaseAuth.signInWithEmailAndPassword(
          email: 'test@example.com',
          password: 'password123',
        ),
      ).called(1);
    });

    test('initialize calls GoogleSignIn.initialize', () async {
      when(
        () => mockGoogleSignIn.initialize(
          serverClientId: any(named: 'serverClientId'),
        ),
      ).thenAnswer((_) async {});

      await authenticationService.initialize();

      verify(
        () => mockGoogleSignIn.initialize(
          serverClientId: DefaultFirebaseOptions.googleClientId,
        ),
      ).called(1);
    });

    test('initialize rethrows exceptions', () async {
      when(
        () => mockGoogleSignIn.initialize(
          serverClientId: any(named: 'serverClientId'),
        ),
      ).thenThrow(Exception('init failed'));

      expect(
        () => authenticationService.initialize(),
        throwsA(isA<Exception>()),
      );
    });

    test('userChanges emits mapped AppUser', () {
      when(() => mockFirebaseAuth.userChanges())
          .thenAnswer((_) => Stream.value(mockUser));
      when(() => mockUser.uid).thenReturn('123');
      when(() => mockUser.displayName).thenReturn('User');
      when(() => mockUser.email).thenReturn('user@example.com');
      when(() => mockUser.photoURL).thenReturn('url');
      when(() => mockUser.providerData).thenReturn(<UserInfo>[]);

      expect(
        authenticationService.userChanges,
        emits(isA<AppUser>()),
      );
    });

    test('userChanges emits null when user is null', () {
      when(() => mockFirebaseAuth.userChanges())
          .thenAnswer((_) => Stream.value(null));

      expect(
        authenticationService.userChanges,
        emits(isNull),
      );
    });

    test('authStateChanges emits mapped AppUser', () {
      when(() => mockFirebaseAuth.authStateChanges())
          .thenAnswer((_) => Stream.value(mockUser));
      when(() => mockUser.uid).thenReturn('123');
      when(() => mockUser.displayName).thenReturn('User');
      when(() => mockUser.email).thenReturn('user@example.com');
      when(() => mockUser.photoURL).thenReturn('url');
      when(() => mockUser.providerData).thenReturn(<UserInfo>[]);

      expect(
        authenticationService.authStateChanges,
        emits(isA<AppUser>()),
      );
    });

    test('currentUser returns mapped AppUser', () {
      when(() => mockFirebaseAuth.currentUser).thenReturn(mockUser);
      when(() => mockUser.uid).thenReturn('123');
      when(() => mockUser.displayName).thenReturn('User');
      when(() => mockUser.email).thenReturn('user@example.com');
      when(() => mockUser.photoURL).thenReturn('url');
      when(() => mockUser.providerData).thenReturn(<UserInfo>[]);

      expect(authenticationService.currentUser, isA<AppUser>());
    });

    test('currentUser returns null when no user', () {
      when(() => mockFirebaseAuth.currentUser).thenReturn(null);

      expect(authenticationService.currentUser, isNull);
    });

    test('linkWithEmailPassword calls user.linkWithCredential', () async {
      final mockCredential = MockUserCredential();
      when(() => mockFirebaseAuth.currentUser).thenReturn(mockUser);
      when(() => mockUser.linkWithCredential(any()))
          .thenAnswer((_) async => mockCredential);

      final result = await authenticationService.linkWithEmailPassword(
        email: 'test@example.com',
        password: 'password123',
      );

      expect(result, mockCredential);
      verify(() => mockUser.linkWithCredential(any())).called(1);
    });

    test('linkWithGoogle calls user.linkWithCredential via GoogleSignIn',
        () async {
      final mockGoogleUser = MockGoogleSignInAccount();
      final mockGoogleAuth = MockGoogleSignInAuthentication();
      final mockUserCredential = MockUserCredential();

      when(() => mockGoogleSignIn.authenticate())
          .thenAnswer((_) async => mockGoogleUser);
      when(() => mockGoogleUser.authentication).thenReturn(mockGoogleAuth);
      when(() => mockGoogleAuth.idToken).thenReturn('dummy_token');
      when(() => mockFirebaseAuth.currentUser).thenReturn(mockUser);
      when(() => mockUser.linkWithCredential(any()))
          .thenAnswer((_) async => mockUserCredential);

      final result = await authenticationService.linkWithGoogle();

      expect(result, mockUserCredential);
      verify(() => mockGoogleSignIn.authenticate()).called(1);
      verify(() => mockUser.linkWithCredential(any())).called(1);
    });

    test('linkWithGoogle rethrows on error', () async {
      when(() => mockGoogleSignIn.authenticate())
          .thenThrow(Exception('Google Sign In Failed'));

      expect(
        () => authenticationService.linkWithGoogle(),
        throwsA(isA<Exception>()),
      );
    });

    test('signInWithGoogle calls signInWithCredential via GoogleSignIn',
        () async {
      final mockGoogleUser = MockGoogleSignInAccount();
      final mockGoogleAuth = MockGoogleSignInAuthentication();
      final mockUserCredential = MockUserCredential();

      when(() => mockGoogleSignIn.authenticate())
          .thenAnswer((_) async => mockGoogleUser);
      when(() => mockGoogleUser.authentication).thenReturn(mockGoogleAuth);
      when(() => mockGoogleAuth.idToken).thenReturn('dummy_token');
      when(() => mockFirebaseAuth.signInWithCredential(any()))
          .thenAnswer((_) async => mockUserCredential);

      final result = await authenticationService.signInWithGoogle();

      expect(result, mockUserCredential);
      verify(() => mockGoogleSignIn.authenticate()).called(1);
      verify(() => mockFirebaseAuth.signInWithCredential(any())).called(1);
    });

    test('signInWithGoogle rethrows on error', () async {
      when(() => mockGoogleSignIn.authenticate())
          .thenThrow(Exception('Google Sign In Failed'));

      expect(
        () => authenticationService.signInWithGoogle(),
        throwsA(isA<Exception>()),
      );
    });

    test('signUpWithEmailAndPassword calls FirebaseAuth', () async {
      final mockCredential = MockUserCredential();
      when(
        () => mockFirebaseAuth.createUserWithEmailAndPassword(
          email: 'test@example.com',
          password: 'password123',
        ),
      ).thenAnswer((_) async => mockCredential);

      final result = await authenticationService.signUpWithEmailAndPassword(
        'test@example.com',
        'password123',
      );

      expect(result, mockCredential);
      verify(
        () => mockFirebaseAuth.createUserWithEmailAndPassword(
          email: 'test@example.com',
          password: 'password123',
        ),
      ).called(1);
    });
  });
}
