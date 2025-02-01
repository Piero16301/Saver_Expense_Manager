import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:saver_expense_manager/home/enter_movement/enter_movement.dart';
import 'package:user_api/user_api.dart';

class EnterMovementPage extends StatelessWidget {
  const EnterMovementPage({
    required this.movement,
    super.key,
  });

  final Movement movement;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => EnterMovementCubit()..init(movement),
      child: const EnterMovementView(),
    );
  }
}
