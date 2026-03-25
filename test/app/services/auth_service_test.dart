import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:saver_expense_manager/app/app.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late AuthService service;
  late MockAuthRepository mockRepository;

  setUp(() {
    mockRepository = MockAuthRepository();
    service = AuthService(authRepository: mockRepository);
  });

  group('AuthService', () {
    test('can be instantiated', () {
      expect(service, isNotNull);
    });
    test('initialize calls repository initialize', () async {
      when(() => mockRepository.initialize()).thenAnswer((_) async {});
      await service.initialize();
      verify(() => mockRepository.initialize()).called(1);
    });

    test('userChanges returns from repository', () {
      const stream = Stream<AppUser?>.empty();
      when(() => mockRepository.userChanges).thenAnswer((_) => stream);
      expect(service.userChanges, equals(stream));
    });

    test('authStateChanges returns from repository', () {
      const stream = Stream<AppUser?>.empty();
      when(() => mockRepository.authStateChanges).thenAnswer((_) => stream);
      expect(service.authStateChanges, equals(stream));
    });

    test('currentUser returns from repository', () {
      const user = AppUser(uid: '1');
      when(() => mockRepository.currentUser).thenReturn(user);
      expect(service.currentUser, equals(user));
    });

    test('isLoggedIn returns from repository', () {
      when(() => mockRepository.isLoggedIn).thenReturn(true);
      expect(service.isLoggedIn, isTrue);
    });

    test('updateDisplayName calls repository', () async {
      when(() => mockRepository.updateDisplayName(any<String>()))
          .thenAnswer((_) async => true);
      final result = await service.updateDisplayName('name');
      expect(result, isTrue);
      verify(() => mockRepository.updateDisplayName('name')).called(1);
    });

    test('signOut calls repository', () async {
      when(() => mockRepository.signOut()).thenAnswer((_) async => true);
      final result = await service.signOut();
      expect(result, isTrue);
      verify(() => mockRepository.signOut()).called(1);
    });

    test('unlinkProvider calls repository', () async {
      when(() => mockRepository.unlinkProvider(any<String>()))
          .thenAnswer((_) async => true);
      final result = await service.unlinkProvider('provider');
      expect(result, isTrue);
      verify(() => mockRepository.unlinkProvider('provider')).called(1);
    });

    test('reloadUser calls repository', () async {
      when(() => mockRepository.reloadUser()).thenAnswer((_) async => true);
      final result = await service.reloadUser();
      expect(result, isTrue);
      verify(() => mockRepository.reloadUser()).called(1);
    });

    test('linkWithGoogle calls repository', () async {
      when(() => mockRepository.linkWithGoogle()).thenAnswer((_) async => true);
      final result = await service.linkWithGoogle();
      expect(result, isTrue);
      verify(() => mockRepository.linkWithGoogle()).called(1);
    });

    test('linkWithEmailPassword calls repository', () async {
      when(
        () => mockRepository.linkWithEmailPassword(
          email: any<String>(named: 'email'),
          password: any<String>(named: 'password'),
        ),
      ).thenAnswer((_) async => true);
      final result =
          await service.linkWithEmailPassword(email: 'e', password: 'p');
      expect(result, isTrue);
      verify(
        () => mockRepository.linkWithEmailPassword(email: 'e', password: 'p'),
      ).called(1);
    });

    test('signInWithGoogle calls repository', () async {
      when(() => mockRepository.signInWithGoogle())
          .thenAnswer((_) async => true);
      final result = await service.signInWithGoogle();
      expect(result, isTrue);
      verify(() => mockRepository.signInWithGoogle()).called(1);
    });

    test('signInWithEmailAndPassword calls repository', () async {
      when(
        () => mockRepository.signInWithEmailAndPassword(
          any<String>(),
          any<String>(),
        ),
      ).thenAnswer((_) async => true);
      final result = await service.signInWithEmailAndPassword('e', 'p');
      expect(result, isTrue);
      verify(() => mockRepository.signInWithEmailAndPassword('e', 'p'))
          .called(1);
    });

    test('signUpWithEmailAndPassword calls repository', () async {
      when(
        () => mockRepository.signUpWithEmailAndPassword(
          any<String>(),
          any<String>(),
        ),
      ).thenAnswer((_) async => true);
      final result = await service.signUpWithEmailAndPassword('e', 'p');
      expect(result, isTrue);
      verify(() => mockRepository.signUpWithEmailAndPassword('e', 'p'))
          .called(1);
    });

    test('updateUserName calls repository', () async {
      when(() => mockRepository.updateUserName(any<String>()))
          .thenAnswer((_) async => true);
      final result = await service.updateUserName('name');
      expect(result, isTrue);
      verify(() => mockRepository.updateUserName('name')).called(1);
    });
  });
}
