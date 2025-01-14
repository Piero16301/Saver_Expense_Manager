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
              id: '1',
              name: 'Transporte',
              value: 50,
            ),
            ChartData(
              id: '2',
              name: 'Entretenimiento',
              value: 75,
            ),
            ChartData(
              id: '3',
              name: 'Salud',
              value: 30,
            ),
            ChartData(
              id: '4',
              name: 'Educación',
              value: 90,
            ),
            ChartData(
              id: '5',
              name: 'Vivienda',
              value: 120,
            ),
            ChartData(
              id: '6',
              name: 'Ropa',
              value: 45,
            ),
            ChartData(
              id: '7',
              name: 'Viajes',
              value: 60,
            ),
            ChartData(
              id: '8',
              name: 'Regalos',
              value: 20,
            ),
            ChartData(
              id: '9',
              name: 'Mascotas',
              value: 35,
            ),
            ChartData(
              id: '10',
              name: 'Otros',
              value: 25,
            ),
          ],
        ),
      ],
    );
  }
}
