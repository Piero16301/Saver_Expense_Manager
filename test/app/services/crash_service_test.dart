import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:saver_expense_manager/app/app.dart';

class MockFirebaseCrashlytics extends Mock implements CrashRepository {}

void main() {
  group('CrashService', () {
    late CrashService crashService;
    late MockFirebaseCrashlytics mockCrashlytics;

    setUp(() {
      mockCrashlytics = MockFirebaseCrashlytics();
      crashService = CrashService(crashRepository: mockCrashlytics);
    });

    test('recordError calls FirebaseCrashlytics.recordError', () {
      when(
        () => mockCrashlytics.recordError(
          any<dynamic>(),
          any<StackTrace?>(),
          reason: any<dynamic>(named: 'reason'),
          information: any<Iterable<Object>>(named: 'information'),
          fatal: any<bool>(named: 'fatal'),
        ),
      ).thenAnswer((_) async {});

      final exception = Exception('Test Exception');
      final stackTrace = StackTrace.current;

      crashService.recordError(
        exception,
        stackTrace,
        reason: 'Testing',
        fatal: true,
      );

      verify(
        () => mockCrashlytics.recordError(
          exception,
          stackTrace,
          reason: 'Testing',
          fatal: true,
        ),
      ).called(1);
    });

    test('log calls FirebaseCrashlytics.log', () {
      when(() => mockCrashlytics.log(any<String>())).thenAnswer((_) async {});

      crashService.log('test log');

      verify(() => mockCrashlytics.log('test log')).called(1);
    });

    test('setCustomKey calls FirebaseCrashlytics.setCustomKey', () {
      when(
        () => mockCrashlytics.setCustomKey(any<String>(), any<Object>()),
      ).thenAnswer((_) async {});

      crashService.setCustomKey('key', 'value');

      verify(() => mockCrashlytics.setCustomKey('key', 'value')).called(1);
    });

    test('setUserIdentifier calls FirebaseCrashlytics.setUserIdentifier', () {
      when(
        () => mockCrashlytics.setUserIdentifier(any<String>()),
      ).thenAnswer((_) async {});

      crashService.setUserIdentifier('user123');

      verify(() => mockCrashlytics.setUserIdentifier('user123')).called(1);
    });
  });
}
