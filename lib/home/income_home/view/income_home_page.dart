import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:saver_expense_manager/home/income_home/income_home.dart';

class IncomeHomePage extends StatelessWidget {
  const IncomeHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => IncomeHomeCubit()..init(),
      child: const IncomeHomeView(),
    );
  }
}
