import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:saver_expense_manager/app/app.dart';
import 'package:saver_expense_manager/l10n/l10n.dart';

class ProfileView extends StatelessWidget {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.profileTitle),
        centerTitle: true,
        actions: const [ChangeLanguageButton()],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: ProfileScreen(
            auth: FirebaseAuth.instance,
            avatar: CircleAvatar(
              radius: 80,
              child: user?.photoURL == null
                  ? const Icon(Icons.person, size: 70)
                  : ClipRRect(
                      borderRadius: BorderRadius.circular(80),
                      child: Image.network(highResPicture(user!.photoURL)!),
                    ),
            ),
            actions: [
              SignedOutAction((context) async {
                final shouldLogout = await showDialog<bool>(
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      title: Text(l10n.confirmLogoutTitle),
                      content: Text(l10n.confirmLogoutMessage),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(false),
                          child: Text(l10n.logoutCancel),
                        ),
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(true),
                          child: Text(l10n.logoutConfirm),
                        ),
                      ],
                    );
                  },
                );

                if (shouldLogout ?? false) {
                  // ignore: use_build_context_synchronously // Context is still valid here
                  context.goNamed('login');
                }
              }),
              DisplayNameChangedAction((context, oldName, newName) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(l10n.displayNameChanged(newName))),
                );
              }),
            ],
            showUnlinkConfirmationDialog: true,
            showDeleteConfirmationDialog: true,
          ),
        ),
      ),
    );
  }
}
