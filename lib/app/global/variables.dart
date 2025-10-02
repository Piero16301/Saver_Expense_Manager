class AppVariables {
  static final minDate = DateTime(2020);

  static const deafultMonthsTrend = 5;
  static const maxDaysWarning = 7;

  static const categoriesCollection = 'categories';
  static const movementsCollection = 'movements';
  static const usersCollection = 'users';
}

enum ExpenseType {
  expense('EXPENSE'),
  income('INCOME');

  const ExpenseType(this.value);

  final String value;
}

enum MovementScreenType { add, edit }
