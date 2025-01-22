import 'package:flutter/material.dart';
import 'package:saver_expense_manager/app/app.dart';
import 'package:saver_expense_manager/models/models.dart';

class ExpensesHomeView extends StatelessWidget {
  const ExpensesHomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        DoughnutCircularChart(
          data: const [
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
          category: Category(
            id: '1',
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
            name: 'Transporte',
            color: '#FF4285F4',
          ),
          total: 264981,
          percentage: 65,
        ),
      ],
    );
  }
}
