import 'dart:io';
import 'dart:ui';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:expressive_kit/expressive_kit.dart';
import 'package:flutter/foundation.dart';
import 'package:material_ui/material_ui.dart';
import 'package:saver_expense_manager/app/app.dart';

part 'app_state.dart';

class AppCubit extends Cubit<AppState> {
  AppCubit() : super(const AppState());

  final LocalStorageService localStorage = getIt<LocalStorageService>();

  void initialLoad() {
    // Setting the language to the device language if it's not set
    final language = localStorage.getLanguage();
    if (language == null) {
      final deviceLocale = kIsWeb
          ? PlatformDispatcher.instance.locale.languageCode
          : Platform.localeName.split('_').first;
      final deviceLanguage = ExpressiveLanguages.fromLanguageCode(deviceLocale);
      localStorage.saveLanguage(language: deviceLanguage);
    }

    // Setting the theme to the device theme if it's not set
    final theme = localStorage.getTheme();
    if (theme == null) {
      localStorage.saveTheme(theme: ExpressiveTheme.defaultTheme);
    }

    // Setting the base color to default color if it's not set
    final baseColor = localStorage.getBaseColor();
    if (baseColor == null) {
      localStorage.saveBaseColor(baseColor: ExpressiveColors.defaultColor);
    }

    // Setting the font family to default font if it's not set
    var fontFamily = localStorage.getFontFamily();
    final isFontSupported =
        fontFamily != null &&
        ExpressiveFonts.availableFonts.containsValue(fontFamily);

    if (!isFontSupported) {
      const defaultFont = ExpressiveFonts.defaultFont;
      localStorage.saveFontFamily(fontFamily: defaultFont);
      fontFamily = defaultFont;
    }

    emit(
      state.copyWith(
        language: localStorage.getLanguage(),
        theme: localStorage.getTheme(),
        baseColor: localStorage.getBaseColor(),
        fontFamily: localStorage.getFontFamily(),
      ),
    );
  }

  void changeLanguage({required Locale language}) {
    localStorage.saveLanguage(language: language);
    getIt<AnalyticsService>().logEvent(
      name: 'change_language',
      parameters: {'language': language.languageCode},
    );
    emit(state.copyWith(language: language));
  }

  void changeTheme({required ThemeMode theme}) {
    localStorage.saveTheme(theme: theme);
    getIt<AnalyticsService>().logEvent(
      name: 'change_theme',
      parameters: {'theme': theme.name.toUpperCase()},
    );
    emit(state.copyWith(theme: theme));
  }

  void changeBaseColor({required Color baseColor}) {
    localStorage.saveBaseColor(baseColor: baseColor);
    getIt<AnalyticsService>().logEvent(
      name: 'change_base_color',
      parameters: {'color': ExpressiveColors.toKey(baseColor)},
    );
    emit(state.copyWith(baseColor: baseColor));
  }

  void changeFontFamily({required String fontFamily}) {
    localStorage.saveFontFamily(fontFamily: fontFamily);
    getIt<AnalyticsService>().logEvent(
      name: 'change_font_family',
      parameters: {'font': fontFamily},
    );
    emit(state.copyWith(fontFamily: fontFamily));
  }
}
