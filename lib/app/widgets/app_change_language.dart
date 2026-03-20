import 'package:country_flags/country_flags.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:saver_expense_manager/app/app.dart';
import 'package:saver_expense_manager/l10n/l10n.dart';

class AppChangeLanguage extends StatelessWidget {
  const AppChangeLanguage({
    super.key,
    this.padding,
  });

  final EdgeInsets? padding;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    const languages = AppVariables.supportedLocales;

    return BlocBuilder<AppCubit, AppState>(
      builder: (context, state) => Padding(
        padding: padding ?? EdgeInsets.zero,
        child: PopupMenuButton<Locale>(
          initialValue: state.language,
          icon: CountryFlag.fromLanguageCode(
            state.language.languageCode,
            theme: const ImageTheme(
              width: 35,
              height: 25,
              shape: RoundedRectangle(4),
            ),
          ),
          tooltip: l10n.selectLanguage,
          constraints: const BoxConstraints(minWidth: 60, maxWidth: 60),
          onSelected: (value) =>
              context.read<AppCubit>().changeLanguage(language: value),
          itemBuilder: (context) {
            return languages.map((value) {
              return PopupMenuItem<Locale>(
                value: value,
                padding: EdgeInsets.zero,
                child: Center(
                  child: CountryFlag.fromLanguageCode(
                    value.languageCode,
                    theme: const ImageTheme(
                      width: 35,
                      height: 25,
                      shape: RoundedRectangle(4),
                    ),
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
