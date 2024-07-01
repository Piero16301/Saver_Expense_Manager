part of 'app_cubit.dart';

class AppState extends Equatable {
  const AppState({
    this.language = 'es',
    this.theme = 'light',
  });

  final String language;
  final String theme;

  AppState copyWith({
    String? language,
    String? theme,
  }) {
    return AppState(
      language: language ?? this.language,
      theme: theme ?? this.theme,
    );
  }

  @override
  List<Object> get props => [
        language,
        theme,
      ];
}
