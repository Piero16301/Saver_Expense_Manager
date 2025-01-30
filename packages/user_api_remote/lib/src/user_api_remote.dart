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

  /// The key used to store language in local storage
  static const kLanguage = '__language__';

  /// The key used to store dark theme in local storage
  static const kDarkTheme = '__dark_theme__';

  @override
  Future<void> saveLanguage(String language) async {
    await _preferences.setString(kLanguage, language);
  }

  @override
  String? getLanguage() {
    return _preferences.getString(kLanguage);
  }

  @override
  Future<void> saveDarkTheme({bool darkTheme = false}) async {
    await _preferences.setBool(kDarkTheme, darkTheme);
  }

  @override
  bool? getDarkTheme() {
    return _preferences.getBool(kDarkTheme);
  }
}
