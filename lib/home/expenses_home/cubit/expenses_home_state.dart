part of 'expenses_home_cubit.dart';

class ExpensesHomeState extends Equatable {
  const ExpensesHomeState({
    this.monthSelected,
  });

  final DateTime? monthSelected;

  ExpensesHomeState copyWith({
    DateTime? monthSelected,
  }) {
    return ExpensesHomeState(
      monthSelected: monthSelected ?? this.monthSelected,
    );
  }

  @override
  List<Object?> get props => [
        monthSelected,
      ];
}
