import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:saver_expense_manager/app/app.dart';

abstract class DatabaseRepository {
  String get newId;

  void saveMovement({required Movement movement});
  Stream<List<Category>> getCategoriesStream();
  Stream<List<Movement>> getMovementsStream({
    required String userId,
    DateTime? startDate,
    DateTime? endDate,
    CategoryType? type,
    String? categoryId,
    int? limit,
    bool orderByDate = false,
  });
  Future<List<Movement>> getMovements({
    required String userId,
    DateTime? from,
    DateTime? to,
  });
  void deleteMovement({required String movementId});
}

class MockDatabaseRepository implements DatabaseRepository {
  static const List<Category> _categories = [
    Category(
      id: '1',
      name: 'FEEDING',
      icon: 'RESTAURANT',
      color: '#FFFFB74D',
      type: CategoryType.expense,
    ),
    Category(
      id: '2',
      name: 'FREELANCE',
      icon: 'PERSON_SEARCH',
      color: '#FF66BB6A',
      type: CategoryType.income,
    ),
  ];

  final List<Movement> _movements = [
    Movement(
      id: '1',
      title: 'Purchase of groceries and a bag',
      description: 'Purchase of groceries and a bag at Metro.',
      date: DateTime(2026, 3, 23),
      category: _categories.first,
      price: 100,
      user: '1',
    ),
    Movement(
      id: '2',
      title: 'Freelance payment',
      description: 'Payment for freelance services rendered.',
      date: DateTime(2026, 3, 22),
      category: _categories.last,
      price: 500,
      user: '1',
    ),
  ];

  @override
  String get newId => DateTime.now().millisecondsSinceEpoch.toString();

  @override
  void saveMovement({required Movement movement}) {
    _movements.add(movement);
  }

  @override
  Stream<List<Category>> getCategoriesStream() {
    return Stream.value(_categories);
  }

  @override
  Stream<List<Movement>> getMovementsStream({
    required String userId,
    DateTime? startDate,
    DateTime? endDate,
    CategoryType? type,
    String? categoryId,
    int? limit,
    bool orderByDate = false,
  }) {
    return Stream.value(_movements);
  }

  @override
  Future<List<Movement>> getMovements({
    required String userId,
    DateTime? from,
    DateTime? to,
  }) {
    return Future.value(_movements);
  }

  @override
  void deleteMovement({required String movementId}) {
    _movements.removeWhere((movement) => movement.id == movementId);
  }
}

class FirestoreDatabaseRepository implements DatabaseRepository {
  FirestoreDatabaseRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  @override
  String get newId =>
      _firestore.collection(AppVariables.movementsCollection).doc().id;

  @override
  void saveMovement({required Movement movement}) {
    try {
      unawaited(
        _firestore
            .collection(AppVariables.movementsCollection)
            .doc(movement.id)
            .set(movement.toJson()),
      );
    } on Exception catch (e, stackTrace) {
      getIt<CrashService>().recordError(
        e,
        stackTrace,
        reason: 'DatabaseService saveMovement error',
      );
    }
  }

  @override
  Stream<List<Category>> getCategoriesStream() {
    return _firestore
        .collection(AppVariables.categoriesCollection)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => Category.fromJson(doc.data())).toList();
    });
  }

  @override
  Stream<List<Movement>> getMovementsStream({
    required String userId,
    DateTime? startDate,
    DateTime? endDate,
    CategoryType? type,
    String? categoryId,
    int? limit,
    bool orderByDate = false,
  }) {
    var query = _firestore
        .collection(AppVariables.movementsCollection)
        .where('user', isEqualTo: userId);

    if (type != null) {
      query = query.where('category.type', isEqualTo: type.value);
    }
    if (categoryId != null) {
      query = query.where('category.id', isEqualTo: categoryId);
    }
    if (startDate != null) {
      query = query.where(
        'date',
        isGreaterThanOrEqualTo: Timestamp.fromDate(startDate),
      );
    }
    if (endDate != null) {
      query = query.where('date', isLessThan: Timestamp.fromDate(endDate));
    }
    if (orderByDate) {
      query = query.orderBy('date', descending: true);
    }
    if (limit != null) {
      query = query.limit(limit);
    }

    return query.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => Movement.fromJson(doc.data())).toList();
    });
  }

  @override
  Future<List<Movement>> getMovements({
    required String userId,
    DateTime? from,
    DateTime? to,
  }) async {
    final performance = getIt<PerformanceService>();
    final trace = performance.startTrace('firestore_get_movements');
    try {
      var query = _firestore
          .collection(AppVariables.movementsCollection)
          .where('user', isEqualTo: userId);

      if (from != null) {
        query = query.where(
          'date',
          isGreaterThanOrEqualTo: Timestamp.fromDate(from),
        );
      }

      if (to != null) {
        query = query.where('date', isLessThan: Timestamp.fromDate(to));
      }

      final snapshot = await query.get();
      return snapshot.docs.map((doc) => Movement.fromJson(doc.data())).toList();
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

  @override
  void deleteMovement({required String movementId}) {
    try {
      unawaited(
        _firestore
            .collection(AppVariables.movementsCollection)
            .doc(movementId)
            .delete(),
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
