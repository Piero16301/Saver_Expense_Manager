import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:saver_expense_manager/app/app.dart';
import 'package:saver_expense_manager/l10n/l10n.dart';

class LoginView extends StatelessWidget {
  const LoginView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          SignInScreen(
            actions: [
              AuthStateChangeAction(
                (context, state) {
                  final user = switch (state) {
                    SignedIn(user: final user) => user,
                    UserCreated(credential: final cred) => cred.user,
                    _ => null,
                  };

                  debugPrint('User: $user');

                  switch (user) {
                    case User(emailVerified: true):
                      context.goNamed('home');
                    case User(emailVerified: false, email: final String _):
                      context.goNamed('email-verification');
                  }
                },
              ),
            ],
          ),
          const ChangeThemeButton(),
          const ChangeLanguageLogin(),
        ],
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
        bottom: 20,
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
