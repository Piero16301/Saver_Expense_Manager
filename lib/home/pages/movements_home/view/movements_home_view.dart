import 'dart:async';

import 'package:firebase_pagination/firebase_pagination.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:saver_expense_manager/app/app.dart';
import 'package:saver_expense_manager/home/home.dart';
import 'package:saver_expense_manager/l10n/l10n.dart';

class MovementsHomeView extends StatelessWidget {
  const MovementsHomeView({
    required this.categories,
    super.key,
  });

  final List<Category> categories;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final authentication = getIt<AuthenticationService>();
    final database = getIt<DatabaseService>();

    return BlocConsumer<MovementsHomeCubit, MovementsHomeState>(
      listener: (context, state) {
        if (state.recommendationsStatus.isFailure) {
          AppFunctions.showSnackBar(
            context,
            message: l10n.antRecommendationsError,
            type: SnackBarType.error,
          );
          context.read<MovementsHomeCubit>().resetRecommendationsStatus();
        }
      },
      builder: (context, state) => Column(
        spacing: 8,
        children: [
          StreamBuilder<List<Movement>>(
            stream: database.getMovementsStream(
              userId: authentication.auth.currentUser!.uid,
              limit: 1,
            ),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const SizedBox.shrink();
              }

              if (snapshot.hasError) {
                return const SizedBox.shrink();
              }

              if (snapshot.data!.isEmpty) {
                return const SizedBox.shrink();
              }

              return FilterMovementsAntResumeHome(
                categories: categories,
                filterType: state.filterType,
                filterCategory: state.filterCategory,
                onFilterTypeChanged:
                    context.read<MovementsHomeCubit>().updateFilterType,
                onFilterCategoryChanged:
                    context.read<MovementsHomeCubit>().updateFilterCategory,
              );
            },
          ),
          ListMovementsHome(
            filterType: state.filterType,
            filterCategory: state.filterCategory,
          ),
        ],
      ),
    );
  }
}

class FilterMovementsAntResumeHome extends StatelessWidget {
  const FilterMovementsAntResumeHome({
    required this.categories,
    required this.onFilterTypeChanged,
    required this.onFilterCategoryChanged,
    this.filterType,
    this.filterCategory,
    super.key,
  });

  final List<Category> categories;
  final CategoryType? filterType;
  final Category? filterCategory;
  final void Function(CategoryType?) onFilterTypeChanged;
  final void Function(Category?) onFilterCategoryChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    categories.sort(
      (a, b) => AppFunctions.getCategoryName(
        a.name,
        l10n,
      ).compareTo(AppFunctions.getCategoryName(b.name, l10n)),
    );

    return Column(
      children: [
        Row(
          children: [
            BlocBuilder<MovementsHomeCubit, MovementsHomeState>(
              builder: (context, state) {
                return SizedBox(
                  width: 40,
                  height: 40,
                  child: AppFilledButton(
                    icon: state.recommendationsStatus.isLoading
                        ? Image.asset(
                            'assets/animations/gemini-loading.gif',
                          )
                        : const HugeIcon(
                            icon: HugeIcons.strokeRoundedAiIdea,
                            strokeWidth: 2,
                          ),
                    onPressed: state.recommendationsStatus.isLoading
                        ? null
                        : state.recommendationsStatus.isSuccess
                            ? () => context
                                .read<MovementsHomeCubit>()
                                .changeShowRecommendations()
                            : () => context
                                .read<MovementsHomeCubit>()
                                .getRecommendations(l10n: l10n),
                    isOnlyIcon: true,
                    innerPadding: const EdgeInsets.all(6),
                  ),
                );
              },
            ),
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  InkWell(
                    onTap: () => _showFilterTypeMenu(context, filterType),
                    borderRadius: BorderRadius.circular(8),
                    child: Chip(
                      padding: const EdgeInsets.all(4),
                      backgroundColor: filterType != null
                          ? Theme.of(context).colorScheme.secondaryContainer
                          : null,
                      side: filterType == null
                          ? null
                          : BorderSide(
                              color: Theme.of(context)
                                  .colorScheme
                                  .secondaryContainer,
                            ),
                      label: Row(
                        spacing: 4,
                        children: [
                          if (filterType != null)
                            HugeIcon(
                              icon: filterType == CategoryType.income
                                  ? HugeIcons.strokeRoundedMoneyAdd01
                                  : HugeIcons.strokeRoundedMoneyRemove01,
                            ),
                          if (filterType != null)
                            Text(
                              filterType == CategoryType.income
                                  ? l10n.incomeName
                                  : l10n.expenseName,
                            ),
                          if (filterType == null) Text(l10n.movementType),
                          if (filterType == null)
                            const HugeIcon(
                              icon: HugeIcons.strokeRoundedArrowDown01,
                            ),
                        ],
                      ),
                    ),
                  ),
                  if (filterType != null) const SizedBox(width: 8),
                  if (filterType != null)
                    InkWell(
                      onTap: () =>
                          _showFilterCategoryMenu(context, filterCategory),
                      borderRadius: BorderRadius.circular(8),
                      child: Chip(
                        padding: const EdgeInsets.all(4),
                        backgroundColor: filterCategory != null
                            ? Theme.of(context).colorScheme.secondaryContainer
                            : null,
                        side: filterCategory == null
                            ? null
                            : BorderSide(
                                color: Theme.of(context)
                                    .colorScheme
                                    .secondaryContainer,
                              ),
                        label: Row(
                          spacing: 4,
                          children: [
                            if (filterCategory != null)
                              HugeIcon(
                                icon: AppFunctions.getCategoryIcon(
                                  filterCategory!.icon,
                                ),
                              ),
                            if (filterCategory != null)
                              Text(
                                AppFunctions.getCategoryName(
                                  filterCategory!.name,
                                  l10n,
                                ),
                              ),
                            if (filterCategory == null) Text(l10n.movementType),
                            if (filterCategory == null)
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
          ],
        ),
        const AntRecommendationsWidget(),
      ],
    );
  }

  void _showFilterTypeMenu(BuildContext context, CategoryType? filterType) {
    final l10n = AppLocalizations.of(context);

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
                      groupValue: filterType,
                      onChanged: (value) {
                        onFilterTypeChanged(value);
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
    Category? filterCategory,
  ) {
    final l10n = AppLocalizations.of(context);

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
                      groupValue: filterCategory,
                      onChanged: (value) {
                        onFilterCategoryChanged(value);
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
                                (category) => category.type == filterType,
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
  const ListMovementsHome({
    this.filterType,
    this.filterCategory,
    super.key,
  });

  final CategoryType? filterType;
  final Category? filterCategory;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final auth = getIt<AuthenticationService>().auth;
    final database = getIt<DatabaseService>();

    return Expanded(
      child: FirestorePagination(
        key: ValueKey('$filterType-$filterCategory'),
        shrinkWrap: true,
        physics: const BouncingScrollPhysics(),
        query: database.getUserMovementsQuery(
          userId: auth.currentUser!.uid,
          type: filterType,
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
          return ListMovementsItemHome(movement: movement);
        },
      ),
    );
  }
}

class AntRecommendationsWidget extends StatelessWidget {
  const AntRecommendationsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MovementsHomeCubit, MovementsHomeState>(
      builder: (context, state) {
        return AnimatedSwitcher(
          duration: AppVariables.animationDuration,
          switchInCurve: Curves.easeInOut,
          switchOutCurve: Curves.easeInOut,
          transitionBuilder: (child, animation) {
            return SizeTransition(
              sizeFactor: animation,
              axisAlignment: -1,
              child: FadeTransition(
                opacity: animation,
                child: child,
              ),
            );
          },
          child: (!state.recommendationsStatus.isSuccess ||
                  state.recommendations == null ||
                  state.recommendations!.isEmpty ||
                  !state.showRecommendations)
              ? const SizedBox.shrink(key: ValueKey('empty'))
              : SizedBox(
                  key: const ValueKey('recommendations'),
                  height: 160,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: PageView.builder(
                      controller: PageController(viewportFraction: 0.93),
                      itemCount: state.recommendations!.length,
                      itemBuilder: (context, index) {
                        final recommendation = state.recommendations![index];
                        return Card(
                          elevation: 2,
                          margin: const EdgeInsets.symmetric(horizontal: 6),
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: SingleChildScrollView(
                              physics: const BouncingScrollPhysics(),
                              child: MarkdownBody(
                                data: recommendation,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
        );
      },
    );
  }
}
