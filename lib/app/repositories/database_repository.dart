import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:saver_expense_manager/app/app.dart';

abstract class DatabaseRepository {
  String get newId;

  Future<void> saveMovement({required Movement movement});
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
  Future<void> deleteMovement({required String movementId});
}

class MockDatabaseRepository implements DatabaseRepository {
  new() : _movements = _buildInitialMovements();

  static const List<Category> _categories = [
    Category(
      id: '1',
      name: 'TRANSPORT',
      icon: 'DIRECTIONS_CAR',
      color: '#FF64B5F6',
      type: CategoryType.expense,
    ),
    Category(
      id: '2',
      name: 'FEEDING',
      icon: 'RESTAURANT',
      color: '#FFFFB74D',
      type: CategoryType.expense,
    ),
    Category(
      id: '3',
      name: 'HEALTH',
      icon: 'LOCAL_HOSPITAL',
      color: '#FF81C784',
      type: CategoryType.expense,
    ),
    Category(
      id: '4',
      name: 'ENTERTAINMENT',
      icon: 'MOVIE',
      color: '#FFBA68C8',
      type: CategoryType.expense,
    ),
    Category(
      id: '5',
      name: 'TRIPS',
      icon: 'CARD_TRAVEL',
      color: '#FFFFF176',
      type: CategoryType.expense,
    ),
    Category(
      id: '6',
      name: 'TECHNOLOGY',
      icon: 'COMPUTER',
      color: '#FF4DD0E1',
      type: CategoryType.expense,
    ),
    Category(
      id: '7',
      name: 'EDUCATION',
      icon: 'SCHOOL',
      color: '#FFFF7043',
      type: CategoryType.expense,
    ),
    Category(
      id: '8',
      name: 'FASHION',
      icon: 'CHECKROOM',
      color: '#FFF48FB1',
      type: CategoryType.expense,
    ),
    Category(
      id: '9',
      name: 'TAXES',
      icon: 'PAYMENTS',
      color: '#FF8BC34A',
      type: CategoryType.expense,
    ),
    Category(
      id: '10',
      name: 'INSURANCE',
      icon: 'SECURITY',
      color: '#FF2196F3',
      type: CategoryType.expense,
    ),
    Category(
      id: '11',
      name: 'DWELLING',
      icon: 'HOUSE',
      color: '#FFA1887F',
      type: CategoryType.expense,
    ),
    Category(
      id: '12',
      name: 'GIFTS',
      icon: 'GIFT',
      color: '#FFFF6B9D',
      type: CategoryType.expense,
    ),
    Category(
      id: '13',
      name: 'OTHERS_EXPENSE',
      icon: 'CATEGORY',
      color: '#FFBDBDBD',
      type: CategoryType.expense,
    ),
    Category(
      id: '14',
      name: 'SALARY',
      icon: 'ATTACH_MONEY',
      color: '#FF5C6BC0',
      type: CategoryType.income,
    ),
    Category(
      id: '15',
      name: 'BUSINESS',
      icon: 'BUSINESS',
      color: '#FFFFA726',
      type: CategoryType.income,
    ),
    Category(
      id: '16',
      name: 'FREELANCE',
      icon: 'PERSON_SEARCH',
      color: '#FF66BB6A',
      type: CategoryType.income,
    ),
    Category(
      id: '17',
      name: 'RENTALS',
      icon: 'APARTMENT',
      color: '#FFAB47BC',
      type: CategoryType.income,
    ),
    Category(
      id: '18',
      name: 'INVESTMENTS',
      icon: 'TRENDING_UP',
      color: '#FFFDD835',
      type: CategoryType.income,
    ),
    Category(
      id: '19',
      name: 'INTERESTS',
      icon: 'PERCENT',
      color: '#FF26C6DA',
      type: CategoryType.income,
    ),
    Category(
      id: '20',
      name: 'PENSIONS',
      icon: 'CARD_MEMBERSHIP',
      color: '#FFFF8A65',
      type: CategoryType.income,
    ),
    Category(
      id: '21',
      name: 'DIVIDENDS',
      icon: 'MONETIZATION_ON',
      color: '#FFEC407A',
      type: CategoryType.income,
    ),
    Category(
      id: '22',
      name: 'AWARDS',
      icon: 'CARD_GIFTCARD',
      color: '#FF9CCC65',
      type: CategoryType.income,
    ),
    Category(
      id: '23',
      name: 'REFUNDS',
      icon: 'RECEIPT_LONG',
      color: '#FF42A5F5',
      type: CategoryType.income,
    ),
    Category(
      id: '24',
      name: 'SALES',
      icon: 'LOCAL_OFFER',
      color: '#FFBCAAA4',
      type: CategoryType.income,
    ),
    Category(
      id: '25',
      name: 'OTHERS_INCOME',
      icon: 'CATEGORY',
      color: '#FF90A4AE',
      type: CategoryType.income,
    ),
  ];

  static Category _cat(String id) => _categories.firstWhere((c) => c.id == id);

  static List<Movement> _buildInitialMovements() {
    final now = DateTime.now();
    DateTime currentMonthDate(int dayOffset) {
      final day = (now.day - dayOffset).clamp(1, 28);
      return DateTime(now.year, now.month, day, 12);
    }

    DateTime pastMonthDate(int monthsAgo, int day) =>
        DateTime(now.year, now.month - monthsAgo, day.clamp(1, 28), 12);

    return [
      Movement(
        id: '1',
        title: 'Grocery shopping',
        description: 'Weekly groceries and household items at Metro.',
        date: currentMonthDate(0),
        category: _cat('2'),
        price: 145.5,
        company: 'metro',
        attachments: const ['1/mock_receipt_metro.png'],
        user: '1',
      ),
      Movement(
        id: '2',
        title: 'Morning coffee',
        description: 'Large latte and croissant at Starbucks.',
        date: currentMonthDate(1),
        category: _cat('2'),
        price: 22,
        company: 'starbucks',
        user: '1',
      ),
      Movement(
        id: '3',
        title: 'Monthly salary',
        description: 'Monthly salary deposit.',
        date: currentMonthDate(2),
        category: _cat('14'),
        price: 3800,
        company: 'bcp',
        user: '1',
      ),
      Movement(
        id: '4',
        title: 'Uber ride',
        description: 'Trip to downtown.',
        date: currentMonthDate(2),
        category: _cat('1'),
        price: 18.5,
        company: 'uber',
        user: '1',
      ),
      Movement(
        id: '5',
        title: 'Netflix subscription',
        description: 'Monthly standard plan.',
        date: currentMonthDate(3),
        category: _cat('4'),
        price: 35.9,
        company: 'netflix',
        user: '1',
      ),
      Movement(
        id: '6',
        title: 'Lunch delivery',
        description: 'Quick order via PedidosYa.',
        date: currentMonthDate(4),
        category: _cat('2'),
        price: 34,
        company: 'pedidosya',
        user: '1',
      ),
      Movement(
        id: '7',
        title: 'Freelance project',
        description: 'Mobile app development for client.',
        date: currentMonthDate(5),
        category: _cat('16'),
        price: 950,
        company: 'yape',
        user: '1',
      ),
      Movement(
        id: '8',
        title: 'Spotify subscription',
        description: 'Monthly individual plan.',
        date: currentMonthDate(6),
        category: _cat('4'),
        price: 20.9,
        company: 'spotify',
        user: '1',
      ),
      Movement(
        id: '9',
        title: 'Pharmacy',
        description: 'Vitamins and pain relievers at Inkafarma.',
        date: currentMonthDate(7),
        category: _cat('3'),
        price: 48,
        company: 'inkafarma',
        user: '1',
      ),
      Movement(
        id: '10',
        title: 'Movie tickets',
        description: 'Weekend movie screening at Cinemark.',
        date: currentMonthDate(8),
        category: _cat('4'),
        price: 54,
        company: 'cinemark',
        user: '1',
      ),
      Movement(
        id: '11',
        title: 'Water utility bill',
        description: 'Monthly Sedalib payment.',
        date: currentMonthDate(9),
        category: _cat('11'),
        price: 68.4,
        company: 'sedalib',
        user: '1',
      ),
      Movement(
        id: '12',
        title: 'Quarterly dividends',
        description: 'Tech portfolio yield.',
        date: currentMonthDate(10),
        category: _cat('21'),
        price: 240,
        company: 'google',
        user: '1',
      ),
      // Month - 1
      Movement(
        id: '13',
        title: 'Previous month salary',
        description: 'Monthly account deposit.',
        date: pastMonthDate(1, 2),
        category: _cat('14'),
        price: 3800,
        company: 'bcp',
        user: '1',
      ),
      Movement(
        id: '14',
        title: 'Tottus supermarket',
        description: 'Monthly pantry restock.',
        date: pastMonthDate(1, 10),
        category: _cat('2'),
        price: 310,
        company: 'tottus',
        user: '1',
      ),
      Movement(
        id: '15',
        title: 'Fiber internet',
        description: 'Monthly MiFibra bill.',
        date: pastMonthDate(1, 15),
        category: _cat('6'),
        price: 99,
        company: 'mifibra',
        user: '1',
      ),
      Movement(
        id: '16',
        title: 'Coffee and snacks',
        description: 'Quick stop at Starbucks.',
        date: pastMonthDate(1, 20),
        category: _cat('2'),
        price: 29.5,
        company: 'starbucks',
        user: '1',
      ),
      // Month - 2
      Movement(
        id: '17',
        title: 'Salary 2 months ago',
        description: 'Monthly deposit.',
        date: pastMonthDate(2, 2),
        category: _cat('14'),
        price: 3650,
        company: 'bcp',
        user: '1',
      ),
      Movement(
        id: '18',
        title: 'Amazon purchase',
        description: 'Desk accessories.',
        date: pastMonthDate(2, 14),
        category: _cat('6'),
        price: 215,
        company: 'amazon',
        user: '1',
      ),
      Movement(
        id: '19',
        title: 'Fuel',
        description: 'Full tank at Primax.',
        date: pastMonthDate(2, 22),
        category: _cat('1'),
        price: 160,
        company: 'primax',
        user: '1',
      ),
      // Month - 3
      Movement(
        id: '20',
        title: 'Freelance consulting',
        description: 'Technical advisory.',
        date: pastMonthDate(3, 8),
        category: _cat('16'),
        price: 750,
        company: 'yape',
        user: '1',
      ),
      Movement(
        id: '21',
        title: 'Car insurance',
        description: 'Monthly insurance installment.',
        date: pastMonthDate(3, 18),
        category: _cat('10'),
        price: 185,
        company: 'bcp',
        user: '1',
      ),
      // Previous year
      Movement(
        id: '22',
        title: 'Annual bonus',
        description: 'Year-end bonus.',
        date: DateTime(now.year - 1, 12, 15, 12),
        category: _cat('14'),
        price: 4200,
        company: 'bcp',
        user: '1',
      ),
      Movement(
        id: '23',
        title: 'Vacation trip',
        description: 'Flights and lodging.',
        date: DateTime(now.year - 1, 12, 20, 12),
        category: _cat('5'),
        price: 1250,
        company: 'falabella',
        user: '1',
      ),
    ];
  }

  final List<Movement> _movements;
  final StreamController<void> _changesController =
      StreamController<void>.broadcast();
  int _idCounter = 100;

  List<Movement> _filterMovements({
    required String userId,
    DateTime? startDate,
    DateTime? endDate,
    CategoryType? type,
    String? categoryId,
    int? limit,
    bool orderByDate = false,
  }) {
    var results = _movements.where((m) => m.user == userId);

    if (type != null) {
      results = results.where((m) => m.category.type == type);
    }
    if (categoryId != null) {
      results = results.where((m) => m.category.id == categoryId);
    }
    if (startDate != null) {
      results = results.where((m) => !m.date.isBefore(startDate));
    }
    if (endDate != null) {
      results = results.where((m) => m.date.isBefore(endDate));
    }

    final list = results.toList();
    if (orderByDate) {
      list.sort((a, b) => b.date.compareTo(a.date));
    }
    if (limit != null && list.length > limit) {
      return list.sublist(0, limit);
    }
    return list;
  }

  @override
  String get newId => 'mock_mov_${++_idCounter}';

  @override
  Future<void> saveMovement({required Movement movement}) async {
    final index = _movements.indexWhere((m) => m.id == movement.id);
    if (index >= 0) {
      _movements[index] = movement;
    } else {
      _movements.add(movement);
    }
    if (!_changesController.isClosed) {
      _changesController.add(null);
    }
  }

  @override
  Stream<List<Category>> getCategoriesStream() async* {
    yield List<Category>.of(_categories);
    await for (final _ in _changesController.stream) {
      yield List<Category>.of(_categories);
    }
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
  }) async* {
    List<Movement> query() => _filterMovements(
      userId: userId,
      startDate: startDate,
      endDate: endDate,
      type: type,
      categoryId: categoryId,
      limit: limit,
      orderByDate: orderByDate,
    );
    yield query();
    await for (final _ in _changesController.stream) {
      yield query();
    }
  }

  @override
  Future<List<Movement>> getMovements({
    required String userId,
    DateTime? from,
    DateTime? to,
  }) async {
    return _filterMovements(userId: userId, startDate: from, endDate: to);
  }

  @override
  Future<void> deleteMovement({required String movementId}) async {
    _movements.removeWhere((movement) => movement.id == movementId);
    if (!_changesController.isClosed) {
      _changesController.add(null);
    }
  }
}

class FirestoreDatabaseRepository implements DatabaseRepository {
  new({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  @override
  String get newId =>
      _firestore.collection(AppVariables.movementsCollection).doc().id;

  @override
  Future<void> saveMovement({required Movement movement}) {
    return _firestore
        .collection(AppVariables.movementsCollection)
        .doc(movement.id)
        .set(movement.toJson());
  }

  @override
  Stream<List<Category>> getCategoriesStream() {
    return _firestore
        .collection(AppVariables.categoriesCollection)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => Category.fromJson(doc.data()))
              .toList();
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

    QuerySnapshot<Map<String, dynamic>> snapshot;
    try {
      snapshot = await query.get().timeout(AppVariables.timeoutDuration);
    } on TimeoutException {
      snapshot = await query.get(const GetOptions(source: Source.cache));
    }
    return snapshot.docs.map((doc) => Movement.fromJson(doc.data())).toList();
  }

  @override
  Future<void> deleteMovement({required String movementId}) {
    return _firestore
        .collection(AppVariables.movementsCollection)
        .doc(movementId)
        .delete();
  }
}
