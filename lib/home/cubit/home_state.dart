part of 'home_cubit.dart';

class HomeState extends Equatable {
  const HomeState({
    this.selectedIndex = 0,
    this.movementsShowType = MovementsShowType.list,
  });

  final int selectedIndex;
  final MovementsShowType movementsShowType;

  HomeState copyWith({
    int? selectedIndex,
    MovementsShowType? movementsShowType,
  }) {
    return HomeState(
      selectedIndex: selectedIndex ?? this.selectedIndex,
      movementsShowType: movementsShowType ?? this.movementsShowType,
    );
  }

  @override
  List<Object> get props => [
        selectedIndex,
        movementsShowType,
      ];
}
