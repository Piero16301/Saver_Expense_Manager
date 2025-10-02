import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_pagination/firebase_pagination.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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
          children: [FilterMovementsHome(), ListMovementsHome()],
        ),
      ),
    );
  }
}

class FilterMovementsHome extends StatelessWidget {
  const FilterMovementsHome({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final categories =
        context.select<AppCubit, List<Category>>(
          (cubit) => cubit.state.categories,
        )..sort(
          (a, b) => getCategoryName(
            a.name,
            l10n,
          ).compareTo(getCategoryName(b.name, l10n)),
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
                      context.read<MovementsHomeCubit>().changeFilterCategory(
                        category,
                      );
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
    final l10n = AppLocalizations.of(context);

    return BlocBuilder<MovementsHomeCubit, MovementsHomeState>(
      buildWhen: (previous, current) =>
          previous.filterType != current.filterType ||
          previous.filterCategory != current.filterCategory,
      builder: (context, state) => Expanded(
        child: FirestorePagination(
          key: ValueKey('${state.filterType}-${state.filterCategory}'),
          shrinkWrap: true,
          physics: const BouncingScrollPhysics(),
          query: getUserMovements(
            userId: FirebaseAuth.instance.currentUser!.uid,
            type: state.filterType,
            category: state.filterCategory,
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
      ),
    );
  }
}
