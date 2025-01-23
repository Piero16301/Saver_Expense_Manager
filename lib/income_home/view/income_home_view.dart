import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:saver_expense_manager/app/app.dart';
import 'package:saver_expense_manager/income_home/income_home.dart';
import 'package:saver_expense_manager/models/models.dart';

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
          DoughnutCircularChart(
            data: const [
              ChartData(
                name: 'Salario',
                value: 50,
                color: '#FF4285F4',
              ),
              ChartData(
                name: 'Bonos',
                value: 75,
                color: 'FFEA4335',
              ),
              ChartData(
                name: 'Inversiones',
                value: 90,
                color: 'FFFBBC05',
              ),
              ChartData(
                name: 'Otros',
                value: 25,
                color: 'FF34A853',
              ),
              ChartData(
                name: 'Ahorros',
                value: 10,
                color: 'FF9C27B0',
              ),
            ],
            category: Category(
              id: '1',
              createdAt: DateTime.now(),
              updatedAt: DateTime.now(),
              name: 'Salario',
              color: '#FF4285F4',
            ),
            total: 936729,
            percentage: 25,
          ),
        ],
      ),
    );
  }
}
