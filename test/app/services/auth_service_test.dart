import 'package:firebase_performance/firebase_performance.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:saver_expense_manager/app/app.dart';

class MockAuthRepository extends Mock implements AuthRepository;

class MockTrace extends Mock implements Trace;

class MockPerformanceService extends Mock implements PerformanceService;

class MockCrashService extends Mock implements CrashService;

class MockLocalStorageService extends Mock implements LocalStorageService;

void main() {
  late AuthService service;
  late MockAuthRepository mockRepository;
  late MockTrace mockTrace;
  late MockPerformanceService mockPerformanceService;
  late MockCrashService mockCrashService;
  late MockLocalStorageService mockLocalStorageService;

  setUpAll(() {
    registerFallbackValue(MockTrace());
  });

  setUp(() async {
    mockRepository = MockAuthRepository();
    mockTrace = MockTrace();
    mockPerformanceService = MockPerformanceService();
    mockCrashService = MockCrashService();
    mockLocalStorageService = MockLocalStorageService();

    await getIt.reset();
    getIt
      ..registerSingleton<PerformanceService>(mockPerformanceService)
      ..registerSingleton<CrashService>(mockCrashService)
      ..registerSingleton<LocalStorageService>(mockLocalStorageService);

    when(() => mockPerformanceService.startTrace(any<String>()))
        .thenReturn(mockTrace);
    when(() => mockPerformanceService.stopTrace(any<Trace>())).thenReturn(null);

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
      final result = await service.linkWithEmailPassword(
        email: 'e',
        password: 'p',
      );
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

    test('deleteAccount calls repository', () async {
      when(
        () => mockRepository.deleteAccount(
          onCloudFunctionError: any(named: 'onCloudFunctionError'),
        ),
      ).thenAnswer((_) async => true);
      final result = await service.deleteAccount();
      expect(result, isTrue);
      verify(
        () => mockRepository.deleteAccount(
          onCloudFunctionError: any(named: 'onCloudFunctionError'),
        ),
      ).called(1);
      verify(() => mockPerformanceService.startTrace('auth_delete_account'))
          .called(1);
      verify(() => mockPerformanceService.stopTrace(mockTrace)).called(1);
    });

    test('initialize records error and rethrows on exception', () async {
      when(() => mockRepository.initialize()).thenThrow(Exception('Init Fail'));

      await expectLater(() => service.initialize(), throwsException);

      verify(
        () => mockCrashService.recordError(
          any<Object>(),
          any<StackTrace?>(),
          reason: 'AuthService initialize error',
        ),
      ).called(1);
    });

    test('signOut clears recommendations for currentUser', () async {
      when(() => mockRepository.currentUser)
          .thenReturn(const AppUser(uid: 'user123'));
      when(() => mockRepository.signOut()).thenAnswer((_) async => true);

      final result = await service.signOut();

      expect(result, isTrue);
      verify(
        () => mockLocalStorageService.clearRecommendations(userId: 'user123'),
      ).called(1);
    });

    test('deleteAccount clears recommendations for currentUser', () async {
      when(() => mockRepository.currentUser)
          .thenReturn(const AppUser(uid: 'user123'));
      when(
        () => mockRepository.deleteAccount(
          onCloudFunctionError: any(named: 'onCloudFunctionError'),
        ),
      ).thenAnswer((invocation) async {
        final onError =
            invocation.namedArguments[#onCloudFunctionError]
                as void Function(Object, StackTrace)?;
        onError?.call(Exception('CF fail'), StackTrace.current);
        return true;
      });

      final result = await service.deleteAccount();

      expect(result, isTrue);
      verify(
        () => mockLocalStorageService.clearRecommendations(userId: 'user123'),
      ).called(1);
      verify(
        () => mockCrashService.recordError(
          any<Object>(),
          any<StackTrace?>(),
          reason: 'AuthService deleteAccount cloud function fallback',
        ),
      ).called(1);
    });

    test('signIn and signUp record performance traces', () async {
      when(() => mockRepository.signInWithGoogle())
          .thenAnswer((_) async => true);
      when(
        () => mockRepository.signInWithEmailAndPassword(
          any<String>(),
          any<String>(),
        ),
      ).thenAnswer((_) async => true);
      when(
        () => mockRepository.signUpWithEmailAndPassword(
          any<String>(),
          any<String>(),
        ),
      ).thenAnswer((_) async => true);

      await service.signInWithGoogle();
      await service.signInWithEmailAndPassword('e', 'p');
      await service.signUpWithEmailAndPassword('e', 'p');

      verify(() => mockPerformanceService.startTrace('auth_sign_in_google'))
          .called(1);
      verify(() => mockPerformanceService.startTrace('auth_sign_in_email'))
          .called(1);
      verify(() => mockPerformanceService.startTrace('auth_sign_up_email'))
          .called(1);
      verify(() => mockPerformanceService.stopTrace(mockTrace)).called(3);
    });

    test(
      'all auth methods record errors and return false on exception',
      () async {
        when(() => mockRepository.updateDisplayName(any<String>()))
            .thenThrow(Exception('Fail'));
        when(() => mockRepository.signOut()).thenThrow(Exception('Fail'));
        when(() => mockRepository.unlinkProvider(any<String>()))
            .thenThrow(Exception('Fail'));
        when(() => mockRepository.reloadUser()).thenThrow(Exception('Fail'));
        when(() => mockRepository.linkWithGoogle())
            .thenThrow(Exception('Fail'));
        when(
          () => mockRepository.linkWithEmailPassword(
            email: any<String>(named: 'email'),
            password: any<String>(named: 'password'),
          ),
        ).thenThrow(Exception('Fail'));
        when(() => mockRepository.signInWithGoogle())
            .thenThrow(Exception('Fail'));
        when(
          () => mockRepository.signInWithEmailAndPassword(
            any<String>(),
            any<String>(),
          ),
        ).thenThrow(Exception('Fail'));
        when(
          () => mockRepository.signUpWithEmailAndPassword(
            any<String>(),
            any<String>(),
          ),
        ).thenThrow(Exception('Fail'));
        when(() => mockRepository.updateUserName(any<String>()))
            .thenThrow(Exception('Fail'));
        when(
          () => mockRepository.deleteAccount(
            onCloudFunctionError: any(named: 'onCloudFunctionError'),
          ),
        ).thenThrow(Exception('Fail'));

        expect(await service.updateDisplayName('name'), isFalse);
        expect(await service.signOut(), isFalse);
        expect(await service.unlinkProvider('provider'), isFalse);
        expect(await service.reloadUser(), isFalse);
        expect(await service.linkWithGoogle(), isFalse);
        expect(
          await service.linkWithEmailPassword(email: 'e', password: 'p'),
          isFalse,
        );
        expect(await service.signInWithGoogle(), isFalse);
        expect(await service.signInWithEmailAndPassword('e', 'p'), isFalse);
        expect(await service.signUpWithEmailAndPassword('e', 'p'), isFalse);
        expect(await service.updateUserName('name'), isFalse);
        expect(await service.deleteAccount(), isFalse);

        verify(
          () => mockCrashService.recordError(
            any<Object>(),
            any<StackTrace?>(),
            reason: any<dynamic>(named: 'reason'),
          ),
        ).called(11);
        verify(() => mockPerformanceService.stopTrace(mockTrace)).called(4);
      },
    );
  });
}
