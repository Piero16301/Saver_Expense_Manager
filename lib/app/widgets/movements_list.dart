import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:saver_expense_manager/app/app.dart';

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
    final language = context.select<AppCubit, Locale>(
      (cubit) => cubit.state.language,
    );
    final auth = getIt<AuthService>();
    final database = getIt<DatabaseService>();

    return Expanded(
      child: AppStreamPaginated<Movement>(
        key: ValueKey('$filterCategory-$monthSelected'),
        stream: (limit) => database.getMovementsStream(
          userId: auth.currentUser!.uid,
          startDate: DateTime(monthSelected.year, monthSelected.month),
          endDate: DateTime(monthSelected.year, monthSelected.month + 1),
          categoryId: filterCategory.id,
          limit: limit,
          orderByDate: true,
        ),
        itemBuilder: (context, docs, index) {
          final movement = docs[index];

          return ListTile(
            onTap: () => context.pushNamed(
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
              style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            subtitle: Text(
              movement.description,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodySmall,
            ),
            trailing: Container(
              width: 90,
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
                  style: Theme.of(context).textTheme.bodySmall!.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            leading: SizedBox(
              width: 40,
              child: Text(
                AppExtensions.largeDateFormat(language.toString())
                    .format(movement.date)
                    .replaceFirst(' ', '\n')
                    .toUpperCase(),
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
          );
        },
      ),
    );
  }
}
