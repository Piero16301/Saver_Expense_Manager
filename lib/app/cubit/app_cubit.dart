import 'dart:io';
import 'dart:ui';

import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:saver_expense_manager/app/app.dart';
import 'package:user_api/user_api.dart';
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

    // Setting the model
    final model = GenerativeModel(
      model: 'gemini-2.0-flash',
      apiKey: dotenv.get('GEN_API_KEY'),
      generationConfig: GenerationConfig(responseMimeType: 'application/json'),
      safetySettings: [
        SafetySetting(HarmCategory.dangerousContent, HarmBlockThreshold.none),
      ],
    );
    emit(state.copyWith(model: model));
  }

  Future<void> changeLanguage(String language) async {
    await userRepository.saveLanguage(language);
    emit(state.copyWith(locale: Locale(language)));
  }

  Future<void> toggleTheme() async {
    await userRepository.saveDarkTheme(darkTheme: !(state.darkTheme ?? false));
    emit(state.copyWith(darkTheme: !(state.darkTheme ?? false)));
  }

  Future<void> loadCategories() async {
    final categoriesJson =
        await FirebaseFirestore.instance.collection(categoriesCollection).get();
    final categories = categoriesJson.docs
        .map((category) => Category.fromJson(category.data()))
        .toList();
    emit(state.copyWith(categories: categories));
  }
}
