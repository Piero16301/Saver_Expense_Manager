import 'package:firebase_pagination/firebase_pagination.dart';
import 'package:flutter/material.dart';
import 'package:saver_expense_manager/app/app.dart';
import 'package:saver_expense_manager/l10n/l10n.dart';

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
    final l10n = AppLocalizations.of(context);
    final auth = getIt<AuthenticationService>();
    final databaseService = getIt<DatabaseService>();

    return Expanded(
      child: FirestorePagination(
        key: ValueKey('$expenseType-$monthSelected'),
        shrinkWrap: true,
        physics: const BouncingScrollPhysics(),
        query: databaseService.getExpenseTypeMovementsQuery(
          userId: auth.currentUser!.uid,
          monthSelected: monthSelected,
          expenseType: expenseType,
        ),
        isLive: true,
        onEmpty: Center(
          child: Text(
            l10n.movementsNoData,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
        itemBuilder: (context, docs, index) {
          final movement = Movement.fromJson(
            docs[index].data()! as Map<String, dynamic>,
          );
          return ListMovementsItemHome(movement: movement);
        },
      ),
    );
  }
}
