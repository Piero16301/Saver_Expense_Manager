import 'dart:async';

import 'package:expressive_kit/expressive_kit.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:intl/intl.dart';
import 'package:material_ui/material_ui.dart';
import 'package:saver_expense_manager/app/app.dart';
import 'package:saver_expense_manager/home/home.dart';
import 'package:saver_expense_manager/l10n/l10n.dart';

class MovementsHomeView extends StatelessWidget {
  const new({required this.categories, super.key});

  final List<Category> categories;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final auth = getIt<AuthService>();
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
              userId: auth.currentUser!.uid,
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
                onFilterTypeChanged: context
                    .read<MovementsHomeCubit>()
                    .updateFilterType,
                onFilterCategoryChanged: context
                    .read<MovementsHomeCubit>()
                    .updateFilterCategory,
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
  const new({
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
                return ExpressiveIconButton.squircle(
                  variant: ExpressiveIconButtonVariant.filled,
                  icon: state.recommendationsStatus.isLoading
                      ? Image.asset(
                          'assets/animations/gemini-loading.gif',
                          height: 34,
                          width: 34,
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
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final options = [
      (null, l10n.movementTypeAll, HugeIcons.strokeRoundedTaskDaily01),
      (
        CategoryType.expense,
        l10n.expenseName,
        HugeIcons.strokeRoundedMoneyRemove01,
      ),
      (CategoryType.income, l10n.incomeName, HugeIcons.strokeRoundedMoneyAdd01),
    ];

    unawaited(
      showExpressiveModalBottomSheet<void>(
        context: context,
        title: l10n.movementTypeTitle,
        maxHeightFraction: AppVariables.modalBottomSheetMaxHeightPct,
        itemsBuilder: (modalContext) => options.map((option) {
          final value = option.$1;
          final title = option.$2;
          final icon = option.$3;
          final isSelected = filterType == value;

          return ListTile(
            leading: HugeIcon(
              icon: icon,
              color: isSelected
                  ? colorScheme.primary
                  : colorScheme.onSurfaceVariant,
              strokeWidth: 2,
            ),
            title: Text(
              title,
              style: theme.textTheme.bodyLarge?.copyWith(
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected ? colorScheme.primary : colorScheme.onSurface,
              ),
            ),
            trailing: isSelected
                ? HugeIcon(
                    icon: HugeIcons.strokeRoundedCheckmarkCircle02,
                    color: colorScheme.primary,
                    strokeWidth: 2,
                  )
                : null,
            onTap: () {
              onFilterTypeChanged(value);
              Navigator.pop(modalContext);
            },
          );
        }).toList(),
      ),
    );
  }

  void _showFilterCategoryMenu(BuildContext context, Category? filterCategory) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final filteredCategories = categories
        .where((category) => category.type == filterType)
        .toList();

    unawaited(
      showExpressiveModalBottomSheet<void>(
        context: context,
        title: l10n.movementCategoryTitle,
        maxHeightFraction: AppVariables.modalBottomSheetMaxHeightPct,
        itemsBuilder: (modalContext) => [
          ListTile(
            leading: HugeIcon(
              icon: HugeIcons.strokeRoundedGridView,
              color: filterCategory == null
                  ? colorScheme.primary
                  : colorScheme.onSurfaceVariant,
              strokeWidth: 2,
            ),
            title: Text(
              l10n.movementCategoryAll,
              style: theme.textTheme.bodyLarge?.copyWith(
                fontWeight: filterCategory == null
                    ? FontWeight.w700
                    : FontWeight.w500,
                color: filterCategory == null
                    ? colorScheme.primary
                    : colorScheme.onSurface,
              ),
            ),
            trailing: filterCategory == null
                ? HugeIcon(
                    icon: HugeIcons.strokeRoundedCheckmarkCircle02,
                    color: colorScheme.primary,
                    strokeWidth: 2,
                  )
                : null,
            onTap: () {
              onFilterCategoryChanged(null);
              Navigator.pop(modalContext);
            },
          ),
          ...filteredCategories.map((category) {
            final isSelected = filterCategory == category;
            return ListTile(
              leading: HugeIcon(
                icon: AppFunctions.getCategoryIcon(category.icon),
                color: isSelected
                    ? colorScheme.primary
                    : colorScheme.onSurfaceVariant,
                strokeWidth: 2,
              ),
              title: Text(
                AppFunctions.getCategoryName(category.name, l10n),
                style: theme.textTheme.bodyLarge?.copyWith(
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  color: isSelected
                      ? colorScheme.primary
                      : colorScheme.onSurface,
                ),
              ),
              trailing: isSelected
                  ? HugeIcon(
                      icon: HugeIcons.strokeRoundedCheckmarkCircle02,
                      color: colorScheme.primary,
                      strokeWidth: 2,
                    )
                  : null,
              onTap: () {
                onFilterCategoryChanged(category);
                Navigator.pop(modalContext);
              },
            );
          }),
        ],
      ),
    );
  }
}

class ListMovementsHome extends StatelessWidget {
  const new({this.filterType, this.filterCategory, super.key});

  final CategoryType? filterType;
  final Category? filterCategory;

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
        key: ValueKey('$filterType-$filterCategory'),
        stream: (limit) => database.getMovementsStream(
          userId: auth.currentUser!.uid,
          type: filterType,
          categoryId: filterCategory?.id,
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

class AntRecommendationsWidget extends StatelessWidget {
  const new({super.key});

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
              alignment: Alignment.topCenter,
              child: FadeTransition(opacity: animation, child: child),
            );
          },
          child:
              (!state.recommendationsStatus.isSuccess ||
                  state.recommendations == null ||
                  state.recommendations!.isEmpty ||
                  !state.showRecommendations)
              ? const SizedBox.shrink(key: ValueKey('empty'))
              : Padding(
                  key: const ValueKey('recommendations'),
                  padding: const EdgeInsets.only(top: 8),
                  child: ExpressiveCarousel(
                    height: 160,
                    itemExtent: MediaQuery.of(context).size.width * 0.9,
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    items: state.recommendations!.map((recommendation) {
                      return ExpressiveCarouselItem(
                        child: ExpressiveCard(
                          margin: EdgeInsets.zero,
                          padding: const EdgeInsets.all(12),
                          child: SingleChildScrollView(
                            physics: const BouncingScrollPhysics(),
                            // Use until flutter_markdown_plus 2.0.0 release
                            // ignore: deprecated_member_use
                            child: MaterialUiCompatibilityBridge(
                              child: MarkdownBody(data: recommendation),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
        );
      },
    );
  }
}
