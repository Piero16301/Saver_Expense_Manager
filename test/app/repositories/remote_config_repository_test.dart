import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:saver_expense_manager/app/app.dart';

class MockFirebaseRemoteConfig extends Mock implements FirebaseRemoteConfig;

class FakeRemoteConfigSettings extends Fake implements RemoteConfigSettings;

void main() {
  late MockFirebaseRemoteConfig mockRemoteConfig;
  late FirebaseRemoteConfigRepository repository;

  setUpAll(() {
    registerFallbackValue(FakeRemoteConfigSettings());
  });

  setUp(() {
    mockRemoteConfig = MockFirebaseRemoteConfig();

    repository = FirebaseRemoteConfigRepository(remoteConfig: mockRemoteConfig);
  });

  group('MockRemoteConfigRepository', () {
    test('Mock tests for coverage', () async {
      final mock = MockRemoteConfigRepository();
      await mock.initialize();
      expect(mock.homeInitialTab, equals('movimientos'));
      expect(mock.geminiModelName, equals('gemini-3.5-flash-lite'));
      expect(mock.geminiPromptExtractReceiptData, isNotEmpty);
      expect(mock.geminiPromptDetectAntExpense, isNotEmpty);
      expect(mock.geminiAntLookbackDays, equals(30));
      expect(mock.paginationLimit, equals(10));
      expect(mock.summaryLastMonths, equals(4));
    });
  });

  group('FirebaseRemoteConfigRepository', () {
    test(
      'initialize calls setDefaults, setConfigSettings, and fetchAndActivate',
      () async {
        when(() => mockRemoteConfig.setDefaults(any<Map<String, dynamic>>()))
            .thenAnswer((_) async {});
        when(
          () => mockRemoteConfig.setConfigSettings(any<RemoteConfigSettings>()),
        ).thenAnswer((_) async {});
        when(() => mockRemoteConfig.fetchAndActivate())
            .thenAnswer((_) async => true);

        await repository.initialize();

        verify(() => mockRemoteConfig.setDefaults(any<Map<String, dynamic>>()))
            .called(1);
        verify(
          () => mockRemoteConfig.setConfigSettings(any<RemoteConfigSettings>()),
        ).called(1);
        verify(() => mockRemoteConfig.fetchAndActivate()).called(1);
      },
    );

    test('initialize rethrows on failure', () async {
      when(() => mockRemoteConfig.setDefaults(any<Map<String, dynamic>>()))
          .thenAnswer((_) async {});
      when(
        () => mockRemoteConfig.setConfigSettings(any<RemoteConfigSettings>()),
      ).thenThrow(Exception('Config Fail'));

      await expectLater(() => repository.initialize(), throwsException);
    });

    test('getters return correct values from remote config', () {
      when(() => mockRemoteConfig.getString(any<String>())).thenReturn('value');
      when(() => mockRemoteConfig.getInt(any<String>())).thenReturn(123);

      expect(repository.homeInitialTab, equals('value'));
      expect(repository.geminiModelName, equals('value'));
      expect(repository.geminiPromptExtractReceiptData, equals('value'));
      expect(repository.geminiPromptDetectAntExpense, equals('value'));
      expect(repository.geminiAntLookbackDays, equals(123));
      expect(repository.paginationLimit, equals(123));
      expect(repository.summaryLastMonths, equals(123));

      verify(() => mockRemoteConfig.getString(any<String>())).called(4);
      verify(() => mockRemoteConfig.getInt(any<String>())).called(3);
    });
  });
}
