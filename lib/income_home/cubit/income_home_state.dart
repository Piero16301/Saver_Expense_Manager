part of 'income_home_cubit.dart';

class IncomeHomeState extends Equatable {
  const IncomeHomeState({
    this.selectedIndex = 0,
  });

  final int selectedIndex;

  IncomeHomeState copyWith({
    int? selectedIndex,
  }) {
    return IncomeHomeState(
      selectedIndex: selectedIndex ?? this.selectedIndex,
    );
  }

  @override
  List<Object> get props => [
        selectedIndex,
      ];
}
