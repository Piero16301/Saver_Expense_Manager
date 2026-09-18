import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/foundation.dart';
import 'package:saver_expense_manager/app/app.dart';

abstract class RemoteConfigRepository {
  /// UI
  static const String uiHomeInitialTab = 'ui_home_initial_tab';

  /// CONFIG
  static const String configExtractReceiptDataTemplateId =
      'config_extract_receipt_data_template_id';
  static const String configPromptDetectAntExpenseTemplateId =
      'config_prompt_detect_ant_expense_template_id';
  static const String configGeminiPromptExtractReceiptData =
      'config_gemini_prompt_extract_receipt_data';
  static const String configGeminiPromptDetectAntExpense =
      'config_gemini_prompt_detect_ant_expense';
  static const String configGeminiAntLookbackDays =
      'config_gemini_ant_lookback_days';
  static const String configPaginationLimit = 'config_pagination_limit';
  static const String configSummaryLastMonths = 'config_summary_last_months';

  Future<void> initialize();
  String get homeInitialTab;
  String get extractReceiptDataTemplateId;
  String get promptDetectAntExpenseTemplateId;
  String get geminiPromptExtractReceiptData;
  String get geminiPromptDetectAntExpense;
  int get geminiAntLookbackDays;
  int get paginationLimit;
  int get summaryLastMonths;
}

class MockRemoteConfigRepository implements RemoteConfigRepository {
  @override
  Future<void> initialize() async {}

  @override
  String get homeInitialTab => 'movimientos';

  @override
  String get extractReceiptDataTemplateId =>
      'config_extract_receipt_data_template_id';

  @override
  String get promptDetectAntExpenseTemplateId =>
      'config_prompt_detect_ant_expense_template_id';

  @override
  String get geminiPromptExtractReceiptData =>
      'config_gemini_prompt_extract_receipt_data';

  @override
  String get geminiPromptDetectAntExpense =>
      'config_gemini_prompt_detect_ant_expense';

  @override
  int get geminiAntLookbackDays => 30;

  @override
  int get paginationLimit => 10;

  @override
  int get summaryLastMonths => 4;
}

class FirebaseRemoteConfigRepository implements RemoteConfigRepository {
  FirebaseRemoteConfigRepository({FirebaseRemoteConfig? remoteConfig})
    : _remoteConfig = remoteConfig ?? FirebaseRemoteConfig.instance;

  final FirebaseRemoteConfig _remoteConfig;

  @override
  Future<void> initialize() async {
    await _remoteConfig.setDefaults({
      RemoteConfigRepository.uiHomeInitialTab: 'movimientos',
      RemoteConfigRepository.configGeminiPromptExtractReceiptData:
          'config_gemini_prompt_extract_receipt_data',
      RemoteConfigRepository.configGeminiPromptDetectAntExpense:
          'config_gemini_prompt_detect_ant_expense',
      RemoteConfigRepository.configGeminiAntLookbackDays: 30,
      RemoteConfigRepository.configPaginationLimit: 10,
      RemoteConfigRepository.configSummaryLastMonths: 4,
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
  String get homeInitialTab =>
      _remoteConfig.getString(RemoteConfigRepository.uiHomeInitialTab);

  @override
  String get extractReceiptDataTemplateId => _remoteConfig.getString(
    RemoteConfigRepository.configExtractReceiptDataTemplateId,
  );

  @override
  String get promptDetectAntExpenseTemplateId => _remoteConfig.getString(
    RemoteConfigRepository.configPromptDetectAntExpenseTemplateId,
  );

  @override
  String get geminiPromptExtractReceiptData => _remoteConfig.getString(
    RemoteConfigRepository.configGeminiPromptExtractReceiptData,
  );

  @override
  String get geminiPromptDetectAntExpense => _remoteConfig.getString(
    RemoteConfigRepository.configGeminiPromptDetectAntExpense,
  );

  @override
  int get geminiAntLookbackDays =>
      _remoteConfig.getInt(RemoteConfigRepository.configGeminiAntLookbackDays);

  @override
  int get paginationLimit =>
      _remoteConfig.getInt(RemoteConfigRepository.configPaginationLimit);

  @override
  int get summaryLastMonths =>
      _remoteConfig.getInt(RemoteConfigRepository.configSummaryLastMonths);
}
