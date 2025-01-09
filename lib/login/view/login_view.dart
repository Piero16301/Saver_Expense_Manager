import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:saver_expense_manager/app/app.dart';

class LoginView extends StatelessWidget {
  const LoginView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(
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
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ChangeLanguageButton(),
                  ChangeThemeButton(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
