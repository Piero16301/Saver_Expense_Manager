/// {@template user_api}
/// User API Package
/// {@endtemplate}
abstract class IUserApi {
  /// {@macro user_api}
  const IUserApi();

  /// Save language in local storage
  Future<void> saveLanguage(String language);

  /// Get language from local storage
  String? getLanguage();

  /// Save dark theme in local storage
  Future<void> saveDarkTheme({bool darkTheme = false});

  /// Get dark theme from local storage
  bool? getDarkTheme();
}
