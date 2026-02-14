// services/remote_config_service.dart
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/foundation.dart';

class RemoteConfigService {
  RemoteConfigService({FirebaseRemoteConfig? remoteConfig})
      : _remoteConfig = remoteConfig ?? FirebaseRemoteConfig.instance;

  final FirebaseRemoteConfig _remoteConfig;

  /// UI
  static const String _uiHomeSummaryCardsVisible =
      'ui_home_summary_cards_visible';
  static const String _uiHomeTopCategoriesVisible =
      'ui_home_top_categories_visible';
  static const String _uiHomeInitialTab = 'ui_home_initial_tab';

  /// CONFIG
  static const String _configGeminiModelId = 'config_gemini_model_id';
  static const String _configGeminiPromptTemplate =
      'config_gemini_prompt_template';

  Future<void> initialize() async {
    await _remoteConfig.setDefaults({
      _uiHomeSummaryCardsVisible: true,
      _uiHomeTopCategoriesVisible: true,
      _uiHomeInitialTab: 'movimientos',
      _configGeminiModelId: 'gemini-3-flash-preview',
      _configGeminiPromptTemplate: 'config_gemini_prompt_template',
    });

    try {
      await _remoteConfig.setConfigSettings(
        RemoteConfigSettings(
          fetchTimeout: const Duration(minutes: 1),
          minimumFetchInterval:
              kDebugMode ? Duration.zero : const Duration(hours: 1),
        ),
      );
      await _remoteConfig.fetchAndActivate();
    } on Exception catch (_) {}
  }

  bool get isHomeSummaryCardsVisible =>
      _remoteConfig.getBool(_uiHomeSummaryCardsVisible);
  bool get isHomeTopCategoriesVisible =>
      _remoteConfig.getBool(_uiHomeTopCategoriesVisible);
  String get homeInitialTab => _remoteConfig.getString(_uiHomeInitialTab);
  String get geminiModelId => _remoteConfig.getString(_configGeminiModelId);
  String get geminiPromptTemplate =>
      _remoteConfig.getString(_configGeminiPromptTemplate);
}
