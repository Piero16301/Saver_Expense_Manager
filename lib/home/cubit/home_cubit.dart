import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:saver_expense_manager/app/app.dart';

part 'home_state.dart';

class HomeCubit extends Cubit<HomeState> {
  HomeCubit() : super(const HomeState());

  void toggleSelectedIndex(int index) {
    emit(state.copyWith(selectedIndex: index));
  }

  void toggleMovementsShow() {
    emit(
      state.copyWith(
        movementsShowType: state.movementsShowType.isList
            ? MovementsShowType.chart
            : MovementsShowType.list,
      ),
    );
  }
}
