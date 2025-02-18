import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:saver_expense_manager/app/app.dart';
import 'package:saver_expense_manager/home/movements_home/movements_home.dart';
import 'package:saver_expense_manager/l10n/l10n.dart';
import 'package:user_api/user_api.dart';

class MovementsHomeView extends StatelessWidget {
  const MovementsHomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MovementsHomeCubit, MovementsHomeState>(
      builder: (context, state) => const Column(
        children: [
          FilterMovementsHome(),
        ],
      ),
    );
  }
}

class FilterMovementsHome extends StatelessWidget {
  const FilterMovementsHome({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final categories = context
        .select<AppCubit, List<Category>>((cubit) => cubit.state.categories)
      ..sort(
        (a, b) => getCategoryName(a.name, l10n)
            .compareTo(getCategoryName(b.name, l10n)),
      );

    return BlocBuilder<MovementsHomeCubit, MovementsHomeState>(
      builder: (context, state) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 10),
          AppDropdownField<Category>(
            label: l10n.movementCategory,
            options: categories
                .map(
                  (category) => DropdownMenuEntry<Category>(
                    value: category,
                    label: getCategoryName(category.name, l10n),
                    leadingIcon: Icon(getIconData(category.icon)),
                  ),
                )
                .toList(),
            selected: state.filterCategory,
            leadingIcon: state.filterCategory != null
                ? getIconData(state.filterCategory!.icon)
                : null,
            onSelected: context.read<MovementsHomeCubit>().changeFilterCategory,
          ),
        ],
      ),
    );
  }
}
