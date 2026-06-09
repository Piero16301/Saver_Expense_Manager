part of 'expenses_home_cubit.dart';

class ExpensesHomeState extends Equatable {
  const ExpensesHomeState({
    this.monthSelected,
    this.selectedIndex = 0,
    this.data = const <CategoryData>[],
  });

  final DateTime? monthSelected;
  final int selectedIndex;
  final List<CategoryData> data;

  ExpensesHomeState copyWith({
    DateTime? monthSelected,
    int? selectedIndex,
    List<CategoryData>? data,
  }) {
    return ExpensesHomeState(
      monthSelected: monthSelected ?? this.monthSelected,
      selectedIndex: selectedIndex ?? this.selectedIndex,
      data: data ?? this.data,
    );
  }

  @override
  List<Object?> get props => [monthSelected, selectedIndex, data];
}
