import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:saver_expense_manager/app/app.dart';

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: Image.asset('assets/images/logo_no_bg.png', height: 40),
        centerTitle: true,
        leading: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            ChangeThemeButton(),
            ChangeLanguageButton(),
          ],
        ),
        leadingWidth: 100,
        actions: [
          IconButton(
            icon: user?.photoURL == null
                ? const Icon(Icons.person)
                : ClipRRect(
                    borderRadius: BorderRadius.circular(50),
                    child: Image.network(highResPicture(user!.photoURL)),
                  ),
            onPressed: () => context.pushNamed('profile'),
          ),
        ],
      ),
      body: const SafeArea(
        child: Padding(
          padding: EdgeInsets.all(10),
          child: Column(
            children: [
              Placeholder(),
            ],
          ),
        ),
      ),
    );
  }
}
