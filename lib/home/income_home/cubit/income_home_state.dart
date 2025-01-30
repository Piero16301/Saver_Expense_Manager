part of 'income_home_cubit.dart';

class IncomeHomeState extends Equatable {
  const IncomeHomeState({
    this.monthSelected,
    this.explodeIndex = 0,
  });

  final DateTime? monthSelected;
  final int explodeIndex;

  IncomeHomeState copyWith({
    DateTime? monthSelected,
    int? explodeIndex,
  }) {
    return IncomeHomeState(
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
