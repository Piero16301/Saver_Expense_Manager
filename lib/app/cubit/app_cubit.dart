import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'app_state.dart';

class AppCubit extends Cubit<AppState> {
  AppCubit() : super(const AppState());

  void changeLanguage(String code) {
    emit(state.copyWith(language: code));
  }

  void changeTheme() {
    emit(state.copyWith(theme: state.theme == 'light' ? 'dark' : 'light'));
  }
}
