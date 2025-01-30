import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:saver_expense_manager/app/app.dart';
import 'package:saver_expense_manager/home/income_home/income_home.dart';
import 'package:saver_expense_manager/models/models.dart';

class IncomeHomeView extends StatelessWidget {
  const IncomeHomeView({super.key});

  @override
  Widget build(BuildContext context) {
    final data = [
      const ChartData(
        name: 'Salario',
        value: 15000.75,
        color: '#FF4285F4',
      ),
      const ChartData(
        name: 'Bonos',
        value: 27500.50,
        color: 'FFEA4335',
      ),
      const ChartData(
        name: 'Inversiones',
        value: 39000.25,
        color: 'FFFBBC05',
      ),
      const ChartData(
        name: 'Otros',
        value: 12500.80,
        color: 'FF34A853',
      ),
      const ChartData(
        name: 'Ahorros',
        value: 21000.10,
        color: 'FF9C27B0',
      ),
    ];

    return BlocBuilder<IncomeHomeCubit, IncomeHomeState>(
      builder: (context, state) => Column(
        children: [
          MonthSelector(
            monthSelected: state.monthSelected!,
            onBack: () => context.read<IncomeHomeCubit>().previousMonth(),
            onForward: () => context.read<IncomeHomeCubit>().nextMonth(),
            onChangeMonth: context.read<IncomeHomeCubit>().changeMonth,
          ),
          TotalSpentChart(data: data),
          DoughnutCircularChart(
            data: data,
            explodeIndex: state.explodeIndex,
            onPointTap: (p0) => context
                .read<IncomeHomeCubit>()
                .changeExplodeIndex(p0.pointIndex),
          ),
        ],
      ),
    );
  }
}
