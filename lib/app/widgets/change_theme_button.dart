import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:saver_expense_manager/app/app.dart';

class ChangeThemeButton extends StatelessWidget {
  const ChangeThemeButton({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AppCubit, AppState>(
      builder: (context, state) => Positioned(
        bottom: 20,
        right: 20,
        child: IconButton(
          onPressed: context.read<AppCubit>().changeTheme,
          icon: Icon(
            state.theme == 'light' ? Icons.nightlight_round : Icons.wb_sunny,
            size: 30,
          ),
        ),
      ),
    );
  }
}
