import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:saver_expense_manager/app/app.dart';
import 'package:saver_expense_manager/home/income_home/income_home.dart';

class IncomeHomeView extends StatelessWidget {
  const IncomeHomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<IncomeHomeCubit, IncomeHomeState>(
      builder: (context, state) => Column(
        children: [
          MonthSelector(
            monthSelected: state.monthSelected!,
            onBack: () => context.read<IncomeHomeCubit>().previousMonth(),
            onForward: () => context.read<IncomeHomeCubit>().nextMonth(),
            onChangeMonth: context.read<IncomeHomeCubit>().changeMonth,
          ),
          TotalSpentChart(data: incomesChartData),
          DoughnutCircularChart(
            data: incomesChartData,
            explodeIndex: state.explodeIndex,
            onPointTap: (p0) => context
                .read<IncomeHomeCubit>()
                .changeExplodeIndex(p0.pointIndex),
          ),
          CategoriesListChart(data: incomesChartData),
        ],
      ),
    );
  }
}
