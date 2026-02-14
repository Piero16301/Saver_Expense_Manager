import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:saver_expense_manager/home/home.dart';

class ExpensesHomePage extends StatelessWidget {
  const ExpensesHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ExpensesHomeCubit()..init(),
      child: const ExpensesHomeView(),
    );
  }
}
