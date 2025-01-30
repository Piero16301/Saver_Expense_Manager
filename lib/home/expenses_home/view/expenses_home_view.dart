import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:saver_expense_manager/app/app.dart';
import 'package:saver_expense_manager/home/expenses_home/expenses_home.dart';
import 'package:saver_expense_manager/models/models.dart';

class ExpensesHomeView extends StatelessWidget {
  const ExpensesHomeView({super.key});

  @override
  Widget build(BuildContext context) {
    final data = [
      const ChartData(
        name: 'Transporte',
        value: 15000.75,
        color: '#FF4285F4',
      ),
      const ChartData(
        name: 'Entretenimiento',
        value: 27500.50,
        color: 'FFEA4335',
      ),
      const ChartData(
        name: 'Salud',
        value: 13000.25,
        color: 'FFFBBC05',
      ),
      const ChartData(
        name: 'Educación',
        value: 19000.80,
        color: 'FF34A853',
      ),
      const ChartData(
        name: 'Vivienda',
        value: 32000.40,
        color: 'FF9C27B0',
      ),
    ];

    return BlocBuilder<ExpensesHomeCubit, ExpensesHomeState>(
      builder: (context, state) => Column(
        children: [
          MonthSelector(
            monthSelected: state.monthSelected!,
            onBack: () => context.read<ExpensesHomeCubit>().previousMonth(),
            onForward: () => context.read<ExpensesHomeCubit>().nextMonth(),
            onChangeMonth: context.read<ExpensesHomeCubit>().changeMonth,
          ),
          TotalSpentChart(data: data),
          DoughnutCircularChart(
            data: data,
            explodeIndex: state.explodeIndex,
            onPointTap: (p0) => context
                .read<ExpensesHomeCubit>()
                .changeExplodeIndex(p0.pointIndex),
          ),
          CategoriesListChart(data: data),
        ],
      ),
    );
  }
}
