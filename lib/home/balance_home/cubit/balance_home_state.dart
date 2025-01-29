part of 'balance_home_cubit.dart';

class BalanceHomeState extends Equatable {
  const BalanceHomeState({
    this.monthSelected,
  });

  final DateTime? monthSelected;

  BalanceHomeState copyWith({
    DateTime? monthSelected,
  }) {
    return BalanceHomeState(
      monthSelected: monthSelected ?? this.monthSelected,
    );
  }

  @override
  List<Object?> get props => [
        monthSelected,
      ];
}
