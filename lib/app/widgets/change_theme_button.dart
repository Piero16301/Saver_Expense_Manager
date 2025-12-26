import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:saver_expense_manager/app/app.dart';

class ChangeThemeButton extends StatelessWidget {
  const ChangeThemeButton({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AppCubit, AppState>(
      builder: (context, state) => IconButton(
        onPressed: () => context.read<AppCubit>().changeTheme(
              theme: (state.theme == 'LIGHT') ? 'DARK' : 'LIGHT',
            ),
        alignment: Alignment.center,
        icon: HugeIcon(
          icon: (state.theme == 'DARK')
              ? HugeIcons.strokeRoundedSun03
              : HugeIcons.strokeRoundedMoon02,
          size: 25,
        ),
      ),
    );
  }
}
