import 'package:material_ui/material_ui.dart';
import 'package:saver_expense_manager/app/app.dart';

class LocalStorageService {
  new({required this._localStorageRepository});

  final LocalStorageRepository _localStorageRepository;

  Future<void> initialize() async {
    await _localStorageRepository.initialize();
  }

  void saveLanguage({required Locale language}) {
    _localStorageRepository.saveLanguage(language: language);
  }

  Locale? getLanguage() {
    return _localStorageRepository.getLanguage();
  }

  void saveTheme({required ThemeMode theme}) {
    _localStorageRepository.saveTheme(theme: theme);
  }

  ThemeMode? getTheme() {
    return _localStorageRepository.getTheme();
  }

  void saveBaseColor({required Color baseColor}) {
    _localStorageRepository.saveBaseColor(baseColor: baseColor);
  }

  Color? getBaseColor() {
    return _localStorageRepository.getBaseColor();
  }

  void saveFontFamily({required String fontFamily}) {
    _localStorageRepository.saveFontFamily(fontFamily: fontFamily);
  }

  String? getFontFamily() {
    return _localStorageRepository.getFontFamily();
  }

  void saveRecommendationsDate({required DateTime date, String? userId}) {
    _localStorageRepository.saveRecommendationsDate(date: date, userId: userId);
  }

  DateTime? getRecommendationsDate({String? userId}) {
    return _localStorageRepository.getRecommendationsDate(userId: userId);
  }

  void saveRecommendations({
    required List<String> recommendations,
    String? userId,
  }) {
    _localStorageRepository.saveRecommendations(
      recommendations: recommendations,
      userId: userId,
    );
  }

  List<String>? getRecommendations({String? userId}) {
    return _localStorageRepository.getRecommendations(userId: userId);
  }

  void clearRecommendations({String? userId}) {
    _localStorageRepository.clearRecommendations(userId: userId);
  }
}
