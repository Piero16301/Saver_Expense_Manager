import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:saver_expense_manager/home/balance_home/balance_home.dart';

class BalanceHomePage extends StatelessWidget {
  const BalanceHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => BalanceHomeCubit()..init(),
      child: const BalanceHomeView(),
    );
  }
}
