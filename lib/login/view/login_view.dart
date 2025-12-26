import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:saver_expense_manager/app/app.dart';
import 'package:saver_expense_manager/home/home.dart';
import 'package:saver_expense_manager/login/email_verification/email_verification.dart';

class LoginView extends StatelessWidget {
  const LoginView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            SignInScreen(
              showPasswordVisibilityToggle: true,
              styles: const {
                EmailFormStyle(
                  signInButtonVariant: ButtonVariant.filled,
                  inputDecorationTheme: InputDecorationTheme(
                    border: OutlineInputBorder(),
                  ),
                ),
              },
              actions: [
                AuthStateChangeAction((context, state) {
                  final user = switch (state) {
                    SignedIn(user: final user) => user,
                    UserCreated(credential: final cred) => cred.user,
                    _ => null,
                  };

                  debugPrint('User: $user');

                  if (user != null) {
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      switch (user) {
                        case User(emailVerified: true):
                          if (context.mounted) {
                            context.goNamed(HomePage.pageName);
                          }
                        case User(emailVerified: false, email: final String _):
                          if (context.mounted) {
                            context.goNamed(EmailVerificationPage.pageName);
                          }
                        default:
                          if (context.mounted) {
                            context.goNamed(HomePage.pageName);
                          }
                      }
                    });
                  }
                }),
              ],
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [ChangeLanguageButton(), ChangeThemeButton()],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
