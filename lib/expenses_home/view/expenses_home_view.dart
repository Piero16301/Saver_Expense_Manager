import 'package:flutter/material.dart';
import 'package:saver_expense_manager/app/app.dart';
import 'package:saver_expense_manager/models/models.dart';

class ExpensesHomeView extends StatelessWidget {
  const ExpensesHomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        DoughnutCircularChart(
          data: [
            ChartData(
              name: 'Transporte',
              value: 50,
              color: '#FF4285F4',
            ),
            ChartData(
              name: 'Entretenimiento',
              value: 75,
              color: 'FFEA4335',
            ),
            ChartData(
              name: 'Salud',
              value: 30,
              color: 'FFFBBC05',
            ),
            ChartData(
              name: 'Educación',
              value: 90,
              color: 'FF34A853',
            ),
            ChartData(
              name: 'Vivienda',
              value: 120,
              color: 'FF9C27B0',
            ),
          ],
        ),
      ],
    );
  }
}
