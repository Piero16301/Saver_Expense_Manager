import 'dart:io';
import 'dart:ui';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:saver_expense_manager/app/app.dart';
import 'package:user_repository/user_repository.dart';

part 'app_state.dart';

class AppCubit extends Cubit<AppState> {
  AppCubit(this.userRepository) : super(const AppState());

  final UserRepository userRepository;

  Future<void> initialLoad() async {
    // Setting the language to the device language if it's not set
    final language = userRepository.getLanguage();
    if (language == null) {
      final deviceLanguage = Platform.localeName;
      await userRepository.saveLanguage(language: deviceLanguage);
    }

    // Setting the theme to the device theme if it's not set
    final theme = userRepository.getTheme();
    if (theme == null) {
      final deviceBrightness = PlatformDispatcher.instance.platformBrightness;
      await userRepository.saveTheme(
        theme: deviceBrightness == Brightness.dark
            ? AppVariables.darkTheme
            : AppVariables.lightTheme,
      );
    }

    // Setting the base color to INDIGO if it's not set
    final baseColor = userRepository.getBaseColor();
    if (baseColor == null) {
      await userRepository.saveBaseColor(
        baseColor: AppVariables.defaultBaseColor,
      );
    }

    // Setting the font family to Nunito_regular if it's not set
    final fontFamily = userRepository.getFontFamily();
    if (fontFamily == null) {
      await userRepository.saveFontFamily(
        fontFamily: AppVariables.defaultFontFamily,
      );
    }

    emit(
      state.copyWith(
        language: userRepository.getLanguage(),
        theme: userRepository.getTheme(),
        baseColor: userRepository.getBaseColor(),
        fontFamily: userRepository.getFontFamily(),
      ),
    );
  }

  Future<void> changeLanguage({required String language}) async {
    await userRepository.saveLanguage(language: language);
    emit(state.copyWith(language: language));
  }

  Future<void> changeTheme({required String theme}) async {
    await userRepository.saveTheme(theme: theme);
    emit(state.copyWith(theme: theme));
  }

  Future<void> changeBaseColor({required String baseColor}) async {
    await userRepository.saveBaseColor(baseColor: baseColor);
    emit(state.copyWith(baseColor: baseColor));
  }

  Future<void> changeFontFamily({required String fontFamily}) async {
    await userRepository.saveFontFamily(fontFamily: fontFamily);
    emit(state.copyWith(fontFamily: fontFamily));
  }
}
