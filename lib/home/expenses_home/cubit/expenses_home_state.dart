part of 'expenses_home_cubit.dart';

class ExpensesHomeState extends Equatable {
  const ExpensesHomeState({
    this.monthSelected,
    this.explodeIndex = 0,
    this.data = const <ChartData>[],
  });

  final DateTime? monthSelected;
  final int explodeIndex;
  final List<ChartData> data;

  ExpensesHomeState copyWith({
    DateTime? monthSelected,
    int? explodeIndex,
    List<ChartData>? data,
  }) {
    return ExpensesHomeState(
      monthSelected: monthSelected ?? this.monthSelected,
      explodeIndex: explodeIndex ?? this.explodeIndex,
      data: data ?? this.data,
    );
  }

  @override
  List<Object?> get props => [
        monthSelected,
        explodeIndex,
        data,
      ];
}
