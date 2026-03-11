import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:saver_expense_manager/app/app.dart';

class MockFirebaseRemoteConfig extends Mock implements FirebaseRemoteConfig {}

void main() {
  late RemoteConfigService remoteConfigService;
  late MockFirebaseRemoteConfig mockRemoteConfig;

  setUp(() {
    mockRemoteConfig = MockFirebaseRemoteConfig();
    remoteConfigService = RemoteConfigService(remoteConfig: mockRemoteConfig);
  });

  setUpAll(() {
    registerFallbackValue(
      RemoteConfigSettings(
        fetchTimeout: const Duration(minutes: 1),
        minimumFetchInterval: const Duration(hours: 1),
      ),
    );
  });

  group('RemoteConfigService', () {
    test('initialize calls expected methods', () async {
      when(() => mockRemoteConfig.setDefaults(any())).thenAnswer((_) async {});
      when(() => mockRemoteConfig.setConfigSettings(any()))
          .thenAnswer((_) async {});
      when(() => mockRemoteConfig.fetchAndActivate())
          .thenAnswer((_) async => true);

      await remoteConfigService.initialize();

      verify(() => mockRemoteConfig.setDefaults(any())).called(1);
      verify(() => mockRemoteConfig.setConfigSettings(any())).called(1);
      verify(() => mockRemoteConfig.fetchAndActivate()).called(1);
    });

    test('initialize catches exceptions from fetchAndActivate', () async {
      when(() => mockRemoteConfig.setDefaults(any())).thenAnswer((_) async {});
      when(() => mockRemoteConfig.setConfigSettings(any()))
          .thenAnswer((_) async {});
      when(() => mockRemoteConfig.fetchAndActivate())
          .thenThrow(Exception('fetch failed'));

      await expectLater(remoteConfigService.initialize(), completes);
    });

    test('getters return correct values', () {
      when(() => mockRemoteConfig.getBool('ui_home_summary_cards_visible'))
          .thenReturn(true);
      when(() => mockRemoteConfig.getBool('ui_home_top_categories_visible'))
          .thenReturn(false);
      when(() => mockRemoteConfig.getString('ui_home_initial_tab'))
          .thenReturn('summary');
      when(() => mockRemoteConfig.getString('config_gemini_model_id'))
          .thenReturn('gemini-1');
      when(
        () => mockRemoteConfig.getString(
          'config_gemini_prompt_extract_receipt_data',
        ),
      ).thenReturn('prompt1');
      when(
        () => mockRemoteConfig.getString(
          'config_gemini_prompt_detect_ant_expense',
        ),
      ).thenReturn('prompt2');
      when(() => mockRemoteConfig.getInt('config_gemini_ant_lookback_days'))
          .thenReturn(30);

      expect(remoteConfigService.homeInitialTab, 'summary');
      expect(remoteConfigService.geminiModelId, 'gemini-1');
      expect(remoteConfigService.geminiPromptExtractReceiptData, 'prompt1');
      expect(remoteConfigService.geminiPromptDetectAntExpense, 'prompt2');
      expect(remoteConfigService.geminiAntLookbackDays, 30);
    });
  });
}
