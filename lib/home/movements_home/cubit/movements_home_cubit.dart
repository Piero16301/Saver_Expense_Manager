import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:user_api/user_api.dart';

part 'movements_home_state.dart';

class MovementsHomeCubit extends Cubit<MovementsHomeState> {
  MovementsHomeCubit() : super(const MovementsHomeState());

  void changeFilterCategory(Category? category) {
    emit(state.copyWith(filterCategory: category));
  }
}
