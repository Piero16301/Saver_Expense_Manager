part of 'movements_home_cubit.dart';

class MovementsHomeState extends Equatable {
  const MovementsHomeState({
    this.filterType,
    this.filterCategory,
  });

  final CategoryType? filterType;
  final Category? filterCategory;

  MovementsHomeState copyWith({
    CategoryType? Function()? filterType,
    Category? Function()? filterCategory,
  }) {
    return MovementsHomeState(
      filterType: filterType != null ? filterType() : this.filterType,
      filterCategory:
          filterCategory != null ? filterCategory() : this.filterCategory,
    );
  }

  @override
  List<Object?> get props => [
        filterType,
        filterCategory,
      ];
}
