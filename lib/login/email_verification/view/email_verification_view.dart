import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class EmailVerificationView extends StatefulWidget {
  const EmailVerificationView({super.key});

  @override
  State<EmailVerificationView> createState() => _EmailVerificationViewState();
}

class _EmailVerificationViewState extends State<EmailVerificationView> {
  @override
  void initState() {
    super.initState();
    // Verificar si el usuario ya está verificado al cargar la pantalla
    _checkEmailVerification();
  }

  void _checkEmailVerification() {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null && user.emailVerified && mounted) {
      // Si el email ya está verificado, navegar directamente a home
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          context.goNamed('home');
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          EmailVerificationScreen(
            actions: [
              EmailVerifiedAction(() {
                if (mounted) {
                  context.goNamed('home');
                }
              }),
              AuthCancelledAction((context) {
                unawaited(FirebaseUIAuth.signOut(context: context));
                if (mounted) {
                  context.goNamed('login');
                }
              }),
            ],
          ),
        ],
      ),
    );
  }
}
