import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:saver_expense_manager/app/app.dart';

class AppChangeTheme extends StatelessWidget {
  const AppChangeTheme({
    this.padding,
    super.key,
  });

  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding ?? EdgeInsets.zero,
      child: IconButton(
        onPressed: () {
          final isDark =
              context.read<AppCubit>().state.theme == AppVariables.darkTheme;
          unawaited(
            context.read<AppCubit>().changeTheme(
                  theme:
                      isDark ? AppVariables.lightTheme : AppVariables.darkTheme,
                ),
          );
        },
        icon: BlocBuilder<AppCubit, AppState>(
          builder: (context, state) => HugeIcon(
            icon: state.theme == AppVariables.darkTheme
                ? HugeIcons.strokeRoundedSun01
                : HugeIcons.strokeRoundedMoon02,
            strokeWidth: 2,
          ),
        ),
      ),
    );
  }
}
