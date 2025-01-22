import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'expenses_home_state.dart';

class ExpensesHomeCubit extends Cubit<ExpensesHomeState> {
  ExpensesHomeCubit() : super(const ExpensesHomeState());

  void init() {
    emit(state.copyWith(monthSelected: DateTime.now()));
  }

  void changeMonth(DateTime? month) {
    if (month == null) {
      return;
    }
    if (month.isAfter(DateTime.now())) {
      return;
    }
    emit(state.copyWith(monthSelected: month));
  }
}
