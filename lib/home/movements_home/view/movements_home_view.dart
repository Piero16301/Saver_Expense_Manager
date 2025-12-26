import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_pagination/firebase_pagination.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:saver_expense_manager/app/app.dart';
import 'package:saver_expense_manager/home/movements_home/movements_home.dart';
import 'package:saver_expense_manager/l10n/l10n.dart';
import 'package:user_api/user_api.dart';

class MovementsHomeView extends StatelessWidget {
  const MovementsHomeView({
    required this.categories,
    super.key,
  });

  final List<Category> categories;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MovementsHomeCubit, MovementsHomeState>(
      builder: (context, state) => Column(
        spacing: 8,
        children: [
          FilterMovementsHome(categories: categories),
          const ListMovementsHome(),
        ],
      ),
    );
  }
}

class FilterMovementsHome extends StatelessWidget {
  const FilterMovementsHome({
    required this.categories,
    super.key,
  });

  final List<Category> categories;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    categories.sort(
      (a, b) => AppFunctions.getCategoryName(
        a.name,
        l10n,
      ).compareTo(AppFunctions.getCategoryName(b.name, l10n)),
    );

    return BlocBuilder<MovementsHomeCubit, MovementsHomeState>(
      builder: (context, state) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            InkWell(
              onTap: () => _showFilterTypeMenu(context, state),
              borderRadius: BorderRadius.circular(8),
              child: Chip(
                padding: const EdgeInsets.all(4),
                backgroundColor: state.filterType != null
                    ? Theme.of(context).colorScheme.secondaryContainer
                    : null,
                side: state.filterType == null
                    ? null
                    : BorderSide(
                        color: Theme.of(context).colorScheme.secondaryContainer,
                      ),
                label: Row(
                  spacing: 4,
                  children: [
                    if (state.filterType != null)
                      HugeIcon(
                        icon: state.filterType == CategoryType.income
                            ? HugeIcons.strokeRoundedMoneyAdd01
                            : HugeIcons.strokeRoundedMoneyRemove01,
                      ),
                    if (state.filterType != null)
                      Text(
                        state.filterType == CategoryType.income
                            ? l10n.incomeName
                            : l10n.expenseName,
                      ),
                    if (state.filterType == null) Text(l10n.movementType),
                    if (state.filterType == null)
                      const HugeIcon(icon: HugeIcons.strokeRoundedArrowDown01),
                  ],
                ),
              ),
            ),
            if (state.filterType != null) const SizedBox(width: 8),
            if (state.filterType != null)
              InkWell(
                onTap: () => _showFilterCategoryMenu(context, state),
                borderRadius: BorderRadius.circular(8),
                child: Chip(
                  padding: const EdgeInsets.all(4),
                  backgroundColor: state.filterCategory != null
                      ? Theme.of(context).colorScheme.secondaryContainer
                      : null,
                  side: state.filterCategory == null
                      ? null
                      : BorderSide(
                          color:
                              Theme.of(context).colorScheme.secondaryContainer,
                        ),
                  label: Row(
                    spacing: 4,
                    children: [
                      if (state.filterCategory != null)
                        HugeIcon(
                          icon: AppFunctions.getCategoryIcon(
                            state.filterCategory!.icon,
                          ),
                        ),
                      if (state.filterCategory != null)
                        Text(
                          AppFunctions.getCategoryName(
                            state.filterCategory!.name,
                            l10n,
                          ),
                        ),
                      if (state.filterCategory == null) Text(l10n.movementType),
                      if (state.filterCategory == null)
                        const HugeIcon(
                          icon: HugeIcons.strokeRoundedArrowDown01,
                        ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _showFilterTypeMenu(BuildContext context, MovementsHomeState state) {
    final l10n = AppLocalizations.of(context);
    final cubit = context.read<MovementsHomeCubit>();

    unawaited(
      showModalBottomSheet<void>(
        context: context,
        isScrollControlled: true,
        builder: (context) => DraggableScrollableSheet(
          initialChildSize: 0.4,
          minChildSize: 0.3,
          maxChildSize: 0.9,
          expand: false,
          builder: (context, scrollController) => Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).scaffoldBackgroundColor,
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: Column(
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Theme.of(context).buttonTheme.colorScheme!.primary,
                      borderRadius: const BorderRadius.all(Radius.circular(2)),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  l10n.movementTypeTitle,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: SingleChildScrollView(
                    controller: scrollController,
                    child: RadioGroup<CategoryType?>(
                      groupValue: state.filterType,
                      onChanged: (value) {
                        if (value == null) {
                          cubit.clearFilterType();
                        } else {
                          cubit.changeFilterType(value);
                        }
                        Navigator.pop(context);
                      },
                      child: Column(
                        children: [
                          RadioListTile<CategoryType?>(
                            title: Text(l10n.movementTypeAll),
                            value: null,
                            contentPadding: EdgeInsets.zero,
                          ),
                          RadioListTile<CategoryType?>(
                            title: Text(l10n.expenseName),
                            value: CategoryType.expense,
                            contentPadding: EdgeInsets.zero,
                          ),
                          RadioListTile<CategoryType?>(
                            title: Text(l10n.incomeName),
                            value: CategoryType.income,
                            contentPadding: EdgeInsets.zero,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showFilterCategoryMenu(
    BuildContext context,
    MovementsHomeState state,
  ) {
    final l10n = AppLocalizations.of(context);
    final cubit = context.read<MovementsHomeCubit>();

    unawaited(
      showModalBottomSheet<void>(
        context: context,
        isScrollControlled: true,
        builder: (context) => DraggableScrollableSheet(
          initialChildSize: 0.6,
          minChildSize: 0.3,
          maxChildSize: 0.9,
          expand: false,
          builder: (context, scrollController) => Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).scaffoldBackgroundColor,
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: Column(
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Theme.of(context).buttonTheme.colorScheme!.primary,
                      borderRadius: const BorderRadius.all(Radius.circular(2)),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  l10n.movementCategoryTitle,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: SingleChildScrollView(
                    controller: scrollController,
                    child: RadioGroup<Category?>(
                      groupValue: state.filterCategory,
                      onChanged: (value) {
                        if (value == null) {
                          cubit.clearFilterCategory();
                        } else {
                          cubit.changeFilterCategory(value);
                        }
                        Navigator.pop(context);
                      },
                      child: Column(
                        children: [
                          RadioListTile<Category?>(
                            title: Text(l10n.movementCategoryAll),
                            value: null,
                            contentPadding: EdgeInsets.zero,
                          ),
                          ...categories
                              .where(
                                (category) => category.type == state.filterType,
                              )
                              .map(
                                (category) => RadioListTile<Category?>(
                                  title: Text(
                                    AppFunctions.getCategoryName(
                                      category.name,
                                      l10n,
                                    ),
                                  ),
                                  value: category,
                                  contentPadding: EdgeInsets.zero,
                                ),
                              ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
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
          query: AppFunctions.getUserMovements(
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
