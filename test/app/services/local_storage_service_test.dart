import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:saver_expense_manager/app/app.dart';

class MockLocalStorageRepository extends Mock
    implements LocalStorageRepository {}

void main() {
  late LocalStorageService service;
  late MockLocalStorageRepository mockRepository;

  setUpAll(() {
    registerFallbackValue(const Locale('en'));
    registerFallbackValue(ThemeMode.system);
    registerFallbackValue(Colors.black);
  });

  setUp(() {
    mockRepository = MockLocalStorageRepository();
    service = LocalStorageService(localStorageRepository: mockRepository);
  });

  group('LocalStorageService', () {
    test('can be instantiated', () {
      expect(service, isNotNull);
    });

    test('initialize calls repository initialize', () async {
      when(() => mockRepository.initialize()).thenAnswer((_) async {});
      await service.initialize();
      verify(() => mockRepository.initialize()).called(1);
    });

    test('saveLanguage calls repository', () {
      when(
        () => mockRepository.saveLanguage(
          language: any<Locale>(named: 'language'),
        ),
      ).thenReturn(null);
      service.saveLanguage(language: const Locale('en'));
      verify(
        () => mockRepository.saveLanguage(language: const Locale('en')),
      ).called(1);
    });

    test('getLanguage returns from repository', () {
      when(() => mockRepository.getLanguage()).thenReturn(const Locale('es'));
      expect(service.getLanguage(), equals(const Locale('es')));
    });

    test('saveTheme calls repository', () {
      when(
        () => mockRepository.saveTheme(theme: any<ThemeMode>(named: 'theme')),
      ).thenReturn(null);
      service.saveTheme(theme: ThemeMode.dark);
      verify(() => mockRepository.saveTheme(theme: ThemeMode.dark)).called(1);
    });

    test('getTheme returns from repository', () {
      when(() => mockRepository.getTheme()).thenReturn(ThemeMode.light);
      expect(service.getTheme(), equals(ThemeMode.light));
    });

    test('saveBaseColor calls repository', () {
      when(
        () => mockRepository.saveBaseColor(
          baseColor: any<Color>(named: 'baseColor'),
        ),
      ).thenReturn(null);
      service.saveBaseColor(baseColor: Colors.red);
      verify(
        () => mockRepository.saveBaseColor(baseColor: Colors.red),
      ).called(1);
    });

    test('getBaseColor returns from repository', () {
      when(() => mockRepository.getBaseColor()).thenReturn(Colors.blue);
      expect(service.getBaseColor(), equals(Colors.blue));
    });

    test('saveFontFamily calls repository', () {
      when(
        () => mockRepository.saveFontFamily(
          fontFamily: any<String>(named: 'fontFamily'),
        ),
      ).thenReturn(null);
      service.saveFontFamily(fontFamily: 'Roboto');
      verify(
        () => mockRepository.saveFontFamily(fontFamily: 'Roboto'),
      ).called(1);
    });

    test('getFontFamily returns from repository', () {
      when(() => mockRepository.getFontFamily()).thenReturn('Arial');
      expect(service.getFontFamily(), equals('Arial'));
    });

    test('saveRecommendationsDate calls repository', () {
      final date = DateTime(2023);
      when(
        () => mockRepository.saveRecommendationsDate(
          date: any<DateTime>(named: 'date'),
        ),
      ).thenReturn(null);
      service.saveRecommendationsDate(date: date);
      verify(
        () => mockRepository.saveRecommendationsDate(date: date),
      ).called(1);
    });

    test('getRecommendationsDate returns from repository', () {
      final date = DateTime(2023);
      when(() => mockRepository.getRecommendationsDate()).thenReturn(date);
      expect(service.getRecommendationsDate(), equals(date));
    });

    test('saveRecommendations calls repository', () {
      when(
        () => mockRepository.saveRecommendations(
          recommendations: any<List<String>>(named: 'recommendations'),
        ),
      ).thenReturn(null);
      service.saveRecommendations(recommendations: ['a', 'b']);
      verify(
        () => mockRepository.saveRecommendations(recommendations: ['a', 'b']),
      ).called(1);
    });

    test('getRecommendations returns from repository', () {
      when(() => mockRepository.getRecommendations()).thenReturn(['x']);
      expect(service.getRecommendations(), equals(['x']));
    });
  });
}
