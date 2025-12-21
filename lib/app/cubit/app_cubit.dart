import 'dart:io';
import 'dart:ui';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_ai/firebase_ai.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:user_repository/user_repository.dart';

part 'app_state.dart';

class AppCubit extends Cubit<AppState> {
  AppCubit(this.userRepository) : super(const AppState());

  final UserRepository userRepository;
  final GenerativeModel model = FirebaseAI.googleAI(
    appCheck: FirebaseAppCheck.instance,
    auth: FirebaseAuth.instance,
  ).generativeModel(
    // model: 'gemini-2.5-flash',
    model: 'gemini-3-flash-preview',
    safetySettings: [
      SafetySetting(
        HarmCategory.dangerousContent,
        HarmBlockThreshold.none,
        null,
      ),
    ],
    generationConfig: GenerationConfig(responseMimeType: 'application/json'),
  );

  Future<void> initialLoad() async {
    // Setting the language to the device language if it's not set
    final language = userRepository.getLanguage();
    if (language == null) {
      final deviceLanguage = Platform.localeName;
      await userRepository.saveLanguage(deviceLanguage);
    }
    emit(
      state.copyWith(
        locale: Locale(
          userRepository.getLanguage()!.split('_').first,
          userRepository.getLanguage()!.split('_').last,
        ),
      ),
    );

    // Setting the theme to the device theme if it's not set
    final darkTheme = userRepository.getDarkTheme();
    if (darkTheme == null) {
      final deviceBrightness = PlatformDispatcher.instance.platformBrightness;
      await userRepository.saveDarkTheme(
        darkTheme: deviceBrightness == Brightness.dark,
      );
    }
    emit(state.copyWith(darkTheme: userRepository.getDarkTheme()));
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
