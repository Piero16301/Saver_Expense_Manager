import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
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
    final language = context.select<AppCubit, Locale>(
      (cubit) => cubit.state.language,
    );
    final theme = Theme.of(context);

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
          final previousMovement = index > 0 ? docs[index - 1] : null;
          final isNewDay =
              previousMovement == null ||
              movement.date.year != previousMovement.date.year ||
              movement.date.month != previousMovement.date.month ||
              movement.date.day != previousMovement.date.day;

          if (!isNewDay) {
            return ListMovementsItemHome(movement: movement, showDate: false);
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: EdgeInsets.only(
                  top: index == 0 ? 4 : 14,
                  bottom: 4,
                  left: 4,
                  right: 4,
                ),
                child: Text(
                  DateFormat.MMMMd(language.toString()).format(movement.date),
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                    fontVariations: <FontVariation>[
                      ...(theme.textTheme.labelLarge?.fontVariations ??
                              const <FontVariation>[])
                          .where((v) => v.axis != 'wght'),
                      const FontVariation('wght', 600),
                    ],
                  ),
                ),
              ),
              ListMovementsItemHome(movement: movement, showDate: false),
            ],
          );
        },
      ),
    );
  }
}
