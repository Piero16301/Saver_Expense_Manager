final minDate = DateTime(2020);

const deafultMonthsTrend = 5;

const categoriesCollection = 'categories';
const movementsCollection = 'movements';
const usersCollection = 'users';

enum ExpenseType {
  expense('EXPENSE'),
  income('INCOME');

  const ExpenseType(this.value);

  final String value;
}

enum MovementScreenType { add, edit }
