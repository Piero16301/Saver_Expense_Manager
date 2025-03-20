import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_pagination/firebase_pagination.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:saver_expense_manager/app/app.dart';
import 'package:saver_expense_manager/home/movements_home/movements_home.dart';
import 'package:saver_expense_manager/l10n/l10n.dart';
import 'package:user_api/user_api.dart';

class MovementsHomeView extends StatelessWidget {
  const MovementsHomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MovementsHomeCubit, MovementsHomeState>(
      builder: (context, state) => const Padding(
        padding: EdgeInsets.only(bottom: 20),
        child: Column(
          spacing: 20,
          children: [
            FilterMovementsHome(),
            ListMovementsHome(),
          ],
        ),
      ),
    );
  }
}

class FilterMovementsHome extends StatelessWidget {
  const FilterMovementsHome({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final categories = context
        .select<AppCubit, List<Category>>((cubit) => cubit.state.categories)
      ..sort(
        (a, b) => getCategoryName(a.name, l10n)
            .compareTo(getCategoryName(b.name, l10n)),
      );

    return BlocBuilder<MovementsHomeCubit, MovementsHomeState>(
      builder: (context, state) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: AppDropdownField<CategoryType>(
                  label: l10n.movementType,
                  options: [CategoryType.expense, CategoryType.income]
                      .map(
                        (type) => DropdownMenuEntry<CategoryType>(
                          value: type,
                          label: getTypeName(type, l10n),
                          leadingIcon: Icon(getTypeIcon(type)),
                        ),
                      )
                      .toList(),
                  selected: state.filterType,
                  leadingIcon: state.filterType != null
                      ? getTypeIcon(state.filterType!)
                      : null,
                  onSelected: (type) {
                    context.read<MovementsHomeCubit>().changeFilterType(type);
                  },
                ),
              ),
              if (state.filterType != null) const SizedBox(width: 10),
              if (state.filterType != null)
                IconButton(
                  onPressed: () {
                    context.read<MovementsHomeCubit>().clearFilterType();
                  },
                  icon: const Icon(Icons.clear),
                ),
            ],
          ),
          if (state.filterType != null) const SizedBox(height: 20),
          if (state.filterType != null)
            Row(
              children: [
                Expanded(
                  child: AppDropdownField<Category>(
                    label: l10n.movementCategory,
                    options: categories
                        .where((c) => c.type == state.filterType)
                        .map(
                          (category) => DropdownMenuEntry<Category>(
                            value: category,
                            label: getCategoryName(category.name, l10n),
                            leadingIcon: Icon(getCategoryIcon(category.icon)),
                          ),
                        )
                        .toList(),
                    selected: state.filterCategory,
                    leadingIcon: state.filterCategory != null
                        ? getCategoryIcon(state.filterCategory!.icon)
                        : null,
                    onSelected: (category) {
                      context
                          .read<MovementsHomeCubit>()
                          .changeFilterCategory(category);
                    },
                  ),
                ),
                if (state.filterCategory != null) const SizedBox(width: 10),
                if (state.filterCategory != null)
                  IconButton(
                    onPressed: () {
                      context.read<MovementsHomeCubit>().clearFilterCategory();
                    },
                    icon: const Icon(Icons.clear),
                  ),
              ],
            ),
        ],
      ),
    );
  }
}

class ListMovementsHome extends StatelessWidget {
  const ListMovementsHome({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MovementsHomeCubit, MovementsHomeState>(
      builder: (context, state) => Expanded(
        child: FirestorePagination(
          physics: const BouncingScrollPhysics(),
          query: getUserMovements(
            userId: FirebaseAuth.instance.currentUser!.uid,
            type: state.filterType,
            category: state.filterCategory,
          ),
          isLive: true,
          itemBuilder: (context, docs, index) {
            final movement = Movement.fromJson(
              docs[index].data()! as Map<String, dynamic>,
            );
            return ListMovementsItemHome(movement: movement);
          },
        ),
      ),
    );
  }
}

class ListMovementsItemHome extends StatelessWidget {
  const ListMovementsItemHome({
    required this.movement,
    super.key,
  });

  final Movement movement;

  @override
  Widget build(BuildContext context) {
    final locale =
        context.select<AppCubit, Locale>((cubit) => cubit.state.locale!);

    return ListTile(
      onTap: () => context.pushNamed<bool>(
        'movement',
        pathParameters: {
          'type': movement.category.type == CategoryType.income
              ? incomeType
              : expenseType,
          'screenType': 'EDIT',
        },
        extra: movement,
      ),
      contentPadding: const EdgeInsets.only(left: 16, right: 16),
      title: Text(
        movement.title,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 18,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text(
        DateFormat.yMMMMd(locale.languageCode).format(movement.date),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: Container(
        width: 80,
        decoration: BoxDecoration(
          color: (movement.category.type == CategoryType.expense
                  ? Colors.red
                  : Colors.green)
              .withValues(
            alpha: 0.3,
          ),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 5),
          child: Text(
            moneyFormat.format(movement.price),
            style: const TextStyle(fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
        ),
      ),
      leading: Icon(
        getCategoryIcon(movement.category.icon),
        size: 30,
        color: HexColor.fromHex(movement.category.color),
      ),
    );
  }
}
