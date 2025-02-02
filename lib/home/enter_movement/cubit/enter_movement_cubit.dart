import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:intl/intl.dart';
import 'package:user_api/user_api.dart';

part 'enter_movement_state.dart';

class EnterMovementCubit extends Cubit<EnterMovementState> {
  EnterMovementCubit() : super(const EnterMovementState());

  void init(Movement movement, List<Category> categories) {
    emit(
      state.copyWith(
        title: movement.title,
        description: movement.description,
        date: movement.date.isEmpty
            ? DateTime.now()
            : DateFormat('dd-MM-yyyy').parse(movement.date),
        categories: categories,
        category: movement.category == Category.empty
            ? categories.first
            : movement.category,
        price: movement.price,
        company: movement.company,
        attachments: movement.attachments,
      ),
    );
  }

  void titleChanged(String value) {
    emit(state.copyWith(title: value));
  }

  void descriptionChanged(String value) {
    emit(state.copyWith(description: value));
  }

  void dateChanged(DateTime value) {
    emit(state.copyWith(date: value));
  }

  void categoryChanged(Category? value) {
    emit(state.copyWith(category: value));
  }

  void priceChanged(String value) {
    emit(state.copyWith(price: double.tryParse(value) ?? 0.0));
  }

  void companyChanged(String value) {
    emit(state.copyWith(company: value));
  }
}
