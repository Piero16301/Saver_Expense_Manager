import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:saver_expense_manager/app/app.dart';
import 'package:saver_expense_manager/home/movement/movement.dart';
import 'package:saver_expense_manager/l10n/l10n.dart';
import 'package:user_api/user_api.dart';

class MovementPage extends StatelessWidget {
  const MovementPage({
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
    final l10n = AppLocalizations.of(context);
    final categories =
        context
            .select<AppCubit, List<Category>>((cubit) => cubit.state.categories)
            .where((element) => element.type == type)
            .toList()
          ..sort(
            (a, b) => getCategoryName(
              a.name,
              l10n,
            ).compareTo(getCategoryName(b.name, l10n)),
          );

    return BlocProvider(
      create: (_) => MovementCubit()..init(movement, categories),
      child: MovementView(type: type, screenType: screenType),
    );
  }
}
