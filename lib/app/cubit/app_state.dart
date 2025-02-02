part of 'app_cubit.dart';

class AppState extends Equatable {
  const AppState({
    this.locale,
    this.darkTheme,
    this.categories = const <Category>[],
  });

  final Locale? locale;
  final bool? darkTheme;
  final List<Category> categories;

  AppState copyWith({
    Locale? locale,
    bool? darkTheme,
    List<Category>? categories,
  }) {
    return AppState(
      locale: locale ?? this.locale,
      darkTheme: darkTheme ?? this.darkTheme,
      categories: categories ?? this.categories,
    );
  }

  @override
  List<Object?> get props => [
        locale,
        darkTheme,
        categories,
      ];
}
