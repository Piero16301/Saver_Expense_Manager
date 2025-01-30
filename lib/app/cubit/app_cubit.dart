import 'dart:io';
import 'dart:ui';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:user_repository/user_repository.dart';

part 'app_state.dart';

class AppCubit extends Cubit<AppState> {
  AppCubit(this.userRepository) : super(const AppState());

  final UserRepository userRepository;

  Future<void> initialLoad() async {
    final language = userRepository.getLanguage();
    if (language == null) {
      final deviceLanguage = Platform.localeName.split('_').first;
      await userRepository.saveLanguage(deviceLanguage);
    }

    final darkTheme = userRepository.getDarkTheme();
    if (darkTheme == null) {
      final deviceBrightness = PlatformDispatcher.instance.platformBrightness;
      await userRepository.saveDarkTheme(
        darkTheme: deviceBrightness == Brightness.dark,
      );
    }

    emit(
      state.copyWith(
        locale: Locale(userRepository.getLanguage()!),
        darkTheme: userRepository.getDarkTheme(),
      ),
    );
  }

  Future<void> changeLanguage(String language) async {
    await userRepository.saveLanguage(language);
    emit(state.copyWith(locale: Locale(language)));
  }

  Future<void> toggleTheme() async {
    await userRepository.saveDarkTheme(darkTheme: !(state.darkTheme ?? false));
    emit(state.copyWith(darkTheme: !(state.darkTheme ?? false)));
  }
}
