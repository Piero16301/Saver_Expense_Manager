part of 'income_home_cubit.dart';

class IncomeHomeState extends Equatable {
  const IncomeHomeState({
    this.monthSelected,
  });

  final DateTime? monthSelected;

  IncomeHomeState copyWith({
    DateTime? monthSelected,
  }) {
    return IncomeHomeState(
      monthSelected: monthSelected ?? this.monthSelected,
    );
  }

  @override
  List<Object?> get props => [
        monthSelected,
      ];
}
