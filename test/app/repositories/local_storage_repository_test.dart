import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:saver_expense_manager/app/app.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MockSharedPreferences extends Mock implements SharedPreferences {}

void main() {
  late MockSharedPreferences mockPrefs;
  late SharedPrefsLocalStorageRepository repository;

  setUp(() {
    mockPrefs = MockSharedPreferences();
    repository = SharedPrefsLocalStorageRepository(prefs: mockPrefs);
  });

  group('MockLocalStorageRepository', () {
    test('Mock tests for coverage', () async {
      final mock = MockLocalStorageRepository();
      await mock.initialize();
      mock.saveLanguage(language: const Locale('en'));
      expect(mock.getLanguage(), isA<Locale>());
      mock.saveTheme(theme: ThemeMode.dark);
      expect(mock.getTheme(), equals(ThemeMode.light));
      mock.saveBaseColor(baseColor: Colors.red);
      expect(mock.getBaseColor(), equals(Colors.blue));
      mock.saveFontFamily(fontFamily: 'font');
      expect(mock.getFontFamily(), equals('default'));
      mock.saveRecommendationsDate(date: DateTime.now());
      expect(mock.getRecommendationsDate(), isNotNull);
      mock.saveRecommendations(recommendations: ['r1']);
      expect(mock.getRecommendations(), isEmpty);
    });
  });

  group('SharedPrefsLocalStorageRepository', () {
    test('saveLanguage calls setString', () {
      when(
        () => mockPrefs.setString(any(), any()),
      ).thenAnswer((_) async => true);
      repository.saveLanguage(language: const Locale('en', 'US'));
      verify(
        () =>
            mockPrefs.setString(LocalStorageRepository.kUserLanguage, 'en_US'),
      ).called(1);
    });

    test('getLanguage returns parsed Locale', () {
      when(
        () => mockPrefs.getString(LocalStorageRepository.kUserLanguage),
      ).thenReturn('es_PE');
      final result = repository.getLanguage();
      expect(result, equals(const Locale('es', 'PE')));
    });

    test('getLanguage returns null if key missing', () {
      when(
        () => mockPrefs.getString(LocalStorageRepository.kUserLanguage),
      ).thenReturn(null);
      final result = repository.getLanguage();
      expect(result, isNull);
    });

    test('saveTheme calls setString with correct name', () {
      when(
        () => mockPrefs.setString(any(), any()),
      ).thenAnswer((_) async => true);
      repository.saveTheme(theme: ThemeMode.dark);
      verify(
        () => mockPrefs.setString(
          LocalStorageRepository.kUserTheme,
          ThemeHelper.getThemeName(ThemeMode.dark),
        ),
      ).called(1);
    });

    test('getTheme returns correctly parsed ThemeMode', () {
      when(
        () => mockPrefs.getString(LocalStorageRepository.kUserTheme),
      ).thenReturn(ThemeHelper.getThemeName(ThemeMode.dark));
      final result = repository.getTheme();
      expect(result, equals(ThemeMode.dark));
    });

    test('saveBaseColor calls setString', () {
      when(
        () => mockPrefs.setString(any(), any()),
      ).thenAnswer((_) async => true);
      repository.saveBaseColor(baseColor: Colors.blue);
      verify(
        () => mockPrefs.setString(
          LocalStorageRepository.kUserBaseColor,
          ColorHelper.getColorName(Colors.blue),
        ),
      ).called(1);
    });

    test('getBaseColor returns correctly parsed Color', () {
      when(
        () => mockPrefs.getString(LocalStorageRepository.kUserBaseColor),
      ).thenReturn(ColorHelper.getColorName(Colors.blue));
      final result = repository.getBaseColor();
      expect(result, equals(Colors.blue));
    });

    test('saveFontFamily calls setString', () {
      when(
        () => mockPrefs.setString(any(), any()),
      ).thenAnswer((_) async => true);
      repository.saveFontFamily(fontFamily: 'Roboto');
      verify(
        () => mockPrefs.setString(
          LocalStorageRepository.kUserFontFamily,
          'Roboto',
        ),
      ).called(1);
    });

    test('getFontFamily returns string', () {
      when(
        () => mockPrefs.getString(LocalStorageRepository.kUserFontFamily),
      ).thenReturn('Roboto');
      expect(repository.getFontFamily(), equals('Roboto'));
    });

    test('saveRecommendationsDate calls setString with formatted date', () {
      when(
        () => mockPrefs.setString(any(), any()),
      ).thenAnswer((_) async => true);
      final date = DateTime(2026);
      repository.saveRecommendationsDate(date: date);
      verify(
        () => mockPrefs.setString(
          LocalStorageRepository.kUserRecommendationsDate,
          AppVariables.formatDate.format(date),
        ),
      ).called(1);
    });

    test('getRecommendationsDate returns parsed DateTime', () {
      final date = DateTime(2026);
      when(
        () => mockPrefs.getString(
          LocalStorageRepository.kUserRecommendationsDate,
        ),
      ).thenReturn(AppVariables.formatDate.format(date));
      expect(repository.getRecommendationsDate(), equals(date));
    });

    test('saveRecommendations calls setStringList', () {
      when(
        () => mockPrefs.setStringList(any(), any()),
      ).thenAnswer((_) async => true);
      repository.saveRecommendations(recommendations: ['r1', 'r2']);
      verify(
        () => mockPrefs.setStringList(
          LocalStorageRepository.kUserRecommendations,
          ['r1', 'r2'],
        ),
      ).called(1);
    });

    test('getRecommendations returns list', () {
      when(
        () => mockPrefs.getStringList(
          LocalStorageRepository.kUserRecommendations,
        ),
      ).thenReturn(['r1', 'r2']);
      expect(repository.getRecommendations(), equals(['r1', 'r2']));
    });
  });
}
