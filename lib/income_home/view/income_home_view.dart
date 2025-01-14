import 'package:flutter/material.dart';
import 'package:saver_expense_manager/app/app.dart';
import 'package:saver_expense_manager/models/models.dart';

class IncomeHomeView extends StatelessWidget {
  const IncomeHomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        DoughnutCircularChart(
          data: [
            ChartData(
              id: '1',
              name: 'Salario',
              value: 50,
            ),
            ChartData(
              id: '2',
              name: 'Bonos',
              value: 75,
            ),
            ChartData(
              id: '3',
              name: 'Inversiones',
              value: 90,
            ),
          ],
        ),
      ],
    );
  }
}
