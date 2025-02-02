import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:saver_expense_manager/app/app.dart';
import 'package:saver_expense_manager/home/enter_movement/enter_movement.dart';
import 'package:user_api/user_api.dart';

class EnterMovementPage extends StatelessWidget {
  const EnterMovementPage({
    required this.movement,
    required this.type,
    required this.screenType,
    super.key,
  });

  final Movement movement;
  final CategoryType type;
  final MovementScreenType screenType;

  @override
  Widget build(BuildContext context) {
    final categories = context
        .select<AppCubit, List<Category>>((cubit) => cubit.state.categories)
        .where((element) => element.type == type)
        .toList();

    return BlocProvider(
      create: (_) => EnterMovementCubit()..init(movement, categories),
      child: EnterMovementView(type: type, screenType: screenType),
    );
  }
}
