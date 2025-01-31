import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:saver_expense_manager/app/app.dart';

class ChangeThemeButton extends StatelessWidget {
  const ChangeThemeButton({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AppCubit, AppState>(
      builder: (context, state) => IconButton(
        onPressed: context.read<AppCubit>().toggleTheme,
        alignment: Alignment.center,
        icon: Icon(
          (state.darkTheme ?? false) ? Icons.wb_sunny : Icons.nightlight_round,
          size: 25,
        ),
      ),
    );
  }
}
