import 'dart:async';

import 'package:saver_expense_manager/app/app.dart';

class DatabaseService {
  DatabaseService({required DatabaseRepository databaseRepository})
      : _databaseRepository = databaseRepository;

  final DatabaseRepository _databaseRepository;

  String get newId => _databaseRepository.newId;

  void saveMovement({required Movement movement}) {
    _databaseRepository.saveMovement(movement: movement);
  }

  Stream<List<Category>> getCategoriesStream() {
    return _databaseRepository.getCategoriesStream();
  }

  Stream<List<Movement>> getMovementsStream({
    required String userId,
    DateTime? startDate,
    DateTime? endDate,
    CategoryType? type,
    String? categoryId,
    int? limit,
    bool orderByDate = false,
  }) {
    return _databaseRepository.getMovementsStream(
      userId: userId,
      startDate: startDate,
      endDate: endDate,
      type: type,
      categoryId: categoryId,
      limit: limit,
      orderByDate: orderByDate,
    );
  }

  Future<List<Movement>> getMovements({
    required String userId,
    DateTime? from,
    DateTime? to,
  }) async {
    return _databaseRepository.getMovements(
      userId: userId,
      from: from,
      to: to,
    );
  }

  void deleteMovement({required String movementId}) {
    _databaseRepository.deleteMovement(movementId: movementId);
  }
}
