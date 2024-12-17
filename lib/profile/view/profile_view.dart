import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:saver_expense_manager/l10n/l10n.dart';

class ProfileView extends StatelessWidget {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.profileTitle),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: ProfileScreen(
            auth: FirebaseAuth.instance,
            actions: [
              SignedOutAction((context) {
                context.goNamed('login');
              }),
              DisplayNameChangedAction((context, oldName, newName) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(l10n.displayNameChanged(newName)),
                  ),
                );
              }),
            ],
            showUnlinkConfirmationDialog: true,
          ),
        ),
      ),
    );
  }
}
