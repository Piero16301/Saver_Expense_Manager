import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:intl/intl.dart';
import 'package:saver_expense_manager/app/app.dart';
import 'package:saver_expense_manager/home/movement/movement.dart';
import 'package:user_api/user_api.dart';

class ListMovementsItemHome extends StatelessWidget {
  const ListMovementsItemHome({required this.movement, super.key});

  final Movement movement;

  @override
  Widget build(BuildContext context) {
    final language = context.select<AppCubit, String>(
      (cubit) => cubit.state.language,
    );

    return ListTile(
      onTap: () => context.pushNamed<bool>(
        MovementPage.pageName,
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
        style: Theme.of(context).textTheme.bodyMedium!.copyWith(
              fontWeight: FontWeight.w600,
            ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text(
        DateFormat.yMMMMd(language).format(movement.date),
        style: Theme.of(context).textTheme.bodySmall,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: Container(
        width: 90,
        decoration: BoxDecoration(
          color: (movement.category.type == CategoryType.expense
                  ? Colors.red
                  : Colors.green)
              .withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
          child: Text(
            AppExtensions.moneyFormat.format(movement.price),
            style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                  fontWeight: FontWeight.w600,
                ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
      leading: HugeIcon(
        icon: AppFunctions.getCategoryIcon(movement.category.icon),
        size: 32,
        color: HexColor.fromHex(movement.category.color),
        strokeWidth: 2,
      ),
    );
  }
}
