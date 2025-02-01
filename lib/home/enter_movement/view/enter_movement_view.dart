import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:saver_expense_manager/app/app.dart';
import 'package:saver_expense_manager/home/enter_movement/enter_movement.dart';

class EnterMovementView extends StatelessWidget {
  const EnterMovementView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<EnterMovementCubit, EnterMovementState>(
      builder: (context, state) => Scaffold(
        appBar: AppBar(
          title: const Text('Movimiento'),
          centerTitle: true,
          notificationPredicate: (notification) => false,
        ),
        body: Padding(
          padding: const EdgeInsets.all(30),
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              spacing: 20,
              children: [
                AppTextField(
                  label: 'Título',
                  onChanged: context.read<EnterMovementCubit>().titleChanged,
                  initialValue: state.title,
                  prefix: const Icon(Icons.title),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
