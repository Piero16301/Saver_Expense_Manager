import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:saver_expense_manager/app/app.dart';
import 'package:user_api/user_api.dart';

part 'movements_home_state.dart';

class MovementsHomeCubit extends Cubit<MovementsHomeState> {
  MovementsHomeCubit() : super(const MovementsHomeState());

  void changeFilterType(CategoryType? type) {
    emit(
      state.copyWith(filterType: type, filterCategory: state.filterCategory),
    );
  }

  void changeFilterCategory(Category? category) {
    emit(
      state.copyWith(filterType: state.filterType, filterCategory: category),
    );
  }

  void clearFilterType() {
    emit(const MovementsHomeState());
  }

  void clearFilterCategory() {
    emit(
      state.copyWith(
        filterType: state.filterType,
        // ignore: avoid_redundant_argument_values
        filterCategory: null,
      ),
    );
  }

  Future<QuerySnapshot<Map<String, dynamic>>> getMovements({
    required String userId,
    required QueryDocumentSnapshot<Object?>? lastDocument,
  }) async {
    return getUserMovements(
      userId: userId,
      type: state.filterType,
      category: state.filterCategory,
      lastDocument: lastDocument,
    );
  }
}
