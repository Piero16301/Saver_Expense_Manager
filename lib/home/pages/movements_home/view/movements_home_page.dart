import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:saver_expense_manager/app/app.dart';
import 'package:saver_expense_manager/home/home.dart';
import 'package:saver_expense_manager/l10n/l10n.dart';

class MovementsHomePage extends StatelessWidget {
  const MovementsHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance
          .collection(AppVariables.categoriesCollection)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasError) {
          return Scaffold(
            body: Center(
              child: Text(
                l10n.errorLoadingCategories,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
          );
        }

        if (snapshot.data!.docs.isEmpty) {
          return Scaffold(
            body: Center(
              child: Text(
                l10n.noCategoriesFound,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
          );
        }

        final categories = snapshot.data!.docs
            .map((category) => Category.fromJson(category.data()))
            .toList();

        return BlocProvider(
          create: (context) => MovementsHomeCubit(),
          child: MovementsHomeView(categories: categories),
        );
      },
    );
  }
}
