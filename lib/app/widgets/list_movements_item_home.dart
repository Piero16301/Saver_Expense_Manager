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
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text(
        DateFormat.yMMMMd(language.split('_').first).format(movement.date),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: Container(
        width: 80,
        decoration: BoxDecoration(
          color: (movement.category.type == CategoryType.expense
                  ? Colors.red
                  : Colors.green)
              .withValues(alpha: 0.3),
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
      leading: HugeIcon(
        icon: AppFunctions.getCategoryIcon(movement.category.icon),
        size: 30,
        color: HexColor.fromHex(movement.category.color),
      ),
    );
  }
}
