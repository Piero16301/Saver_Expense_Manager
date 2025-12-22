import 'package:shared_preferences/shared_preferences.dart';
import 'package:user_api/user_api.dart';

/// {@template user_api_remote}
/// User API Remote Package
/// {@endtemplate}
class UserApiRemote implements IUserApi {
  /// {@macro user_api_remote}
  UserApiRemote({
    required SharedPreferences preferences,
  }) : _preferences = preferences;

  final SharedPreferences _preferences;

  /// The key used to store the user's language
  static const kUserLanguage = '__user_language__';

  /// The key used to store the user's theme preference
  static const kUserTheme = '__user_theme__';

  /// The key used to store the user's base color preference
  static const kUserBaseColor = '__user_base_color__';

  /// The key used to store the user's font family preference
  static const kUserFontFamily = '__user_font_family__';

  @override
  Future<void> saveLanguage({required String language}) async {
    await _preferences.setString(kUserLanguage, language);
  }

  @override
  String? getLanguage() {
    return _preferences.getString(kUserLanguage);
  }

  @override
  Future<void> saveTheme({required String theme}) async {
    await _preferences.setString(kUserTheme, theme);
  }

  @override
  String? getTheme() {
    return _preferences.getString(kUserTheme);
  }

  @override
  Future<void> saveBaseColor({required String baseColor}) async {
    await _preferences.setString(kUserBaseColor, baseColor);
  }

  @override
  String? getBaseColor() {
    return _preferences.getString(kUserBaseColor);
  }

  @override
  Future<void> saveFontFamily({required String fontFamily}) async {
    await _preferences.setString(kUserFontFamily, fontFamily);
  }

  @override
  String? getFontFamily() {
    return _preferences.getString(kUserFontFamily);
  }
}
