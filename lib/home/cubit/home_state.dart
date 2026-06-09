part of 'home_cubit.dart';

class HomeState extends Equatable {
  const HomeState({required this.selectedIndex});

  factory HomeState.initial() {
    return HomeState(
      selectedIndex: AppFunctions.getInitialTabIndex(
        getIt<RemoteConfigService>().homeInitialTab,
      ),
    );
  }

  final int selectedIndex;

  HomeState copyWith({int? selectedIndex}) {
    return HomeState(selectedIndex: selectedIndex ?? this.selectedIndex);
  }

  @override
  List<Object> get props => [selectedIndex];
}
