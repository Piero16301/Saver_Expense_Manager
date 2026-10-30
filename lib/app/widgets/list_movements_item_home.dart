import 'package:expressive_kit/expressive_kit.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:material_ui/material_ui.dart';
import 'package:saver_expense_manager/app/app.dart';

class ListMovementsItemHome extends StatelessWidget {
  const ListMovementsItemHome({
    required this.movement,
    this.showDate = true,
    super.key,
  });

  final Movement movement;
  final bool showDate;

  @override
  Widget build(BuildContext context) {
    final language = context.select<AppCubit, Locale>(
      (cubit) => cubit.state.language,
    );
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: ExpressiveCard(
        margin: EdgeInsets.zero,
        padding: EdgeInsets.zero,
        borderRadius: BorderRadius.circular(18),
        backgroundColor: theme.colorScheme.surfaceContainerLow,
        child: ExpressiveListTile(
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
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 10,
          ),
          title: Text(
            movement.title,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontVariations: <FontVariation>[
                ...(theme.textTheme.bodyMedium?.fontVariations ??
                        const <FontVariation>[])
                    .where((v) => v.axis != 'wght'),
                const FontVariation('wght', 600),
              ],
            ),
            maxLines: showDate ? 1 : 2,
            overflow: TextOverflow.ellipsis,
          ),
          subtitle: showDate
              ? Padding(
                  padding: const EdgeInsets.only(top: 2),
                  child: Text(
                    DateFormat.yMMMMd(
                      language.toString(),
                    ).format(movement.date),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                )
              : null,
          trailing: Container(
            constraints: const BoxConstraints(minWidth: 84),
            decoration: BoxDecoration(
              color:
                  (movement.category.type == CategoryType.expense
                          ? Colors.red
                          : Colors.green)
                      .withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
              child: Text(
                AppExtensions.moneyFormat.format(movement.price),
                style: theme.textTheme.labelLarge!.copyWith(
                  fontVariations: <FontVariation>[
                    ...(theme.textTheme.labelLarge?.fontVariations ??
                            const <FontVariation>[])
                        .where((v) => v.axis != 'wght'),
                    const FontVariation('wght', 700),
                  ],
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
          leading: MovementIcon(movement: movement),
        ),
      ),
    );
  }
}
