import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:saver_expense_manager/app/app.dart';
import 'package:saver_expense_manager/l10n/l10n.dart';
import 'package:user_api/user_api.dart';

class MovementsChartType extends StatefulWidget {
  const MovementsChartType({
    required this.categories,
    super.key,
  });

  final List<Category> categories;

  @override
  State<MovementsChartType> createState() => _MovementsChartTypeState();
}

class _MovementsChartTypeState extends State<MovementsChartType> {
  late DateTime startMonth;
  late DateTime endMonth;

  Map<ResumeItemType, bool> selResumeItems = {
    ResumeItemType.income: true,
    ResumeItemType.balance: true,
    ResumeItemType.expense: true,
  };

  @override
  void initState() {
    startMonth = AppFunctions.substracMonth(AppVariables.deafultMonthsResume);
    endMonth = DateTime.now();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final l10n = AppLocalizations.of(context);

    return StreamBuilder<QuerySnapshot>(
      stream: AppFunctions.getUserMovementsRange(
        userId: user!.uid,
        startMonth: startMonth,
        endMonth: endMonth,
      ),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.data!.docs.isEmpty) {
          return Center(child: Text(l10n.movementsNoData));
        }

        final docs = snapshot.data!.docs
            as List<QueryDocumentSnapshot<Map<String, dynamic>>>;
        final movements = docs.map((e) => Movement.fromJson(e.data())).toList();

        return Column(
          spacing: 16,
          children: [
            MonthRangeSelector(
              startMonth: startMonth,
              endMonth: endMonth,
              rangeMonths: 2,
              onChangeStartMonth: (date) {
                if (date != null) {
                  setState(() {
                    startMonth = date;
                  });
                }
              },
              onChangeEndMonth: (date) {
                if (date != null) {
                  setState(() {
                    endMonth = date;
                  });
                }
              },
            ),
            ResumeMovementsChart(
              movements: movements,
              endMonth: endMonth,
              selResumeItems: selResumeItems,
              onChangeResumeItems: (type) {
                setState(() {
                  selResumeItems[type] = !(selResumeItems[type] ?? true);
                });
              },
            ),
            IncomesAndExpensesChart(
              movements: movements,
              startMonth: startMonth,
              endMonth: endMonth,
              selResumeItems: selResumeItems,
            ),
            // CategoriesResumeCards(
            //   movements: movements,
            //   categories: widget.categories,
            // ),
            const SizedBox(height: 48),
          ],
        );
      },
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
      twoMonthsAgoIncomes,
      twoMonthsAgoExpenses,
      oneMonthAgoIncomes,
      oneMonthAgoExpenses
    ) = AppFunctions.calculateIncomesAndExpenses(
      movements: movements,
      endMonth: endMonth,
    );

    final (twoMonthsAgoBalance, oneMonthAgoBalance) = (
      twoMonthsAgoIncomes - twoMonthsAgoExpenses,
      oneMonthAgoIncomes - oneMonthAgoExpenses
    );

    return Row(
      spacing: 8,
      children: [
        ResumeItemCardMovements(
          type: ResumeItemType.income,
          value: oneMonthAgoIncomes,
          difference: twoMonthsAgoIncomes == 0
              ? (oneMonthAgoIncomes > 0 ? 100 : 0)
              : ((oneMonthAgoIncomes - twoMonthsAgoIncomes) /
                      twoMonthsAgoIncomes *
                      100)
                  .roundToDouble(),
          color: AppVariables.incomeColor,
          isSelected: selResumeItems[ResumeItemType.income] ?? true,
          onTap: onChangeResumeItems,
        ),
        ResumeItemCardMovements(
          type: ResumeItemType.balance,
          value: oneMonthAgoIncomes - oneMonthAgoExpenses,
          difference: twoMonthsAgoBalance == 0
              ? (oneMonthAgoBalance > 0 ? 100 : 0)
              : ((oneMonthAgoBalance - twoMonthsAgoBalance) /
                      twoMonthsAgoBalance *
                      100)
                  .roundToDouble(),
          color: AppVariables.balanceColor,
          isSelected: selResumeItems[ResumeItemType.balance] ?? true,
          onTap: onChangeResumeItems,
        ),
        ResumeItemCardMovements(
          type: ResumeItemType.expense,
          value: oneMonthAgoExpenses,
          difference: twoMonthsAgoExpenses == 0
              ? (oneMonthAgoExpenses > 0 ? 100 : 0)
              : ((oneMonthAgoExpenses - twoMonthsAgoExpenses) /
                      twoMonthsAgoExpenses *
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
      return '${value >= 0 ? '+' : '-'}'
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
          elevation: isSelected ? 4 : 1,
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
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
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
                        '${difference >= 0 ? '+' : '-'}'
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
    final language = context.select<AppCubit, String>(
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
            language: language,
            selResumeItems: selResumeItems,
          ),
        ),
      ),
    );
  }
}

class CategoriesResumeCards extends StatelessWidget {
  const CategoriesResumeCards({
    required this.movements,
    required this.categories,
    super.key,
  });

  final List<Movement> movements;
  final List<Category> categories;

  @override
  Widget build(BuildContext context) {
    return const Expanded(
      child: Placeholder(),
    );
  }
}
