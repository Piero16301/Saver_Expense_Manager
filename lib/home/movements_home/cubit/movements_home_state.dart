part of 'movements_home_cubit.dart';

class MovementsHomeState extends Equatable {
  const MovementsHomeState({
    this.filterType,
    this.filterCategory,
  });

  final CategoryType? filterType;
  final Category? filterCategory;

  MovementsHomeState copyWith({
    CategoryType? filterType,
    Category? filterCategory,
  }) {
    return MovementsHomeState(
      filterType: filterType,
      filterCategory: filterCategory,
    );
  }

  @override
  List<Object?> get props => [
        filterType,
        filterCategory,
      ];
}
