import 'dart:async';
import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/services.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:saver_expense_manager/app/app.dart';
import 'package:saver_expense_manager/l10n/l10n.dart';

part 'movement_state.dart';

class MovementCubit extends Cubit<MovementState> {
  MovementCubit() : super(const MovementState());

  void init(Movement movement, List<Category> categories) {
    emit(
      state.copyWith(
        id: movement.id,
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
        movementRecap: movement.movementRecap,
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
      await getIt<RemoteStorageService>().deleteFile(value);
    } on Exception catch (_) {}
  }

  Future<void> attachOpen(String value) async {
    try {
      final appTemDir = await getApplicationCacheDirectory();
      final filePath = '${appTemDir.path}/$value';
      final file = File(filePath);

      final data =
          await getIt<RemoteStorageService>().getData(value) ?? Uint8List(0);
      await file.writeAsBytes(data.toList());
      await OpenFile.open(filePath);
    } on Exception catch (_) {}
  }

  bool saveMovement(String userId, AppLocalizations l10n) {
    final nowDate = DateTime.now();

    // Save movement in Firebase Firestore
    final docId = state.id.isEmpty
        ? getIt<DatabaseService>()
            .firestore
            .collection(AppVariables.movementsCollection)
            .doc()
            .id
        : state.id;
    try {
      unawaited(
        getIt<DatabaseService>()
            .firestore
            .collection(AppVariables.movementsCollection)
            .doc(docId)
            .set(
              Movement(
                id: docId,
                title: state.title,
                description: state.description,
                date: state.date!.copyWith(
                  hour: nowDate.hour,
                  minute: nowDate.minute,
                  second: nowDate.second,
                ),
                category: state.category!,
                price: state.price,
                company: state.company,
                attachments: state.attachments,
                user: userId,
                movementRecap: state.movementRecap.isNotEmpty
                    ? state.movementRecap
                    : buildMovementRecap(l10n),
              ).toJson(),
            ),
      );
    } on Exception catch (_) {
      return false;
    }
    return true;
  }

  String buildMovementRecap(AppLocalizations l10n) {
    if (state.category?.type == CategoryType.expense) {
      return l10n
          .movementExpenseRecapTemplate(state.company, state.title)
          .replaceAll('<<amount>>', '{{amount}}')
          .replaceAll('<<date>>', '{{date}}');
    } else {
      return l10n
          .movementIncomeRecapTemplate(state.company, state.title)
          .replaceAll('<<amount>>', '{{amount}}')
          .replaceAll('<<date>>', '{{date}}');
    }
  }

  bool removeMovement() {
    if (state.id.isEmpty) {
      return false;
    }

    // Remove movement from Firebase Firestore
    unawaited(
      getIt<DatabaseService>()
          .firestore
          .collection(AppVariables.movementsCollection)
          .doc(state.id)
          .delete(),
    );

    // Remove associated attachments from Firebase Storage
    for (final attachment in state.attachments) {
      unawaited(getIt<RemoteStorageService>().deleteFile(attachment));
    }

    return true;
  }
}
