import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:saver_expense_manager/home/movements_home/movements_home.dart';

class MovementsHomePage extends StatelessWidget {
  const MovementsHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => MovementsHomeCubit(),
      child: const MovementsHomeView(),
    );
  }
}
