import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/foundation.dart';
import 'package:saver_expense_manager/app/app.dart';

abstract class RemoteConfigRepository {
  /// CONFIG
  static const String configGeminiAntLookbackDays =
      'config_gemini_ant_lookback_days';
  static const String configGeminiModelName = 'config_gemini_model_name';
  static const String configGeminiPromptDetectAntExpense =
      'config_gemini_prompt_detect_ant_expense';
  static const String configGeminiPromptExtractReceiptData =
      'config_gemini_prompt_extract_receipt_data';
  static const String configPaginationLimit = 'config_pagination_limit';
  static const String configSummaryLastMonths = 'config_summary_last_months';

  /// UI
  static const String uiHomeInitialTab = 'ui_home_initial_tab';

  Future<void> initialize();

  int get geminiAntLookbackDays;
  String get geminiModelName;
  String get geminiPromptDetectAntExpense;
  String get geminiPromptExtractReceiptData;
  int get paginationLimit;
  int get summaryLastMonths;

  String get homeInitialTab;
}

class MockRemoteConfigRepository implements RemoteConfigRepository {
  @override
  Future<void> initialize() async {}

  @override
  int get geminiAntLookbackDays => 30;

  @override
  String get geminiModelName => 'gemini-3.5-flash-lite';

  @override
  String get geminiPromptDetectAntExpense =>
      'config_gemini_prompt_detect_ant_expense';

  @override
  String get geminiPromptExtractReceiptData =>
      'config_gemini_prompt_extract_receipt_data';

  @override
  int get paginationLimit => 10;

  @override
  int get summaryLastMonths => 4;

  @override
  String get homeInitialTab => 'movimientos';
}

class FirebaseRemoteConfigRepository implements RemoteConfigRepository {
  FirebaseRemoteConfigRepository({FirebaseRemoteConfig? remoteConfig})
    : _remoteConfig = remoteConfig ?? FirebaseRemoteConfig.instance;

  final FirebaseRemoteConfig _remoteConfig;

  @override
  Future<void> initialize() async {
    await _remoteConfig.setDefaults({
      RemoteConfigRepository.configGeminiAntLookbackDays: 30,
      RemoteConfigRepository.configGeminiModelName: 'gemini-3.5-flash-lite',
      RemoteConfigRepository.configGeminiPromptDetectAntExpense:
          'config_gemini_prompt_detect_ant_expense',
      RemoteConfigRepository.configGeminiPromptExtractReceiptData:
          'config_gemini_prompt_extract_receipt_data',
      RemoteConfigRepository.configPaginationLimit: 10,
      RemoteConfigRepository.configSummaryLastMonths: 4,
      RemoteConfigRepository.uiHomeInitialTab: 'movimientos',
    });

    try {
      await _remoteConfig.setConfigSettings(
        RemoteConfigSettings(
          fetchTimeout: AppVariables.remoteConfigFetchTimeout,
          minimumFetchInterval: kDebugMode
              ? Duration.zero
              : AppVariables.remoteConfigMinimumFetchInterval,
        ),
      );
      await _remoteConfig.fetchAndActivate();
    } on Exception catch (e, stackTrace) {
      getIt<CrashService>().recordError(
        e,
        stackTrace,
        reason: 'RemoteConfig initialization failed',
      );
    }
  }

  @override
  int get geminiAntLookbackDays =>
      _remoteConfig.getInt(RemoteConfigRepository.configGeminiAntLookbackDays);

  @override
  String get geminiModelName =>
      _remoteConfig.getString(RemoteConfigRepository.configGeminiModelName);

  @override
  String get geminiPromptDetectAntExpense => _remoteConfig.getString(
    RemoteConfigRepository.configGeminiPromptDetectAntExpense,
  );

  @override
  String get geminiPromptExtractReceiptData => _remoteConfig.getString(
    RemoteConfigRepository.configGeminiPromptExtractReceiptData,
  );

  @override
  int get paginationLimit =>
      _remoteConfig.getInt(RemoteConfigRepository.configPaginationLimit);

  @override
  int get summaryLastMonths =>
      _remoteConfig.getInt(RemoteConfigRepository.configSummaryLastMonths);

  @override
  String get homeInitialTab =>
      _remoteConfig.getString(RemoteConfigRepository.uiHomeInitialTab);
}
