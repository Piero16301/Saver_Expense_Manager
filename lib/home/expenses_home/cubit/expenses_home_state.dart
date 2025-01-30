part of 'expenses_home_cubit.dart';

class ExpensesHomeState extends Equatable {
  const ExpensesHomeState({
    this.monthSelected,
    this.explodeIndex = 0,
  });

  final DateTime? monthSelected;
  final int explodeIndex;

  ExpensesHomeState copyWith({
    DateTime? monthSelected,
    int? explodeIndex,
  }) {
    return ExpensesHomeState(
      monthSelected: monthSelected ?? this.monthSelected,
      explodeIndex: explodeIndex ?? this.explodeIndex,
    );
  }

  @override
  List<Object?> get props => [
        monthSelected,
        explodeIndex,
      ];
}
