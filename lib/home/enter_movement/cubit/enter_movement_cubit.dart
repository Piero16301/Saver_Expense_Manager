import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:saver_expense_manager/app/app.dart';
import 'package:user_api/user_api.dart';

part 'enter_movement_state.dart';

class EnterMovementCubit extends Cubit<EnterMovementState> {
  EnterMovementCubit() : super(const EnterMovementState());

  void init(Movement movement, List<Category> categories) {
    emit(
      state.copyWith(
        title: movement.title,
        description: movement.description,
        date: movement.date,
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

  void attachAdd(String value) {
    final updatedAttachments = List<String>.from(state.attachments)..add(value);
    emit(state.copyWith(attachments: updatedAttachments));
  }

  Future<void> attachRemove(String value) async {
    final updatedAttachments = List<String>.from(state.attachments)
      ..remove(value);
    emit(state.copyWith(attachments: updatedAttachments));

    // Remove the file from Firebase Storage
    try {
      await FirebaseStorage.instance.ref().child(value).delete();
    } catch (e) {
      debugPrint('Error deleting file: $e');
    }
  }

  bool saveMovement(String userId) {
    // Save movement in Firebase Firestore
    final docId =
        FirebaseFirestore.instance.collection(movementsCollection).doc().id;
    FirebaseFirestore.instance.collection(movementsCollection).doc(docId).set(
          Movement(
            id: docId,
            title: state.title,
            description: state.description,
            date: state.date!,
            category: state.category!,
            price: state.price,
            company: state.company,
            attachments: state.attachments,
            user: userId,
          ).toJson(),
        );

    return true;
  }
}
