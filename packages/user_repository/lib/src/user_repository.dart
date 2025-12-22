import 'package:user_api/user_api.dart';

/// {@template user_repository}
/// User Repository Package
/// {@endtemplate}
class UserRepository {
  /// {@macro user_repository}
  const UserRepository({
    required IUserApi userApi,
  }) : _userApi = userApi;

  final IUserApi _userApi;

  /// Save language in local storage
  Future<void> saveLanguage({required String language}) =>
      _userApi.saveLanguage(language: language);

  /// Get language from local storage
  String? getLanguage() => _userApi.getLanguage();

  /// Save theme preference in local storage
  Future<void> saveTheme({required String theme}) =>
      _userApi.saveTheme(theme: theme);

  /// Get theme preference from local storage
  String? getTheme() => _userApi.getTheme();

  /// Save base color in local storage
  Future<void> saveBaseColor({required String baseColor}) =>
      _userApi.saveBaseColor(baseColor: baseColor);

  /// Get save color from local storage
  String? getBaseColor() => _userApi.getBaseColor();

  /// Save font family in local storage
  Future<void> saveFontFamily({required String fontFamily}) =>
      _userApi.saveFontFamily(fontFamily: fontFamily);

  /// Get font family from local storage
  String? getFontFamily() => _userApi.getFontFamily();
}
