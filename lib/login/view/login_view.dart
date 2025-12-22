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
                            context.goNamed('home');
                          }
                        case User(emailVerified: false, email: final String _):
                          if (context.mounted) {
                            context.goNamed('email-verification');
                          }
                        default:
                          if (context.mounted) {
                            context.goNamed('home');
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
