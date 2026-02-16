import 'dart:io';
import 'dart:ui';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:saver_expense_manager/app/app.dart';

part 'app_state.dart';

class AppCubit extends Cubit<AppState> {
  AppCubit() : super(const AppState());

  final LocalStorageService localStorage = getIt<LocalStorageService>();

  void initialLoad() {
    // Setting the language to the device language if it's not set
    final language = localStorage.getLanguage();
    if (language == null) {
      final deviceLanguage = Platform.localeName;
      localStorage.saveLanguage(language: deviceLanguage);
    }

    // Setting the theme to the device theme if it's not set
    final theme = localStorage.getTheme();
    if (theme == null) {
      final deviceBrightness = PlatformDispatcher.instance.platformBrightness;
      localStorage.saveTheme(
        theme: deviceBrightness == Brightness.dark
            ? AppVariables.darkTheme
            : AppVariables.lightTheme,
      );
    }

    // Setting the base color to INDIGO if it's not set
    final baseColor = localStorage.getBaseColor();
    if (baseColor == null) {
      localStorage.saveBaseColor(
        baseColor: AppVariables.defaultBaseColor,
      );
    }

    // Setting the font family to Nunito_regular if it's not set
    final fontFamily = localStorage.getFontFamily();
    if (fontFamily == null) {
      localStorage.saveFontFamily(
        fontFamily: AppVariables.defaultFontFamily,
      );
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

  void changeLanguage({required String language}) {
    localStorage.saveLanguage(language: language);
    emit(state.copyWith(language: language));
  }

  void changeTheme({required String theme}) {
    localStorage.saveTheme(theme: theme);
    emit(state.copyWith(theme: theme));
  }

  void changeBaseColor({required String baseColor}) {
    localStorage.saveBaseColor(baseColor: baseColor);
    emit(state.copyWith(baseColor: baseColor));
  }

  void changeFontFamily({required String fontFamily}) {
    localStorage.saveFontFamily(fontFamily: fontFamily);
    emit(state.copyWith(fontFamily: fontFamily));
  }
}
