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
  Future<void> saveLanguage(String language) => _userApi.saveLanguage(language);

  /// Get language from local storage
  String? getLanguage() => _userApi.getLanguage();

  /// Save dark theme in local storage
  Future<void> saveDarkTheme({bool darkTheme = false}) =>
      _userApi.saveDarkTheme(darkTheme: darkTheme);

  /// Get dark theme from local storage
  bool? getDarkTheme() => _userApi.getDarkTheme();
}
