import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:saver_expense_manager/app/app.dart';
import 'package:saver_expense_manager/models/models.dart';

class BalanceHomeView extends StatelessWidget {
  const BalanceHomeView({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Column(
      children: [
        RadialCircularChart(
          data: const [
            ChartData(
              name: 'Gastos',
              value: 25,
              color: '#8B0000',
            ),
            ChartData(
              name: 'Ingresos',
              value: 75,
              color: '#006400',
            ),
          ],
          image: highResPicture(user!.photoURL),
        ),
      ],
    );
  }
}
