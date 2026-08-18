import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:intl/intl.dart';
import 'package:material_ui/material_ui.dart';
import 'package:saver_expense_manager/app/app.dart';

class ListMovementsItemHome extends StatelessWidget {
  const ListMovementsItemHome({required this.movement, super.key});

  final Movement movement;

  @override
  Widget build(BuildContext context) {
    final language = context.select<AppCubit, Locale>(
      (cubit) => cubit.state.language,
    );

    return ListTile(
      onTap: () => context.pushNamed<bool>(
        AppRoute.movement.name,
        pathParameters: {
          'type': movement.category.type == CategoryType.income
              ? CategoryType.income.value
              : CategoryType.expense.value,
          'screenType': MovementScreenType.edit.name.toUpperCase(),
        },
        extra: movement,
      ),
      contentPadding: const EdgeInsets.only(left: 8, right: 8),
      title: Text(
        movement.title,
        style:
            Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(
              fontVariations: <FontVariation>[
                ...(Theme.of(context).textTheme.bodyMedium?.fontVariations ??
                        const <FontVariation>[])
                    .where((v) => v.axis != 'wght'),
                const FontVariation('wght', 700),
              ],
            ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text(
        DateFormat.yMMMMd(language.toString()).format(movement.date),
        style: Theme.of(context).textTheme.bodySmall,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: Container(
        width: 90,
        decoration: BoxDecoration(
          color:
              (movement.category.type == CategoryType.expense
                      ? Colors.red
                      : Colors.green)
                  .withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
          child: Text(
            AppExtensions.moneyFormat.format(movement.price),
            style:
                Theme.of(
                  context,
                ).textTheme.labelLarge!.copyWith(
                  fontVariations: <FontVariation>[
                    ...(Theme.of(
                              context,
                            ).textTheme.labelLarge?.fontVariations ??
                            const <FontVariation>[])
                        .where((v) => v.axis != 'wght'),
                    const FontVariation('wght', 700),
                  ],
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
