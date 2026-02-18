part of 'app_cubit.dart';

class AppState extends Equatable {
  const AppState({
    this.language = const Locale('en', 'US'),
    this.theme = ThemeMode.system,
    this.baseColor = Colors.green,
    this.fontFamily = 'Poppins',
    this.receiptsModel = ModelType.cloud,
    this.expensesModel = ModelType.cloud,
  });

  final Locale language;
  final ThemeMode theme;
  final Color baseColor;
  final String fontFamily;
  final ModelType receiptsModel;
  final ModelType expensesModel;

  AppState copyWith({
    Locale? language,
    ThemeMode? theme,
    Color? baseColor,
    String? fontFamily,
    ModelType? receiptsModel,
    ModelType? expensesModel,
  }) {
    return AppState(
      language: language ?? this.language,
      theme: theme ?? this.theme,
      baseColor: baseColor ?? this.baseColor,
      fontFamily: fontFamily ?? this.fontFamily,
      receiptsModel: receiptsModel ?? this.receiptsModel,
      expensesModel: expensesModel ?? this.expensesModel,
    );
  }

  @override
  List<Object> get props => [
        language,
        theme,
        baseColor,
        fontFamily,
        receiptsModel,
        expensesModel,
      ];
}
