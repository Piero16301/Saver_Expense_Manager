import 'dart:async';

import 'package:saver_expense_manager/app/app.dart';

class DatabaseService {
  new({required this._databaseRepository});

  final DatabaseRepository _databaseRepository;

  String get newId => _databaseRepository.newId;

  void saveMovement({required Movement movement}) {
    try {
      unawaited(
        _databaseRepository.saveMovement(movement: movement).catchError((
          Object e,
          StackTrace stackTrace,
        ) {
          getIt<CrashService>().recordError(
            e,
            stackTrace,
            reason: 'DatabaseService saveMovement error',
          );
        }),
      );
    } on Exception catch (e, stackTrace) {
      getIt<CrashService>().recordError(
        e,
        stackTrace,
        reason: 'DatabaseService saveMovement error',
      );
    }
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
    final performance = getIt<PerformanceService>();
    final trace = performance.startTrace('firestore_get_movements');
    try {
      return await _databaseRepository.getMovements(
        userId: userId,
        from: from,
        to: to,
      );
    } catch (e, stackTrace) {
      getIt<CrashService>().recordError(
        e,
        stackTrace,
        reason: 'DatabaseService getMovements error',
      );
      rethrow;
    } finally {
      performance.stopTrace(trace);
    }
  }

  void deleteMovement({required String movementId}) {
    try {
      unawaited(
        _databaseRepository.deleteMovement(movementId: movementId).catchError((
          Object e,
          StackTrace stackTrace,
        ) {
          getIt<CrashService>().recordError(
            e,
            stackTrace,
            reason: 'DatabaseService deleteMovement error',
          );
        }),
      );
    } on Exception catch (e, stackTrace) {
      getIt<CrashService>().recordError(
        e,
        stackTrace,
        reason: 'DatabaseService deleteMovement error',
      );
    }
  }
}
