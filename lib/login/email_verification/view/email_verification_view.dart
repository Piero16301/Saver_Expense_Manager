import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:saver_expense_manager/app/app.dart';
import 'package:saver_expense_manager/l10n/l10n.dart';

class EmailVerificationView extends StatelessWidget {
  const EmailVerificationView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          EmailVerificationScreen(
            actions: [
              EmailVerifiedAction(() {
                context.goNamed('home');
              }),
              AuthCancelledAction((context) {
                FirebaseUIAuth.signOut(context: context);
                context.goNamed('login');
              }),
            ],
          ),
          const ChangeThemeLogin(),
          const ChangeLanguageLogin(),
        ],
      ),
    );
  }
}

class ChangeThemeLogin extends StatelessWidget {
  const ChangeThemeLogin({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AppCubit, AppState>(
      builder: (context, state) => Positioned(
        top: 60,
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

class ChangeLanguageLogin extends StatelessWidget {
  const ChangeLanguageLogin({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final languages = {
      'en': l10n.english,
      'es': l10n.spanish,
      'it': l10n.italian,
    };
    return BlocBuilder<AppCubit, AppState>(
      builder: (context, state) => Positioned(
        top: 60,
        left: 20,
        child: TextButton(
          onPressed: () => changeLanguageDialog(context),
          child: Text(
            languages[state.language]!,
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
