part of 'home_cubit.dart';

class HomeState extends Equatable {
  const HomeState({
    required this.movementsShowType,
    required this.selectedIndex,
  });

  factory HomeState.initial() {
    return HomeState(
      movementsShowType: MovementsShowType.fromString(
        getIt<RemoteConfigService>().transactionsInitialView,
      ),
      selectedIndex: AppFunctions.getInitialTabIndex(
        getIt<RemoteConfigService>().homeInitialTab,
      ),
    );
  }

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
