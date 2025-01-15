part of 'balance_home_cubit.dart';

class BalanceHomeState extends Equatable {
  const BalanceHomeState({
    this.selectedIndex = 0,
  });

  final int selectedIndex;

  BalanceHomeState copyWith({
    int? selectedIndex,
  }) {
    return BalanceHomeState(
      selectedIndex: selectedIndex ?? this.selectedIndex,
    );
  }

  @override
  List<Object> get props => [
        selectedIndex,
      ];
}
