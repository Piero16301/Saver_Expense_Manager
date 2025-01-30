import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:saver_expense_manager/app/app.dart';
import 'package:saver_expense_manager/home/balance_home/balance_home.dart';
import 'package:user_api/user_api.dart';

class BalanceHomeView extends StatelessWidget {
  const BalanceHomeView({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return BlocBuilder<BalanceHomeCubit, BalanceHomeState>(
      builder: (context, state) => Column(
        children: [
          MonthSelector(
            monthSelected: state.monthSelected!,
            onBack: () => context.read<BalanceHomeCubit>().previousMonth(),
            onForward: () => context.read<BalanceHomeCubit>().nextMonth(),
            onChangeMonth: context.read<BalanceHomeCubit>().changeMonth,
          ),
          const SizedBox(height: 10),
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
      ),
    );
  }
}
