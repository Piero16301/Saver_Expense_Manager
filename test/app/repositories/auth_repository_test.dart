import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_performance/firebase_performance.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:mocktail/mocktail.dart';
import 'package:saver_expense_manager/app/app.dart';

class MockFirebaseAuth extends Mock implements FirebaseAuth {}

class MockGoogleSignIn extends Mock implements GoogleSignIn {}

class MockUser extends Mock implements User {}

class MockPerformanceService extends Mock implements PerformanceService {}

class MockTrace extends Mock implements Trace {}

class MockCrashService extends Mock implements CrashService {}

class MockAuthCredential extends Mock implements AuthCredential {}

class MockUserCredential extends Mock implements UserCredential {}

void main() {
  late MockFirebaseAuth mockAuth;
  late MockGoogleSignIn mockGoogleSignIn;
  late MockUser mockUser;
  late MockPerformanceService mockPerformanceService;
  late MockCrashService mockCrashService;
  late FirebaseAuthRepository repository;

  setUpAll(() {
    registerFallbackValue(MockAuthCredential());
    registerFallbackValue(MockTrace());
  });

  setUp(() async {
    mockAuth = MockFirebaseAuth();
    mockGoogleSignIn = MockGoogleSignIn();
    mockUser = MockUser();
    mockPerformanceService = MockPerformanceService();
    mockCrashService = MockCrashService();

    await getIt.reset();
    getIt
      ..registerSingleton<PerformanceService>(mockPerformanceService)
      ..registerSingleton<CrashService>(mockCrashService);

    final mockTrace = MockTrace();
    when(() => mockPerformanceService.startTrace(any<String>()))
        .thenReturn(mockTrace);
    when(() => mockPerformanceService.stopTrace(any<Trace>())).thenReturn(null);

    repository = FirebaseAuthRepository(
      auth: mockAuth,
      googleSignIn: mockGoogleSignIn,
    );
  });

  group('MockAuthRepository', () {
    test('Mock tests for coverage', () async {
      final mock = MockAuthRepository();
      await mock.initialize();
      expect(mock.currentUser, isNotNull);
      expect(mock.isLoggedIn, isTrue);
      expect(await mock.signOut(), isTrue);
      expect(await mock.updateDisplayName('name'), isTrue);
      expect(await mock.reloadUser(), isTrue);
      expect(await mock.linkWithGoogle(), isTrue);
      expect(
          await mock.linkWithEmailPassword(email: 'e', password: 'p'), isTrue,);
      expect(await mock.signInWithGoogle(), isTrue);
      expect(await mock.signInWithEmailAndPassword('e', 'p'), isTrue);
      expect(await mock.signUpWithEmailAndPassword('e', 'p'), isTrue);
      expect(await mock.updateUserName('name'), isTrue);
    });
  });

  group('FirebaseAuthRepository', () {
    test('initialize calls googleSignIn.initialize', () async {
      when(() => mockGoogleSignIn.initialize(
              serverClientId: any<String?>(named: 'serverClientId'),),)
          .thenAnswer((_) async {});
      await repository.initialize();
      verify(() => mockGoogleSignIn.initialize(
          serverClientId: any<String?>(named: 'serverClientId'),),).called(1);
    });

    test('updateDisplayName calls currentUser.updateDisplayName and reload',
        () async {
      when(() => mockAuth.currentUser).thenReturn(mockUser);
      when(() => mockUser.updateDisplayName(any<String?>()))
          .thenAnswer((_) async {});
      when(() => mockUser.reload()).thenAnswer((_) async {});

      final result = await repository.updateDisplayName('New Name');

      expect(result, isTrue);
      verify(() => mockUser.updateDisplayName('New Name')).called(1);
      verify(() => mockUser.reload()).called(1);
    });

    test('signOut calls auth.signOut', () async {
      when(() => mockAuth.signOut()).thenAnswer((_) async {});
      final result = await repository.signOut();
      expect(result, isTrue);
      verify(() => mockAuth.signOut()).called(1);
    });

    test('reloadUser calls currentUser.reload', () async {
      when(() => mockAuth.currentUser).thenReturn(mockUser);
      when(() => mockUser.reload()).thenAnswer((_) async {});
      final result = await repository.reloadUser();
      expect(result, isTrue);
      verify(() => mockUser.reload()).called(1);
    });

    test('signInWithEmailAndPassword calls auth.signInWithEmailAndPassword',
        () async {
      when(() => mockAuth.signInWithEmailAndPassword(
              email: any<String>(named: 'email'),
              password: any<String>(named: 'password'),),)
          .thenAnswer((_) async => MockUserCredential());

      final result =
          await repository.signInWithEmailAndPassword('test@test.com', 'p123');

      expect(result, isTrue);
      verify(() => mockAuth.signInWithEmailAndPassword(
          email: 'test@test.com', password: 'p123',),).called(1);
    });

    test('signUpWithEmailAndPassword calls auth.createUserWithEmailAndPassword',
        () async {
      when(() => mockAuth.createUserWithEmailAndPassword(
              email: any<String>(named: 'email'),
              password: any<String>(named: 'password'),),)
          .thenAnswer((_) async => MockUserCredential());

      final result =
          await repository.signUpWithEmailAndPassword('new@test.com', 'p123');

      expect(result, isTrue);
      verify(() => mockAuth.createUserWithEmailAndPassword(
          email: 'new@test.com', password: 'p123',),).called(1);
    });

    test('updateUserName calls currentUser.updateDisplayName', () async {
      when(() => mockAuth.currentUser).thenReturn(mockUser);
      when(() => mockUser.updateDisplayName(any<String?>()))
          .thenAnswer((_) async {});
      when(() => mockUser.reload()).thenAnswer((_) async {});
      final result = await repository.updateUserName('Updated');
      expect(result, isTrue);
      verify(() => mockUser.updateDisplayName('Updated')).called(1);
    });

    test('isLoggedIn returns correct value based on currentUser', () {
      when(() => mockAuth.currentUser).thenReturn(null);
      expect(repository.isLoggedIn, isFalse);
      when(() => mockAuth.currentUser).thenReturn(mockUser);
      // Mock properties of mockUser for conversion
      when(() => mockUser.uid).thenReturn('uid');
      when(() => mockUser.email).thenReturn('e');
      when(() => mockUser.displayName).thenReturn('d');
      when(() => mockUser.photoURL).thenReturn('p');
      when(() => mockUser.phoneNumber).thenReturn('n');
      when(() => mockUser.providerData).thenReturn([]);
      expect(repository.isLoggedIn, isTrue);
    });

    test('linkWithEmailPassword calls currentUser.linkWithCredential',
        () async {
      when(() => mockAuth.currentUser).thenReturn(mockUser);
      when(() => mockUser.linkWithCredential(any<AuthCredential>()))
          .thenAnswer((_) async => MockUserCredential());

      final result = await repository.linkWithEmailPassword(
          email: 'e@t.com', password: 'p',);

      expect(result, isTrue);
      verify(() => mockUser.linkWithCredential(any<AuthCredential>()))
          .called(1);
    });
  });
}
