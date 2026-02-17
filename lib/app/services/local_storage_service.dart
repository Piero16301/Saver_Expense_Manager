import 'package:shared_preferences/shared_preferences.dart';

class LocalStorageService {
  LocalStorageService() : _prefs = null;

  SharedPreferences? _prefs;

  /// Keys to save user preferences
  static const kUserLanguage = '__user_language__';
  static const kUserTheme = '__user_theme__';
  static const kUserBaseColor = '__user_base_color__';
  static const kUserFontFamily = '__user_font_family__';

  Future<void> initialize() async {
    _prefs = await SharedPreferences.getInstance();
  }

  void saveLanguage({required String language}) {
    _prefs?.setString(kUserLanguage, language).ignore();
  }

  String? getLanguage() {
    return _prefs?.getString(kUserLanguage);
  }

  void saveTheme({required String theme}) {
    _prefs?.setString(kUserTheme, theme).ignore();
  }

  String? getTheme() {
    return _prefs?.getString(kUserTheme);
  }

  void saveBaseColor({required String baseColor}) {
    _prefs?.setString(kUserBaseColor, baseColor).ignore();
  }

  String? getBaseColor() {
    return _prefs?.getString(kUserBaseColor);
  }

  void saveFontFamily({required String fontFamily}) {
    _prefs?.setString(kUserFontFamily, fontFamily).ignore();
  }

  String? getFontFamily() {
    return _prefs?.getString(kUserFontFamily);
  }
}
