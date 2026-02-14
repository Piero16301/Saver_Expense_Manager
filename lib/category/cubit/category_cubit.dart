import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:user_api/user_api.dart';

part 'category_state.dart';

class CategoryCubit extends Cubit<CategoryState> {
  CategoryCubit() : super(const CategoryState());

  void init(Category category) {
    emit(state.copyWith(category: category));
  }
}
