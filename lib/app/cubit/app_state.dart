part of 'app_cubit.dart';

class AppState extends Equatable {
  const AppState({
    this.locale,
    this.darkTheme,
  });

  final Locale? locale;
  final bool? darkTheme;

  AppState copyWith({
    Locale? locale,
    bool? darkTheme,
  }) {
    return AppState(
      locale: locale ?? this.locale,
      darkTheme: darkTheme ?? this.darkTheme,
    );
  }

  @override
  List<Object?> get props => [
    locale,
    darkTheme,
  ];
}
