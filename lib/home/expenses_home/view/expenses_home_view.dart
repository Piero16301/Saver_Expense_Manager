import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:saver_expense_manager/app/app.dart';
import 'package:saver_expense_manager/home/expenses_home/expenses_home.dart';

class ExpensesHomeView extends StatelessWidget {
  const ExpensesHomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ExpensesHomeCubit, ExpensesHomeState>(
      builder: (context, state) => Column(
        children: [
          MonthSelector(
            monthSelected: state.monthSelected!,
            onBack: () => context.read<ExpensesHomeCubit>().previousMonth(),
            onForward: () => context.read<ExpensesHomeCubit>().nextMonth(),
            onChangeMonth: context.read<ExpensesHomeCubit>().changeMonth,
          ),
          TotalSpentChart(data: expensesChartData),
          DoughnutCircularChart(
            data: expensesChartData,
            explodeIndex: state.explodeIndex,
            onPointTap: (p0) => context
                .read<ExpensesHomeCubit>()
                .changeExplodeIndex(p0.pointIndex),
          ),
          CategoriesListChart(data: expensesChartData),
        ],
      ),
    );
  }
}
