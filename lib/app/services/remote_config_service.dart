// services/remote_config_service.dart
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/foundation.dart';
import 'package:saver_expense_manager/app/app.dart';

class RemoteConfigService {
  RemoteConfigService({FirebaseRemoteConfig? remoteConfig})
      : _remoteConfig = remoteConfig ?? FirebaseRemoteConfig.instance;

  final FirebaseRemoteConfig _remoteConfig;

  /// UI
  static const String _uiHomeInitialTab = 'ui_home_initial_tab';

  /// CONFIG
  static const String _configGeminiModelId = 'config_gemini_model_id';
  static const String _configGeminiPromptExtractReceiptData =
      'config_gemini_prompt_extract_receipt_data';
  static const String _configGeminiPromptDetectAntExpense =
      'config_gemini_prompt_detect_ant_expense';
  static const String _configGeminiAntLookbackDays =
      'config_gemini_ant_lookback_days';

  Future<void> initialize() async {
    await _remoteConfig.setDefaults({
      _uiHomeInitialTab: 'movimientos',
      _configGeminiModelId: 'gemini-3-flash-preview',
      _configGeminiPromptExtractReceiptData:
          'config_gemini_prompt_extract_receipt_data',
      _configGeminiPromptDetectAntExpense:
          'config_gemini_prompt_detect_ant_expense',
      _configGeminiAntLookbackDays: 30,
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
    } on Exception catch (_) {}
  }

  String get homeInitialTab => _remoteConfig.getString(_uiHomeInitialTab);
  String get geminiModelId => _remoteConfig.getString(_configGeminiModelId);
  String get geminiPromptExtractReceiptData =>
      _remoteConfig.getString(_configGeminiPromptExtractReceiptData);
  String get geminiPromptDetectAntExpense =>
      _remoteConfig.getString(_configGeminiPromptDetectAntExpense);
  int get geminiAntLookbackDays =>
      _remoteConfig.getInt(_configGeminiAntLookbackDays);
}
