part of 'app_cubit.dart';

class AppState extends Equatable {
  const AppState({
    this.locale,
    this.darkTheme,
    this.model,
  });

  final Locale? locale;
  final bool? darkTheme;
  final GenerativeModel? model;

  AppState copyWith({
    Locale? locale,
    bool? darkTheme,
    GenerativeModel? model,
  }) {
    return AppState(
      locale: locale ?? this.locale,
      darkTheme: darkTheme ?? this.darkTheme,
      model: model ?? this.model,
    );
  }

  @override
  List<Object?> get props => [
    locale,
    darkTheme,
    model,
  ];
}
