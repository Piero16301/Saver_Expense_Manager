import 'package:flutter/material.dart';
import 'package:saver_expense_manager/app/app.dart';
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

  void saveLanguage({required Locale language}) {
    final languageString = '${language.languageCode}_${language.countryCode}';
    _prefs?.setString(kUserLanguage, languageString).ignore();
  }

  Locale? getLanguage() {
    final languageString = _prefs?.getString(kUserLanguage);
    if (languageString == null) {
      return null;
    }
    final languageParts = languageString.split('_');
    return Locale(languageParts.first, languageParts.last);
  }

  void saveTheme({required ThemeMode theme}) {
    _prefs?.setString(kUserTheme, ThemeHelper.getThemeName(theme)).ignore();
  }

  ThemeMode? getTheme() {
    final themeString = _prefs?.getString(kUserTheme);
    if (themeString == null) {
      return null;
    }
    return ThemeHelper.getThemeByName(themeString);
  }

  void saveBaseColor({required Color baseColor}) {
    _prefs
        ?.setString(kUserBaseColor, ColorHelper.getColorName(baseColor))
        .ignore();
  }

  Color? getBaseColor() {
    final baseColorString = _prefs?.getString(kUserBaseColor);
    if (baseColorString == null) {
      return null;
    }
    return ColorHelper.getColorByName(baseColorString);
  }

  void saveFontFamily({required String fontFamily}) {
    _prefs?.setString(kUserFontFamily, fontFamily).ignore();
  }

  String? getFontFamily() {
    return _prefs?.getString(kUserFontFamily);
  }
}
