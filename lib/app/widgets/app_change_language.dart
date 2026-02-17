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
    final currentLocale = Localizations.localeOf(context).languageCode;
    final languages =
        AppLocalizations.supportedLocales.map((e) => e.languageCode).toList();

    return Padding(
      padding: padding ?? EdgeInsets.zero,
      child: PopupMenuButton<String>(
        initialValue: currentLocale,
        icon: Text(
          _getFlag(currentLocale, l10n),
          style: const TextStyle(fontSize: 22),
        ),
        tooltip: l10n.selectLanguage,
        constraints: const BoxConstraints(minWidth: 60, maxWidth: 60),
        onSelected: (newValue) =>
            context.read<AppCubit>().changeLanguage(language: newValue),
        itemBuilder: (context) {
          return languages.map((value) {
            return PopupMenuItem<String>(
              value: value,
              padding: EdgeInsets.zero,
              child: Center(
                child: Text(
                  _getFlag(value, l10n),
                  style: const TextStyle(fontSize: 22),
                ),
              ),
            );
          }).toList();
        },
      ),
    );
  }

  String _getFlag(String languageCode, AppLocalizations l10n) {
    switch (languageCode) {
      case 'en':
        return l10n.englishFlag;
      case 'es':
        return l10n.spanishFlag;
      case 'it':
        return l10n.italianFlag;
      default:
        return l10n.englishFlag;
    }
  }
}
