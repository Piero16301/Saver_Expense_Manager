import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_pagination/firebase_pagination.dart';
import 'package:flutter/material.dart';
import 'package:saver_expense_manager/app/app.dart';
import 'package:saver_expense_manager/l10n/l10n.dart';
import 'package:user_api/user_api.dart';

class MovementsListChart extends StatelessWidget {
  const MovementsListChart({
    required this.filterCategory,
    required this.monthSelected,
    super.key,
  });

  final Category filterCategory;
  final DateTime monthSelected;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Expanded(
      child: FirestorePagination(
        key: ValueKey('$filterCategory-$monthSelected'),
        shrinkWrap: true,
        physics: const BouncingScrollPhysics(),
        query: getCategoryMovements(
          userId: FirebaseAuth.instance.currentUser!.uid,
          monthSelected: monthSelected,
          category: filterCategory,
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
