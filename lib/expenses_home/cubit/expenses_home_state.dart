part of 'expenses_home_cubit.dart';

class ExpensesHomeState extends Equatable {
  const ExpensesHomeState({
    this.selectedIndex = 0,
  });

  final int selectedIndex;

  ExpensesHomeState copyWith({
    int? selectedIndex,
  }) {
    return ExpensesHomeState(
      selectedIndex: selectedIndex ?? this.selectedIndex,
    );
  }

  @override
  List<Object> get props => [
        selectedIndex,
      ];
}
