import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:saver_expense_manager/app/app.dart';

part 'app_state.dart';

class AppCubit extends Cubit<AppState> {
  AppCubit() : super(const AppState());

  final LocalStorageService localStorage = getIt<LocalStorageService>();

  void initialLoad() {
    // Setting the language to the device language if it's not set
    final language = localStorage.getLanguage();
    if (language == null) {
      final deviceLanguage = AppVariables.supportedLocales.first;
      localStorage.saveLanguage(language: deviceLanguage);
    }

    // Setting the theme to the device theme if it's not set
    final theme = localStorage.getTheme();
    if (theme == null) {
      localStorage.saveTheme(theme: ThemeMode.system);
    }

    // Setting the base color to GREEN if it's not set
    final baseColor = localStorage.getBaseColor();
    if (baseColor == null) {
      localStorage.saveBaseColor(baseColor: AppVariables.defaultBaseColor);
    }

    // Setting the font family to Popping if it's not set
    var fontFamily = localStorage.getFontFamily();
    final isFontSupported = fontFamily != null &&
        AppVariables.availableFonts.containsValue(fontFamily);

    if (!isFontSupported) {
      final defaultFont =
          AppVariables.availableFonts[AppVariables.defaultFontFamily] ??
              AppVariables.defaultFontFamily;
      localStorage.saveFontFamily(fontFamily: defaultFont);
      fontFamily = defaultFont;
    }

    final receiptsModel = localStorage.getReceiptsModel();
    if (receiptsModel == null) {
      localStorage.saveReceiptsModel(modelType: ModelType.cloud);
    }

    final expensesModel = localStorage.getExpensesModel();
    if (expensesModel == null) {
      localStorage.saveExpensesModel(modelType: ModelType.cloud);
    }

    emit(
      state.copyWith(
        language: localStorage.getLanguage(),
        theme: localStorage.getTheme(),
        baseColor: localStorage.getBaseColor(),
        fontFamily: localStorage.getFontFamily(),
        receiptsModel: localStorage.getReceiptsModel(),
        expensesModel: localStorage.getExpensesModel(),
      ),
    );
  }

  void changeLanguage({required Locale language}) {
    localStorage.saveLanguage(language: language);
    emit(state.copyWith(language: language));
  }

  void changeTheme({required ThemeMode theme}) {
    localStorage.saveTheme(theme: theme);
    emit(state.copyWith(theme: theme));
  }

  void changeBaseColor({required Color baseColor}) {
    localStorage.saveBaseColor(baseColor: baseColor);
    emit(state.copyWith(baseColor: baseColor));
  }

  void changeFontFamily({required String fontFamily}) {
    localStorage.saveFontFamily(fontFamily: fontFamily);
    emit(state.copyWith(fontFamily: fontFamily));
  }

  void changeReceiptsModel({required ModelType modelType}) {
    localStorage.saveReceiptsModel(modelType: modelType);
    emit(state.copyWith(receiptsModel: modelType));
  }

  void changeExpensesModel({required ModelType modelType}) {
    localStorage.saveExpensesModel(modelType: modelType);
    emit(state.copyWith(expensesModel: modelType));
  }
}
