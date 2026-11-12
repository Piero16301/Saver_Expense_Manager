import 'package:expressive_kit/expressive_kit.dart';
import 'package:material_ui/material_ui.dart';
import 'package:saver_expense_manager/app/app.dart';
import 'package:shared_preferences/shared_preferences.dart';

abstract class LocalStorageRepository {
  static const kUserLanguage = '__user_language__';
  static const kUserTheme = '__user_theme__';
  static const kUserBaseColor = '__user_base_color__';
  static const kUserFontFamily = '__user_font_family__';
  static const kUserRecommendationsDate = '__user_recommendations_date__';
  static const kUserRecommendations = '__user_recommendations__';

  Future<void> initialize();
  void saveLanguage({required Locale language});
  Locale? getLanguage();
  void saveTheme({required ThemeMode theme});
  ThemeMode? getTheme();
  void saveBaseColor({required Color baseColor});
  Color? getBaseColor();
  void saveFontFamily({required String fontFamily});
  String? getFontFamily();
  void saveRecommendationsDate({required DateTime date, String? userId});
  DateTime? getRecommendationsDate({String? userId});
  void saveRecommendations({
    required List<String> recommendations,
    String? userId,
  });
  List<String>? getRecommendations({String? userId});
  void clearRecommendations({String? userId});
}

class MockLocalStorageRepository implements LocalStorageRepository {
  @override
  Future<void> initialize() async {}

  @override
  void saveLanguage({required Locale language}) {}

  @override
  Locale? getLanguage() {
    return const Locale('en', 'US');
  }

  @override
  void saveTheme({required ThemeMode theme}) {}

  @override
  ThemeMode? getTheme() {
    return ThemeMode.light;
  }

  @override
  void saveBaseColor({required Color baseColor}) {}

  @override
  Color? getBaseColor() {
    return Colors.blue;
  }

  @override
  void saveFontFamily({required String fontFamily}) {}

  @override
  String? getFontFamily() {
    return 'default';
  }

  @override
  void saveRecommendationsDate({required DateTime date, String? userId}) {}

  @override
  DateTime? getRecommendationsDate({String? userId}) {
    return DateTime.now();
  }

  @override
  void saveRecommendations({
    required List<String> recommendations,
    String? userId,
  }) {}

  @override
  List<String>? getRecommendations({String? userId}) {
    return [];
  }

  @override
  void clearRecommendations({String? userId}) {}
}

class SharedPrefsLocalStorageRepository implements LocalStorageRepository {
  new({this._prefs});

  SharedPreferences? _prefs;

  @override
  Future<void> initialize() async {
    _prefs = await SharedPreferences.getInstance();
  }

  @override
  void saveLanguage({required Locale language}) {
    final languageString = '${language.languageCode}_${language.countryCode}';
    _prefs
        ?.setString(LocalStorageRepository.kUserLanguage, languageString)
        .ignore();
  }

  @override
  Locale? getLanguage() {
    final languageString = _prefs?.getString(
      LocalStorageRepository.kUserLanguage,
    );
    if (languageString == null) {
      return null;
    }
    final languageParts = languageString.split('_');
    return Locale(languageParts.first, languageParts.last);
  }

  @override
  void saveTheme({required ThemeMode theme}) {
    _prefs
        ?.setString(
          LocalStorageRepository.kUserTheme,
          ExpressiveTheme.toKey(theme),
        )
        .ignore();
  }

  @override
  ThemeMode? getTheme() {
    final themeString = _prefs?.getString(LocalStorageRepository.kUserTheme);
    if (themeString == null) {
      return null;
    }
    return ExpressiveTheme.fromKey(themeString);
  }

  @override
  void saveBaseColor({required Color baseColor}) {
    _prefs
        ?.setString(
          LocalStorageRepository.kUserBaseColor,
          ExpressiveColors.toKey(baseColor),
        )
        .ignore();
  }

  @override
  Color? getBaseColor() {
    final baseColorString = _prefs?.getString(
      LocalStorageRepository.kUserBaseColor,
    );
    if (baseColorString == null) {
      return null;
    }
    return ExpressiveColors.fromKey(baseColorString);
  }

  @override
  void saveFontFamily({required String fontFamily}) {
    _prefs
        ?.setString(LocalStorageRepository.kUserFontFamily, fontFamily)
        .ignore();
  }

  @override
  String? getFontFamily() {
    return _prefs?.getString(LocalStorageRepository.kUserFontFamily);
  }

  String _recDateKey(String? userId) => userId != null && userId.isNotEmpty
      ? '${LocalStorageRepository.kUserRecommendationsDate}_$userId'
      : LocalStorageRepository.kUserRecommendationsDate;

  String _recKey(String? userId) => userId != null && userId.isNotEmpty
      ? '${LocalStorageRepository.kUserRecommendations}_$userId'
      : LocalStorageRepository.kUserRecommendations;

  @override
  void saveRecommendationsDate({required DateTime date, String? userId}) {
    _prefs
        ?.setString(_recDateKey(userId), AppVariables.formatDate.format(date))
        .ignore();
  }

  @override
  DateTime? getRecommendationsDate({String? userId}) {
    final dateString = _prefs?.getString(_recDateKey(userId));
    if (dateString == null) {
      return null;
    }
    return AppVariables.formatDate.parse(dateString);
  }

  @override
  void saveRecommendations({
    required List<String> recommendations,
    String? userId,
  }) {
    _prefs?.setStringList(_recKey(userId), recommendations).ignore();
  }

  @override
  List<String>? getRecommendations({String? userId}) {
    return _prefs?.getStringList(_recKey(userId));
  }

  @override
  void clearRecommendations({String? userId}) {
    _prefs?.remove(_recKey(userId)).ignore();
    _prefs?.remove(_recDateKey(userId)).ignore();
    if (userId == null) {
      _prefs?.remove(LocalStorageRepository.kUserRecommendations).ignore();
      _prefs?.remove(LocalStorageRepository.kUserRecommendationsDate).ignore();
    }
  }
}
