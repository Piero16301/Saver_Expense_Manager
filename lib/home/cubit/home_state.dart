part of 'home_cubit.dart';

class HomeState extends Equatable {
  const new({required this.selectedIndex});

  factory initial() {
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
