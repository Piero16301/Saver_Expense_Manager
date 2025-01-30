import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'expenses_home_state.dart';

class ExpensesHomeCubit extends Cubit<ExpensesHomeState> {
  ExpensesHomeCubit() : super(const ExpensesHomeState());

  void init() {
    final now = DateTime.now();
    emit(state.copyWith(monthSelected: DateTime(now.year, now.month)));
  }

  void changeMonth(DateTime? month) {
    if (month == null) return;
    emit(state.copyWith(monthSelected: DateTime(month.year, month.month)));
  }

  void changeExplodeIndex(int? index) {
    emit(state.copyWith(explodeIndex: index));
  }

  void nextMonth() {
    final monthSelected = state.monthSelected!;
    if (monthSelected.month == 12) {
      emit(
        state.copyWith(
          monthSelected: DateTime(monthSelected.year + 1),
        ),
      );
    } else {
      emit(
        state.copyWith(
          monthSelected: DateTime(monthSelected.year, monthSelected.month + 1),
        ),
      );
    }
  }

  void previousMonth() {
    final monthSelected = state.monthSelected!;
    if (monthSelected.month == 1) {
      emit(
        state.copyWith(
          monthSelected: DateTime(monthSelected.year - 1, 12),
        ),
      );
    } else {
      emit(
        state.copyWith(
          monthSelected: DateTime(monthSelected.year, monthSelected.month - 1),
        ),
      );
    }
  }
}
