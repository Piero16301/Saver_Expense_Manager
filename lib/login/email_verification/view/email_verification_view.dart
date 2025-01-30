import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

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
        ],
      ),
    );
  }
}
