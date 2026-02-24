import 'package:firebase_pagination/firebase_pagination.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:saver_expense_manager/app/app.dart';
import 'package:saver_expense_manager/l10n/l10n.dart';
import 'package:saver_expense_manager/movement/movement.dart';

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
    final language = context.select<AppCubit, Locale>(
      (cubit) => cubit.state.language,
    );
    final auth = getIt<AuthenticationService>();
    final database = getIt<DatabaseService>();

    return Expanded(
      child: FirestorePagination(
        key: ValueKey('$filterCategory-$monthSelected'),
        shrinkWrap: true,
        physics: const BouncingScrollPhysics(),
        query: database.getCategoryMovementsQuery(
          userId: auth.currentUser!.uid,
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
              MovementPage.pageName,
              pathParameters: {
                'type': movement.category.type == CategoryType.income
                    ? CategoryType.income.value
                    : CategoryType.expense.value,
                'screenType': 'EDIT',
              },
              extra: movement,
            ),
            contentPadding: const EdgeInsets.only(left: 8, right: 8),
            title: Text(
              movement.title,
              style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            subtitle: Text(
              movement.description,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
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
            leading: Text(
              AppExtensions.largeDateFormat(language.toString())
                  .format(movement.date)
                  .replaceFirst(' ', '\n')
                  .toUpperCase(),
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
          );
        },
      ),
    );
  }
}
