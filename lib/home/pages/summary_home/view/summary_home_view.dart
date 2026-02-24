import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:saver_expense_manager/app/app.dart';
import 'package:saver_expense_manager/category/category.dart';
import 'package:saver_expense_manager/home/home.dart';
import 'package:saver_expense_manager/l10n/l10n.dart';

class SummaryHomeView extends StatelessWidget {
  const SummaryHomeView({
    required this.categories,
    super.key,
  });

  final List<Category> categories;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final remoteConfig = getIt<RemoteConfigService>();
    final auth = getIt<AuthenticationService>().auth;
    final database = getIt<DatabaseService>();

    return BlocBuilder<SummaryHomeCubit, SummaryHomeState>(
      builder: (context, state) => StreamBuilder<List<Movement>>(
        stream: database.getUserMovementsRangeStream(
          userId: auth.currentUser!.uid,
          startMonth: state.startMonth!,
          endMonth: state.endMonth!,
        ),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.data!.isEmpty) {
            return Center(child: Text(l10n.movementsNoData));
          }

          final movements = snapshot.data!;

          return Column(
            spacing: 16,
            children: [
              MonthRangeSelector(
                startMonth: state.startMonth!,
                endMonth: state.endMonth!,
                onChangeStartMonth: (date) =>
                    context.read<SummaryHomeCubit>().changeStartMonth(date),
                onChangeEndMonth: (date) =>
                    context.read<SummaryHomeCubit>().changeEndMonth(date),
              ),
              if (remoteConfig.isHomeSummaryCardsVisible)
                ResumeMovementsChart(
                  movements: movements,
                  endMonth: state.endMonth!,
                  selResumeItems: state.selResumeItems,
                  onChangeResumeItems: (type) =>
                      context.read<SummaryHomeCubit>().toggleResumeItem(type),
                ),
              IncomesAndExpensesChart(
                movements: movements,
                startMonth: state.startMonth!,
                endMonth: state.endMonth!,
                selResumeItems: state.selResumeItems,
              ),
              if (remoteConfig.isHomeTopCategoriesVisible)
                CategoriesResumeCards(
                  movements: movements,
                  categories: categories,
                ),
            ],
          );
        },
      ),
    );
  }
}

class ResumeMovementsChart extends StatelessWidget {
  const ResumeMovementsChart({
    required this.movements,
    required this.endMonth,
    this.selResumeItems = const <ResumeItemType, bool>{},
    this.onChangeResumeItems,
    super.key,
  });

  final List<Movement> movements;
  final DateTime endMonth;
  final Map<ResumeItemType, bool> selResumeItems;
  final void Function(ResumeItemType type)? onChangeResumeItems;

  @override
  Widget build(BuildContext context) {
    final (
      pastMonthIncomes,
      pastMonthExpenses,
      currentMonthIncomes,
      currentMonthExpenses,
    ) = AppFunctions.calculateIncomesAndExpenses(
      movements: movements,
      endMonth: endMonth,
    );

    final (pastMonthBalance, currentMonthBalance) = (
      pastMonthIncomes - pastMonthExpenses,
      currentMonthIncomes - currentMonthExpenses,
    );

    return Row(
      spacing: 8,
      children: [
        ResumeItemCardMovements(
          type: ResumeItemType.income,
          value: currentMonthIncomes,
          difference: pastMonthIncomes == 0
              ? (currentMonthIncomes > 0 ? 100 : 0)
              : ((currentMonthIncomes - pastMonthIncomes) /
                      pastMonthIncomes *
                      100)
                  .roundToDouble(),
          color: AppVariables.incomeColor,
          isSelected: selResumeItems[ResumeItemType.income] ?? true,
          onTap: onChangeResumeItems,
        ),
        ResumeItemCardMovements(
          type: ResumeItemType.balance,
          value: currentMonthIncomes - currentMonthExpenses,
          difference: pastMonthBalance == 0
              ? (currentMonthBalance > 0 ? 100 : 0)
              : ((currentMonthBalance - pastMonthBalance) /
                      pastMonthBalance *
                      100)
                  .roundToDouble(),
          color: AppVariables.balanceColor,
          isSelected: selResumeItems[ResumeItemType.balance] ?? true,
          onTap: onChangeResumeItems,
        ),
        ResumeItemCardMovements(
          type: ResumeItemType.expense,
          value: currentMonthExpenses,
          difference: pastMonthExpenses == 0
              ? (currentMonthExpenses > 0 ? 100 : 0)
              : ((currentMonthExpenses - pastMonthExpenses) /
                      pastMonthExpenses *
                      100)
                  .roundToDouble(),
          color: AppVariables.expenseColor,
          isSelected: selResumeItems[ResumeItemType.expense] ?? true,
          onTap: onChangeResumeItems,
        ),
      ],
    );
  }
}

class ResumeItemCardMovements extends StatelessWidget {
  const ResumeItemCardMovements({
    required this.type,
    required this.value,
    required this.difference,
    required this.color,
    this.isSelected = true,
    this.onTap,
    super.key,
  });

  final ResumeItemType type;
  final double value;
  final double difference;
  final Color color;
  final bool isSelected;
  final void Function(ResumeItemType type)? onTap;

  List<List<dynamic>> get _icon {
    switch (type) {
      case ResumeItemType.income:
        return HugeIcons.strokeRoundedMoneyAdd01;
      case ResumeItemType.balance:
        return HugeIcons.strokeRoundedBalanceScale;
      case ResumeItemType.expense:
        return HugeIcons.strokeRoundedMoneyRemove01;
    }
  }

  String _title(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    switch (type) {
      case ResumeItemType.income:
        return l10n.categoryIncomeTitle;
      case ResumeItemType.balance:
        return l10n.categoryBalanceTitle;
      case ResumeItemType.expense:
        return l10n.categoryExpenseTitle;
    }
  }

  Color get _differenceColor {
    if (type == ResumeItemType.expense) {
      return difference < 0
          ? AppVariables.growthColor
          : AppVariables.decreaseColor;
    } else {
      return difference >= 0
          ? AppVariables.growthColor
          : AppVariables.decreaseColor;
    }
  }

  String _valueFormatted() {
    if (type == ResumeItemType.balance) {
      return '${value >= 0 ? '+' : ''}'
          '${AppExtensions.moneyFormat.format(value)}';
    }
    return AppExtensions.moneyFormat.format(value);
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Opacity(
        opacity: isSelected ? 1.0 : 0.5,
        child: Card(
          margin: EdgeInsets.zero,
          elevation: isSelected ? 2 : 1,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(
              color: isSelected
                  ? color.withValues(alpha: 0.5)
                  : Colors.transparent,
              width: 2,
            ),
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: onTap != null ? () => onTap!(type) : null,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                spacing: 8,
                children: [
                  Row(
                    spacing: 8,
                    children: [
                      HugeIcon(
                        icon: _icon,
                        size: 20,
                        color: color,
                      ),
                      Text(
                        _title(context),
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ],
                  ),
                  Text(
                    _valueFormatted(),
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: color,
                        ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    spacing: 4,
                    children: [
                      HugeIcon(
                        icon: difference >= 0
                            ? HugeIcons.strokeRoundedArrowUpDouble
                            : HugeIcons.strokeRoundedArrowDownDouble,
                        size: 16,
                        color: _differenceColor,
                      ),
                      Text(
                        '${difference >= 0 ? '+' : ''}'
                        '${difference.abs().toInt()}%',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: _differenceColor,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class IncomesAndExpensesChart extends StatelessWidget {
  const IncomesAndExpensesChart({
    required this.movements,
    required this.startMonth,
    required this.endMonth,
    required this.selResumeItems,
    super.key,
  });

  final List<Movement> movements;
  final DateTime startMonth;
  final DateTime endMonth;
  final Map<ResumeItemType, bool> selResumeItems;

  @override
  Widget build(BuildContext context) {
    final language = context.select<AppCubit, Locale>(
      (cubit) => cubit.state.language,
    );
    final l10n = AppLocalizations.of(context);

    final titles = <String>[];
    final colors = <Color>[];

    if (selResumeItems[ResumeItemType.income] ?? true) {
      titles.add(l10n.categoryIncomeTitle);
      colors.add(AppVariables.incomeColor);
    }
    if (selResumeItems[ResumeItemType.expense] ?? true) {
      titles.add(l10n.categoryExpenseTitle);
      colors.add(AppVariables.expenseColor);
    }
    if (selResumeItems[ResumeItemType.balance] ?? true) {
      titles.add(l10n.categoryBalanceTitle);
      colors.add(AppVariables.balanceColor);
    }

    return Visibility(
      visible: titles.isNotEmpty,
      child: Expanded(
        child: LinearChart(
          titles: titles,
          colors: colors,
          data: AppFunctions.buildResumeTrendData(
            movements: movements,
            startMonth: startMonth,
            endMonth: endMonth,
            language: language.toString(),
            selResumeItems: selResumeItems,
          ),
        ),
      ),
    );
  }
}

class CategoriesResumeCards extends StatefulWidget {
  const CategoriesResumeCards({
    required this.movements,
    required this.categories,
    super.key,
  });

  final List<Movement> movements;
  final List<Category> categories;

  @override
  State<CategoriesResumeCards> createState() => _CategoriesResumeCardsState();
}

class _CategoriesResumeCardsState extends State<CategoriesResumeCards> {
  CategoryType selectedFilter = CategoryType.expense;

  @override
  Widget build(BuildContext context) {
    final categoryExpenses = AppFunctions.calculateCategoryAmounts(
      movements: widget.movements,
      filterType: selectedFilter,
    );

    final sortedCategories = categoryExpenses.values.toList()
      ..sort(
        (a, b) => b.totalExpense.compareTo(a.totalExpense),
      );

    final totalExpenses = sortedCategories.fold<double>(
      0,
      (s, item) => s + item.totalExpense,
    );

    return Visibility(
      visible: sortedCategories.isNotEmpty,
      child: Column(
        children: [
          Row(
            spacing: 12,
            children: [
              SizedBox(
                height: 180,
                child: SegmentedButton<CategoryType>(
                  direction: Axis.vertical,
                  showSelectedIcon: false,
                  segments: [
                    ButtonSegment<CategoryType>(
                      value: CategoryType.expense,
                      label: HugeIcon(
                        icon: HugeIcons.strokeRoundedMoneyRemove01,
                        strokeWidth: 2,
                        color: selectedFilter == CategoryType.expense
                            ? AppVariables.expenseColor
                            : null,
                      ),
                    ),
                    ButtonSegment<CategoryType>(
                      value: CategoryType.income,
                      label: HugeIcon(
                        icon: HugeIcons.strokeRoundedMoneyAdd01,
                        strokeWidth: 2,
                        color: selectedFilter == CategoryType.income
                            ? AppVariables.incomeColor
                            : null,
                      ),
                    ),
                  ],
                  selected: {selectedFilter},
                  onSelectionChanged: (newSelection) {
                    setState(() {
                      selectedFilter = newSelection.first;
                    });
                  },
                  style: const ButtonStyle(
                    visualDensity: VisualDensity.compact,
                    shape: WidgetStatePropertyAll(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(16)),
                      ),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: SizedBox(
                  height: 180,
                  width: double.infinity,
                  child: ListView.separated(
                    physics: const BouncingScrollPhysics(),
                    scrollDirection: Axis.horizontal,
                    padding: EdgeInsets.zero,
                    itemCount: sortedCategories.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(width: 12),
                    itemBuilder: (context, index) {
                      final categoryData = sortedCategories[index];
                      final percentage = totalExpenses > 0
                          ? (categoryData.totalExpense / totalExpenses * 100)
                          : 0.0;
                      final ranking = index + 1;

                      return InkWell(
                        borderRadius: BorderRadius.circular(16),
                        onTap: () => context.pushNamed(
                          CategoryPage.pageName,
                          extra: categoryData.category,
                        ),
                        child: CategoryExpenseCard(
                          category: categoryData.category,
                          amount: categoryData.totalExpense,
                          percentage: percentage,
                          ranking: ranking,
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }
}

class CategoryExpenseCard extends StatelessWidget {
  const CategoryExpenseCard({
    required this.category,
    required this.amount,
    required this.percentage,
    required this.ranking,
    super.key,
  });

  final Category category;
  final double amount;
  final double percentage;
  final int ranking;

  String _getRankingText() {
    return '#$ranking';
  }

  Color get _rankingColor {
    switch (ranking) {
      case 1:
        return const Color(0xFFFFD700);
      case 2:
        return const Color(0xFFC0C0C0);
      case 3:
        return const Color(0xFFCD7F32);
      default:
        return Colors.grey.shade600;
    }
  }

  Color get _rankingBackgroundColor {
    switch (ranking) {
      case 1:
        return const Color(0xFFFFD700).withValues(alpha: 0.2);
      case 2:
        return const Color(0xFFC0C0C0).withValues(alpha: 0.2);
      case 3:
        return const Color(0xFFCD7F32).withValues(alpha: 0.2);
      default:
        return Colors.grey.withValues(alpha: 0.2);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final categoryColor = HexColor.fromHex(category.color);

    return SizedBox(
      width: 180,
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: categoryColor.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: HugeIcon(
                      icon: AppFunctions.getCategoryIcon(category.icon),
                      color: categoryColor,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: _rankingBackgroundColor,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      _getRankingText(),
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: _rankingColor,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 8,
                children: [
                  Text(
                    AppFunctions.getCategoryName(category.name, l10n)
                        .toUpperCase(),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.5,
                        ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    AppExtensions.moneyFormat.format(amount),
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: percentage / 100,
                      backgroundColor: categoryColor.withValues(alpha: 0.2),
                      valueColor: AlwaysStoppedAnimation<Color>(categoryColor),
                      minHeight: 6,
                    ),
                  ),
                  Text(
                    '${percentage.toInt()}% del total',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context)
                              .textTheme
                              .bodySmall
                              ?.color
                              ?.withValues(alpha: 0.6),
                        ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
