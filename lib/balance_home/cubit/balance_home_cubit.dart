import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'balance_home_state.dart';

class BalanceHomeCubit extends Cubit<BalanceHomeState> {
  BalanceHomeCubit() : super(const BalanceHomeState());

  void toggleIndex(int index) {
    emit(state.copyWith(selectedIndex: index));
  }
}
