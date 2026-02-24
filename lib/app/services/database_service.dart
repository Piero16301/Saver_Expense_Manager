import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:saver_expense_manager/app/app.dart';

class DatabaseService {
  DatabaseService() : _firestore = FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  FirebaseFirestore get firestore => _firestore;

  Stream<List<Category>> getCategoriesStream() {
    return _firestore
        .collection(AppVariables.categoriesCollection)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => Category.fromJson(doc.data())).toList();
    });
  }

  Stream<List<Movement>> getMonthMovementsStream({
    required String userId,
    required DateTime monthSelected,
    required CategoryType type,
  }) {
    return _firestore
        .collection(AppVariables.movementsCollection)
        .where('user', isEqualTo: userId)
        .where('category.type', isEqualTo: type.value)
        .where(
          'date',
          isGreaterThanOrEqualTo: Timestamp.fromDate(
            DateTime(monthSelected.year, monthSelected.month),
          ),
        )
        .where(
          'date',
          isLessThan: Timestamp.fromDate(
            DateTime(
              monthSelected.month == 12
                  ? monthSelected.year + 1
                  : monthSelected.year,
              monthSelected.month == 12 ? 1 : monthSelected.month + 1,
            ),
          ),
        )
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => Movement.fromJson(doc.data())).toList();
    });
  }

  Stream<List<Movement>> getUserMovementsRangeStream({
    required String userId,
    required DateTime startMonth,
    required DateTime endMonth,
  }) {
    return _firestore
        .collection(AppVariables.movementsCollection)
        .where('user', isEqualTo: userId)
        .where(
          'date',
          isGreaterThanOrEqualTo: Timestamp.fromDate(
            DateTime(startMonth.year, startMonth.month),
          ),
        )
        .where(
          'date',
          isLessThan: Timestamp.fromDate(
            DateTime(
              endMonth.month == 12 ? endMonth.year + 1 : endMonth.year,
              endMonth.month == 12 ? 1 : endMonth.month + 1,
            ),
          ),
        )
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => Movement.fromJson(doc.data())).toList();
    });
  }

  Query<Map<String, dynamic>> getCategoryMovementsQuery({
    required String userId,
    required DateTime monthSelected,
    required Category category,
  }) {
    return _firestore
        .collection(AppVariables.movementsCollection)
        .where('user', isEqualTo: userId)
        .where('category.id', isEqualTo: category.id)
        .where(
          'date',
          isGreaterThanOrEqualTo: Timestamp.fromDate(
            DateTime(monthSelected.year, monthSelected.month),
          ),
        )
        .where(
          'date',
          isLessThan: Timestamp.fromDate(
            DateTime(
              monthSelected.month == 12
                  ? monthSelected.year + 1
                  : monthSelected.year,
              monthSelected.month == 12 ? 1 : monthSelected.month + 1,
            ),
          ),
        )
        .orderBy('date', descending: true);
  }

  Query<Map<String, dynamic>> getExpenseTypeMovementsQuery({
    required String userId,
    required DateTime monthSelected,
    required CategoryType expenseType,
  }) {
    return _firestore
        .collection(AppVariables.movementsCollection)
        .where('user', isEqualTo: userId)
        .where('category.type', isEqualTo: expenseType.value)
        .where(
          'date',
          isGreaterThanOrEqualTo: Timestamp.fromDate(
            DateTime(monthSelected.year, monthSelected.month),
          ),
        )
        .where(
          'date',
          isLessThan: Timestamp.fromDate(
            DateTime(
              monthSelected.month == 12
                  ? monthSelected.year + 1
                  : monthSelected.year,
              monthSelected.month == 12 ? 1 : monthSelected.month + 1,
            ),
          ),
        )
        .orderBy('date', descending: true);
  }

  Query<Map<String, dynamic>> getUserMovementsQuery({
    required String userId,
    required CategoryType? type,
    required Category? category,
  }) {
    var query = _firestore
        .collection(AppVariables.movementsCollection)
        .where('user', isEqualTo: userId);

    if (type != null) {
      query = query.where(
        'category.type',
        isEqualTo: type == CategoryType.expense
            ? CategoryType.expense.value
            : CategoryType.income.value,
      );
    }

    if (category != null) {
      query = query.where('category.id', isEqualTo: category.id);
    }

    return query.orderBy('date', descending: true);
  }

  Stream<List<Movement>> getTrendChartStream({
    required String userId,
    required DateTime startMonth,
    required DateTime endMonth,
    required Category category,
  }) {
    return _firestore
        .collection(AppVariables.movementsCollection)
        .where('user', isEqualTo: userId)
        .where('category.id', isEqualTo: category.id)
        .where(
          'date',
          isGreaterThanOrEqualTo: Timestamp.fromDate(
            DateTime(startMonth.year, startMonth.month),
          ),
        )
        .where(
          'date',
          isLessThan: Timestamp.fromDate(
            DateTime(
              endMonth.month == 12 ? endMonth.year + 1 : endMonth.year,
              endMonth.month == 12 ? 1 : endMonth.month + 1,
            ),
          ),
        )
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => Movement.fromJson(doc.data())).toList();
    });
  }

  Stream<List<Movement>> getMovementsStream({
    required String userId,
    DateTime? from,
    DateTime? to,
    int? limit,
  }) {
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
      query = query.where(
        'date',
        isLessThan: Timestamp.fromDate(to),
      );
    }

    if (limit != null) {
      query = query.limit(limit);
    }

    return query.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => Movement.fromJson(doc.data())).toList();
    });
  }

  Future<List<Movement>> getMovements({
    required String userId,
    DateTime? from,
    DateTime? to,
  }) {
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
      query = query.where(
        'date',
        isLessThan: Timestamp.fromDate(to),
      );
    }

    return query.get().then((snapshot) {
      return snapshot.docs.map((doc) => Movement.fromJson(doc.data())).toList();
    });
  }
}
