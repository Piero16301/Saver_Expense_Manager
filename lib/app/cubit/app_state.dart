part of 'app_cubit.dart';

class AppState extends Equatable {
  const AppState({
    this.locale,
    this.darkTheme,
    this.categories = const <Category>[],
    this.model,
  });

  final Locale? locale;
  final bool? darkTheme;
  final List<Category> categories;
  final GenerativeModel? model;

  AppState copyWith({
    Locale? locale,
    bool? darkTheme,
    List<Category>? categories,
    GenerativeModel? model,
  }) {
    return AppState(
      locale: locale ?? this.locale,
      darkTheme: darkTheme ?? this.darkTheme,
      categories: categories ?? this.categories,
      model: model ?? this.model,
    );
  }

  @override
  List<Object?> get props => [locale, darkTheme, categories, model];
}
