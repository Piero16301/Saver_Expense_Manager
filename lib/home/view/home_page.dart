import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:saver_expense_manager/app/app.dart';
import 'package:saver_expense_manager/home/home.dart';
import 'package:saver_expense_manager/l10n/l10n.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  static const String pageName = 'home';
  static const String pagePath = '/';

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final databaseService = getIt<DatabaseService>();

    return StreamBuilder<List<Category>>(
      stream: databaseService.getCategoriesStream().handleError((dynamic _) {}),
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

        if (snapshot.data!.isEmpty) {
          return Scaffold(
            body: Center(
              child: Text(
                l10n.noCategoriesFound,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
          );
        }

        final categories = snapshot.data!;

        return BlocProvider(
          create: (_) => HomeCubit(),
          child: HomeView(categories: categories),
        );
      },
    );
  }
}
