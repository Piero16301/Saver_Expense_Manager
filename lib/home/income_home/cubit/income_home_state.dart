part of 'income_home_cubit.dart';

class IncomeHomeState extends Equatable {
  const IncomeHomeState({
    this.monthSelected,
    this.selectedIndex = 0,
    this.data = const <ChartData>[],
  });

  final DateTime? monthSelected;
  final int selectedIndex;
  final List<ChartData> data;

  IncomeHomeState copyWith({
    DateTime? monthSelected,
    int? selectedIndex,
    List<ChartData>? data,
  }) {
    return IncomeHomeState(
      monthSelected: monthSelected ?? this.monthSelected,
      selectedIndex: selectedIndex ?? this.selectedIndex,
      data: data ?? this.data,
    );
  }

  @override
  List<Object?> get props => [
        monthSelected,
        selectedIndex,
        data,
      ];
}
