import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:saver_expense_manager/app/app.dart';

class MockFirebaseRemoteConfig extends Mock implements FirebaseRemoteConfig {}

class MockCrashService extends Mock implements CrashService {}

class FakeRemoteConfigSettings extends Fake implements RemoteConfigSettings {}

void main() {
  late MockFirebaseRemoteConfig mockRemoteConfig;
  late MockCrashService mockCrashService;
  late FirebaseRemoteConfigRepository repository;

  setUpAll(() {
    registerFallbackValue(FakeRemoteConfigSettings());
  });

  setUp(() async {
    mockRemoteConfig = MockFirebaseRemoteConfig();
    mockCrashService = MockCrashService();

    await getIt.reset();
    getIt.registerSingleton<CrashService>(mockCrashService);

    repository = FirebaseRemoteConfigRepository(remoteConfig: mockRemoteConfig);
  });

  group('MockRemoteConfigRepository', () {
    test('Mock tests for coverage', () async {
      final mock = MockRemoteConfigRepository();
      await mock.initialize();
      expect(mock.homeInitialTab, equals('movimientos'));
      expect(mock.geminiModelId, equals('gemini-3-flash-preview'));
      expect(mock.geminiPromptExtractReceiptData, isNotEmpty);
      expect(mock.geminiPromptDetectAntExpense, isNotEmpty);
      expect(mock.geminiAntLookbackDays, equals(30));
      expect(mock.paginationLimit, equals(10));
    });
  });

  group('FirebaseRemoteConfigRepository', () {
    test(
        'initialize calls setDefaults, setConfigSettings, and fetchAndActivate',
        () async {
      when(() => mockRemoteConfig.setDefaults(any<Map<String, dynamic>>()))
          .thenAnswer((_) async {});
      when(() =>
              mockRemoteConfig.setConfigSettings(any<RemoteConfigSettings>()),)
          .thenAnswer((_) async {});
      when(() => mockRemoteConfig.fetchAndActivate())
          .thenAnswer((_) async => true);

      await repository.initialize();

      verify(() => mockRemoteConfig.setDefaults(any<Map<String, dynamic>>()))
          .called(1);
      verify(() =>
              mockRemoteConfig.setConfigSettings(any<RemoteConfigSettings>()),)
          .called(1);
      verify(() => mockRemoteConfig.fetchAndActivate()).called(1);
    });

    test('initialize records error on failure but does not rethrow', () async {
      when(() => mockRemoteConfig.setDefaults(any<Map<String, dynamic>>()))
          .thenAnswer((_) async {});
      when(() =>
              mockRemoteConfig.setConfigSettings(any<RemoteConfigSettings>()),)
          .thenThrow(Exception('Config Fail'));

      await repository.initialize();

      await Future<void>.delayed(Duration.zero);
      verify(() => mockCrashService.recordError(
          any<Object>(), any<StackTrace?>(),
          reason: any<dynamic>(named: 'reason'),),).called(1);
    });

    test('getters return correct values from remote config', () {
      when(() => mockRemoteConfig.getString(any<String>())).thenReturn('value');
      when(() => mockRemoteConfig.getInt(any<String>())).thenReturn(123);

      expect(repository.homeInitialTab, equals('value'));
      expect(repository.geminiModelId, equals('value'));
      expect(repository.geminiPromptExtractReceiptData, equals('value'));
      expect(repository.geminiPromptDetectAntExpense, equals('value'));
      expect(repository.geminiAntLookbackDays, equals(123));
      expect(repository.paginationLimit, equals(123));

      verify(() => mockRemoteConfig.getString(any<String>())).called(4);
      verify(() => mockRemoteConfig.getInt(any<String>())).called(2);
    });
  });
}
