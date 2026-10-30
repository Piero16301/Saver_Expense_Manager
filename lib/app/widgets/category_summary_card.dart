import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:go_router/go_router.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:material_ui/material_ui.dart';
import 'package:saver_expense_manager/app/app.dart';
import 'package:saver_expense_manager/l10n/l10n.dart';

typedef ExpensesCategorySummaryCard = CategorySummaryCard;
typedef IncomeCategorySummaryCard = CategorySummaryCard;

class CategorySummaryCard extends StatelessWidget {
  const CategorySummaryCard({
    required this.data,
    required this.selectedIndex,
    required this.onCategorySelected,
    this.isExpanded = false,
    super.key,
  });

  final List<CategoryData> data;
  final int selectedIndex;
  final ValueChanged<int> onCategorySelected;
  final bool isExpanded;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final safeIndex = selectedIndex.clamp(0, data.length - 1);
    final selectedItem = data[safeIndex];
    final totalValue = data.fold<double>(
      0,
      (previousValue, element) => previousValue + element.value,
    );
    final selectedPercentage = totalValue > 0
        ? (selectedItem.value / totalValue * 100)
        : 0.0;
    final selectedColor = HexColor.fromHex(selectedItem.category.color);
    final valueFormat = AppExtensions.moneyFormat.format(selectedItem.value);

    return Card(
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: EdgeInsets.all(isExpanded ? 18 : 14),
        child: Column(
          mainAxisSize: isExpanded ? MainAxisSize.max : MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: 12,
          children: [
            Row(
              spacing: 12,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      l10n.homeTotal,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                        fontVariations: <FontVariation>[
                          ...(theme.textTheme.headlineMedium?.fontVariations ??
                                  const <FontVariation>[])
                              .where((v) => v.axis != 'wght'),
                          const FontVariation('wght', 700),
                        ],
                      ),
                    ),
                    Text(
                      AppExtensions.moneyFormat.format(totalValue),
                      style: theme.textTheme.headlineMedium!.copyWith(
                        fontVariations: <FontVariation>[
                          ...(theme.textTheme.headlineMedium?.fontVariations ??
                                  const <FontVariation>[])
                              .where((v) => v.axis != 'wght'),
                          const FontVariation('wght', 700),
                        ],
                      ),
                    ),
                  ],
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisSize: MainAxisSize.min,
                    spacing: 6,
                    children: [
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerRight,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          spacing: 6,
                          children: [
                            Container(
                              width: 10,
                              height: 10,
                              decoration: BoxDecoration(
                                color: selectedColor,
                                shape: BoxShape.circle,
                              ),
                            ),
                            Text(
                              AppFunctions.getCategoryName(
                                selectedItem.category.name,
                                l10n,
                              ),
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                            Text(
                              '· $valueFormat (${selectedPercentage.toInt()}%)',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                fontVariations: <FontVariation>[
                                  ...(theme
                                              .textTheme
                                              .bodySmall
                                              ?.fontVariations ??
                                          const <FontVariation>[])
                                      .where((v) => v.axis != 'wght'),
                                  const FontVariation('wght', 700),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        height: 34,
                        child: FilledButton.tonal(
                          style: FilledButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 14),
                          ),
                          onPressed: () => context.pushNamed(
                            AppRoute.category.name,
                            extra: selectedItem.category,
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            spacing: 4,
                            children: [
                              Text(
                                l10n.homeDetails,
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  fontVariations: <FontVariation>[
                                    ...(theme
                                                .textTheme
                                                .bodyMedium
                                                ?.fontVariations ??
                                            const <FontVariation>[])
                                        .where((v) => v.axis != 'wght'),
                                    const FontVariation('wght', 600),
                                  ],
                                ),
                              ),
                              const HugeIcon(
                                icon: HugeIcons.strokeRoundedArrowRight01,
                                size: 16,
                                strokeWidth: 2,
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
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: SizedBox(
                height: 14,
                child: Row(
                  children: [
                    for (var i = 0; i < data.length; i++) ...[
                      if (i > 0) const SizedBox(width: 2),
                      Expanded(
                        flex: totalValue > 0
                            ? ((data[i].value / totalValue) * 1000)
                                  .round()
                                  .clamp(15, 1000)
                            : 1,
                        child: GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: () => onCategorySelected(i),
                          child: AnimatedContainer(
                            duration: AppVariables.animationDuration,
                            color: i == safeIndex
                                ? HexColor.fromHex(data[i].category.color)
                                : HexColor.fromHex(
                                    data[i].category.color,
                                  ).withValues(alpha: 0.4),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            if (isExpanded)
              Expanded(
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(
                    parent: kIsWeb
                        ? ClampingScrollPhysics()
                        : BouncingScrollPhysics(),
                  ),
                  child: Column(
                    spacing: 8,
                    children: [
                      for (var i = 0; i < data.length; i++)
                        _CategoryExpandedItem(
                          item: data[i],
                          percentage: totalValue > 0
                              ? (data[i].value / totalValue * 100)
                              : 0,
                          isSelected: i == safeIndex,
                          onTap: () => onCategorySelected(i),
                        ),
                    ],
                  ),
                ),
              )
            else
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                child: Row(
                  spacing: 8,
                  children: [
                    for (var i = 0; i < data.length; i++)
                      _CategorySegmentChip(
                        item: data[i],
                        percentage: totalValue > 0
                            ? (data[i].value / totalValue * 100)
                            : 0,
                        isSelected: i == safeIndex,
                        onTap: () => onCategorySelected(i),
                      ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _CategoryExpandedItem extends StatelessWidget {
  const _CategoryExpandedItem({
    required this.item,
    required this.percentage,
    required this.isSelected,
    required this.onTap,
  });

  final CategoryData item;
  final double percentage;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final categoryColor = HexColor.fromHex(item.category.color);

    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: AnimatedContainer(
        duration: AppVariables.animationDuration,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected
              ? categoryColor.withValues(alpha: 0.16)
              : theme.colorScheme.surfaceContainerHighest.withValues(
                  alpha: 0.3,
                ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? categoryColor
                : categoryColor.withValues(alpha: 0.2),
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(
          spacing: 12,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: categoryColor.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: HugeIcon(
                icon: AppFunctions.getCategoryIcon(item.category.icon),
                size: 20,
                color: categoryColor,
                strokeWidth: 2,
              ),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                spacing: 6,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    spacing: 8,
                    children: [
                      Flexible(
                        child: Text(
                          AppFunctions.getCategoryName(
                            item.category.name,
                            l10n,
                          ),
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontVariations: <FontVariation>[
                              ...(theme.textTheme.bodyMedium?.fontVariations ??
                                      const <FontVariation>[])
                                  .where((v) => v.axis != 'wght'),
                              FontVariation('wght', isSelected ? 700 : 500),
                            ],
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text(
                        AppExtensions.moneyFormat.format(item.value),
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontVariations: <FontVariation>[
                            ...(theme.textTheme.bodyMedium?.fontVariations ??
                                    const <FontVariation>[])
                                .where((v) => v.axis != 'wght'),
                            const FontVariation('wght', 700),
                          ],
                        ),
                      ),
                    ],
                  ),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: (percentage / 100).clamp(0.0, 1.0),
                      minHeight: 6,
                      backgroundColor: categoryColor.withValues(alpha: 0.15),
                      valueColor: AlwaysStoppedAnimation<Color>(categoryColor),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              constraints: const BoxConstraints(minWidth: 46),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: categoryColor.withValues(
                  alpha: isSelected ? 0.25 : 0.12,
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                '${percentage.toInt()}%',
                textAlign: TextAlign.center,
                style: theme.textTheme.labelMedium?.copyWith(
                  color: categoryColor,
                  fontVariations: <FontVariation>[
                    ...(theme.textTheme.labelMedium?.fontVariations ??
                            const <FontVariation>[])
                        .where((v) => v.axis != 'wght'),
                    const FontVariation('wght', 700),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CategorySegmentChip extends StatelessWidget {
  const _CategorySegmentChip({
    required this.item,
    required this.percentage,
    required this.isSelected,
    required this.onTap,
  });

  final CategoryData item;
  final double percentage;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final categoryColor = HexColor.fromHex(item.category.color);

    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: onTap,
      child: AnimatedContainer(
        duration: AppVariables.animationDuration,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected
              ? categoryColor.withValues(alpha: 0.2)
              : theme.colorScheme.surfaceContainerHighest.withValues(
                  alpha: 0.4,
                ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? categoryColor
                : categoryColor.withValues(alpha: 0.25),
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          spacing: 6,
          children: [
            HugeIcon(
              icon: AppFunctions.getCategoryIcon(item.category.icon),
              size: 22,
              color: categoryColor,
              strokeWidth: 2,
            ),
            Text(
              '${percentage.toInt()}%',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: isSelected
                    ? categoryColor
                    : theme.colorScheme.onSurfaceVariant,
                fontVariations: <FontVariation>[
                  ...(theme.textTheme.bodyMedium?.fontVariations ??
                          const <FontVariation>[])
                      .where((v) => v.axis != 'wght'),
                  FontVariation('wght', isSelected ? 700 : 600),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
