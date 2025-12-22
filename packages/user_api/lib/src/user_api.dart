/// {@template user_api}
/// User API Package
/// {@endtemplate}
abstract class IUserApi {
  /// {@macro user_api}
  const IUserApi();

  /// Save language in local storage
  Future<void> saveLanguage({required String language});

  /// Get language from local storage
  String? getLanguage();

  /// Save theme preference in local storage
  Future<void> saveTheme({required String theme});

  /// Get theme preference from local storage
  String? getTheme();

  /// Save base color in local storage
  Future<void> saveBaseColor({required String baseColor});

  /// Get base color from local storage
  String? getBaseColor();

  /// Save font family in local storage
  Future<void> saveFontFamily({required String fontFamily});

  /// Get font family from local storage
  String? getFontFamily();
}
