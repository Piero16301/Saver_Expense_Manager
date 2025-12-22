part of 'app_cubit.dart';

class AppState extends Equatable {
  const AppState({
    this.language = 'en_US',
    this.theme = 'LIGHT',
    this.baseColor = 'INDIGO',
    this.fontFamily = 'Nunito_regular',
  });

  final String language;
  final String theme;
  final String baseColor;
  final String fontFamily;

  AppState copyWith({
    String? language,
    String? theme,
    String? baseColor,
    String? fontFamily,
  }) {
    return AppState(
      language: language ?? this.language,
      theme: theme ?? this.theme,
      baseColor: baseColor ?? this.baseColor,
      fontFamily: fontFamily ?? this.fontFamily,
    );
  }

  @override
  List<Object> get props => [
        language,
        theme,
        baseColor,
        fontFamily,
      ];
}
