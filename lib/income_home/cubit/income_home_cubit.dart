import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'income_home_state.dart';

class IncomeHomeCubit extends Cubit<IncomeHomeState> {
  IncomeHomeCubit() : super(const IncomeHomeState());

  void toggleIndex(int index) {
    emit(state.copyWith(selectedIndex: index));
  }
}
