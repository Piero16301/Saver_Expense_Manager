import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'expenses_home_state.dart';

class ExpensesHomeCubit extends Cubit<ExpensesHomeState> {
  ExpensesHomeCubit() : super(const ExpensesHomeState());

  void toggleIndex(int index) {
    emit(state.copyWith(selectedIndex: index));
  }
}
