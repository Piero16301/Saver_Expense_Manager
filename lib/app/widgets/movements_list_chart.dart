import 'package:material_ui/material_ui.dart';
import 'package:saver_expense_manager/app/app.dart';

class MovementsListChart extends StatelessWidget {
  const MovementsListChart({
    required this.expenseType,
    required this.monthSelected,
    super.key,
  });

  final CategoryType expenseType;
  final DateTime monthSelected;

  @override
  Widget build(BuildContext context) {
    final auth = getIt<AuthService>();
    final database = getIt<DatabaseService>();

    return Expanded(
      child: AppStreamPaginated<Movement>(
        key: ValueKey('$expenseType-$monthSelected'),
        stream: (limit) => database.getMovementsStream(
          userId: auth.currentUser!.uid,
          startDate: DateTime(monthSelected.year, monthSelected.month),
          endDate: DateTime(monthSelected.year, monthSelected.month + 1),
          type: expenseType,
          limit: limit,
          orderByDate: true,
        ),
        itemBuilder: (context, docs, index) {
          final movement = docs[index];

          return ListMovementsItemHome(movement: movement);
        },
      ),
    );
  }
}
