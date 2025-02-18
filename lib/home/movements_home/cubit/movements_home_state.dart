part of 'movements_home_cubit.dart';

class MovementsHomeState extends Equatable {
  const MovementsHomeState({
    this.filterCategory,
  });

  final Category? filterCategory;

  MovementsHomeState copyWith({
    Category? filterCategory,
  }) {
    return MovementsHomeState(
      filterCategory: filterCategory,
    );
  }

  @override
  List<Object?> get props => [
        filterCategory,
      ];
}
