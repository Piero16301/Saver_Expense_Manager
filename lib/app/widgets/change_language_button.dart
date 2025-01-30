import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:saver_expense_manager/app/app.dart';
import 'package:saver_expense_manager/l10n/l10n.dart';

class ChangeLanguageButton extends StatelessWidget {
  const ChangeLanguageButton({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final languages = {
      'en': l10n.englishFlag,
      'es': l10n.spanishFlag,
      'it': l10n.italianFlag,
    };
    return BlocBuilder<AppCubit, AppState>(
      builder: (context, state) => IconButton(
        onPressed: () => changeLanguageDialog(context),
        icon: SizedBox.square(
          dimension: 30,
          child: Text(
            languages[(state.locale ?? const Locale('en')).languageCode]!,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 20),
          ),
        ),
      ),
    );
  }

  void changeLanguageDialog(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (context) {
        final l10n = context.l10n;

        return SimpleDialog(
          title: Text(l10n.selectLanguage),
          children: AppLocalizations.supportedLocales.map((locale) {
            final languages = {
              'en': l10n.english,
              'es': l10n.spanish,
              'it': l10n.italian,
            };
            final language = languages[locale.languageCode]!;
            return SimpleDialogOption(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 25),
              onPressed: () {
                context.read<AppCubit>().changeLanguage(locale.languageCode);
                Navigator.pop(context);
              },
              child: Text(language),
            );
          }).toList(),
        );
      },
    );
  }
}
