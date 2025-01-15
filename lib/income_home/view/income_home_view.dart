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
        ),
      ],
    );
  }
}
