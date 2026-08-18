import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:material_ui/material_ui.dart';
import 'package:saver_expense_manager/app/app.dart';
import 'package:saver_expense_manager/l10n/l10n.dart';

class AppChangeTheme extends StatelessWidget {
  const AppChangeTheme({this.padding, super.key});

  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return BlocBuilder<AppCubit, AppState>(
      builder: (context, state) => Padding(
        padding: padding ?? EdgeInsets.zero,
        child: PopupMenuButton<ThemeMode>(
          initialValue: state.theme,
          icon: HugeIcon(
            icon: state.theme == ThemeMode.light
                ? HugeIcons.strokeRoundedSun03
                : (state.theme == ThemeMode.dark
                      ? HugeIcons.strokeRoundedMoon02
                      : HugeIcons.strokeRoundedSmartPhone01),
            strokeWidth: 2,
          ),
          tooltip: l10n.selectTheme,
          constraints: const BoxConstraints(minWidth: 60, maxWidth: 60),
          onSelected: (value) =>
              context.read<AppCubit>().changeTheme(theme: value),
          itemBuilder: (context) {
            return ThemeMode.values.map((value) {
              return PopupMenuItem<ThemeMode>(
                value: value,
                padding: EdgeInsets.zero,
                child: Center(
                  child: HugeIcon(
                    icon: value == ThemeMode.light
                        ? HugeIcons.strokeRoundedSun03
                        : (value == ThemeMode.dark
                              ? HugeIcons.strokeRoundedMoon02
                              : HugeIcons.strokeRoundedSmartPhone01),
                    strokeWidth: 2,
                  ),
                ),
              );
            }).toList();
          },
        ),
      ),
    );
  }
}
