import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_pagination/firebase_pagination.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:saver_expense_manager/app/app.dart';
import 'package:saver_expense_manager/l10n/l10n.dart';
import 'package:user_api/user_api.dart';

class MovementsList extends StatelessWidget {
  const MovementsList({
    required this.filterCategory,
    required this.monthSelected,
    super.key,
  });

  final Category filterCategory;
  final DateTime monthSelected;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final language = context.select<AppCubit, String>(
      (cubit) => cubit.state.language,
    );

    return Expanded(
      child: FirestorePagination(
        key: ValueKey('$filterCategory-$monthSelected'),
        shrinkWrap: true,
        physics: const BouncingScrollPhysics(),
        query: AppFunctions.getCategoryMovements(
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
          return ListTile(
            onTap: () => context.pushNamed(
              'movement',
              pathParameters: {
                'type': movement.category.type == CategoryType.income
                    ? CategoryType.income.value
                    : CategoryType.expense.value,
                'screenType': 'EDIT',
              },
              extra: movement,
            ),
            contentPadding: const EdgeInsets.only(left: 16, right: 16),
            title: Text(
              movement.title,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            subtitle: Text(
              movement.description,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            trailing: Container(
              width: 80,
              decoration: BoxDecoration(
                color: HexColor.fromHex(
                  movement.category.color,
                ).withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 5),
                child: Text(
                  AppExtensions.moneyFormat.format(movement.price),
                  style: const TextStyle(fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            leading: Text(
              AppExtensions.largeDateFormat(
                language.split('_').first,
              ).format(movement.date).replaceFirst(' ', '\n').toUpperCase(),
              textAlign: TextAlign.center,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          );
        },
      ),
    );
  }
}
