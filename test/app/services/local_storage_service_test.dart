import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:saver_expense_manager/app/app.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  late LocalStorageService localStorageService;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    localStorageService = LocalStorageService();
    await localStorageService.initialize();
  });

  group('LocalStorageService', () {
    test('saveLanguage and getLanguage work correctly', () {
      expect(localStorageService.getLanguage(), isNull);

      localStorageService.saveLanguage(language: const Locale('es', 'ES'));

      final language = localStorageService.getLanguage();
      expect(language?.languageCode, 'es');
      expect(language?.countryCode, 'ES');
    });

    test('saveTheme and getTheme work correctly', () {
      expect(localStorageService.getTheme(), isNull);

      localStorageService.saveTheme(theme: ThemeMode.dark);

      expect(localStorageService.getTheme(), ThemeMode.dark);
    });

    test('saveBaseColor and getBaseColor work correctly', () {
      expect(localStorageService.getBaseColor(), isNull);

      localStorageService.saveBaseColor(baseColor: Colors.blue);

      expect(localStorageService.getBaseColor(), Colors.blue);
    });

    test('saveFontFamily and getFontFamily work correctly', () {
      expect(localStorageService.getFontFamily(), isNull);

      localStorageService.saveFontFamily(fontFamily: 'Roboto');

      expect(localStorageService.getFontFamily(), 'Roboto');
    });

    test('saveRecommendationsDate and getRecommendationsDate work correctly',
        () {
      expect(localStorageService.getRecommendationsDate(), isNull);

      final date = DateTime(2023, 10, 5);
      localStorageService.saveRecommendationsDate(date: date);

      expect(localStorageService.getRecommendationsDate(), date);
    });

    test('saveRecommendations and getRecommendations work correctly', () {
      expect(localStorageService.getRecommendations(), isNull);

      final recommendations = ['Rec 1', 'Rec 2'];
      localStorageService.saveRecommendations(recommendations: recommendations);

      expect(localStorageService.getRecommendations(), recommendations);
    });
  });
}
