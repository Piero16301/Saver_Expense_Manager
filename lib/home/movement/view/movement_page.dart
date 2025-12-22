import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:saver_expense_manager/app/app.dart';
import 'package:saver_expense_manager/home/movement/movement.dart';
import 'package:saver_expense_manager/l10n/l10n.dart';
import 'package:user_api/user_api.dart';

class MovementPage extends StatelessWidget {
  const MovementPage({
    required this.movement,
    required this.type,
    required this.screenType,
    super.key,
  });

  final Movement movement;
  final CategoryType type;
  final MovementScreenType screenType;

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
            .where((element) => element.type == type)
            .toList()
          ..sort(
            (a, b) => AppFunctions.getCategoryName(
              a.name,
              l10n,
            ).compareTo(AppFunctions.getCategoryName(b.name, l10n)),
          );

        return BlocProvider(
          create: (_) => MovementCubit()..init(movement, categories),
          child: MovementView(type: type, screenType: screenType),
        );
      },
    );
  }
}
