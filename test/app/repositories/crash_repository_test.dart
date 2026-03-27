import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:saver_expense_manager/app/repositories/crash_repository.dart';

class MockFirebaseCrashlytics extends Mock implements FirebaseCrashlytics {}

void main() {
  late MockFirebaseCrashlytics mockCrashlytics;
  late CrashlyticsCrashRepository repository;

  setUp(() {
    mockCrashlytics = MockFirebaseCrashlytics();
    repository = CrashlyticsCrashRepository(crashlytics: mockCrashlytics);
  });

  group('MockCrashRepository', () {
    test('does nothing on all methods', () {
      final _ = MockCrashRepository()
        ..log('test')
        ..recordError(Exception(), null)
        ..setCustomKey('key', 'value')
        ..setUserIdentifier('id');
    });
  });

  group('CrashlyticsCrashRepository', () {
    test('log calls _crashlytics.log', () async {
      when(() => mockCrashlytics.log(any<String>())).thenAnswer((_) async {});
      repository.log('test_log');
      await Future<void>.delayed(Duration.zero);
      verify(() => mockCrashlytics.log('test_log')).called(1);
    });

    test('recordError calls _crashlytics.recordError', () async {
      final exception = Exception('test');
      final stackTrace = StackTrace.current;
      when(
        () => mockCrashlytics.recordError(
          any<dynamic>(),
          any<StackTrace?>(),
          reason: any<dynamic>(named: 'reason'),
          information: any<Iterable<Object>>(named: 'information'),
          fatal: any<bool>(named: 'fatal'),
        ),
      ).thenAnswer((_) async {});

      repository.recordError(exception, stackTrace, reason: 'test_reason');
      await Future<void>.delayed(Duration.zero);
      verify(
        () => mockCrashlytics.recordError(
          exception,
          stackTrace,
          reason: 'test_reason',
        ),
      ).called(1);
    });

    test('setCustomKey calls _crashlytics.setCustomKey', () async {
      when(() => mockCrashlytics.setCustomKey(any<String>(), any<Object>()))
          .thenAnswer((_) async {});
      repository.setCustomKey('key', 'value');
      await Future<void>.delayed(Duration.zero);
      verify(() => mockCrashlytics.setCustomKey('key', 'value')).called(1);
    });

    test('setUserIdentifier calls _crashlytics.setUserIdentifier', () async {
      when(() => mockCrashlytics.setUserIdentifier(any<String>()))
          .thenAnswer((_) async {});
      repository.setUserIdentifier('user_123');
      await Future<void>.delayed(Duration.zero);
      verify(() => mockCrashlytics.setUserIdentifier('user_123')).called(1);
    });
  });
}
