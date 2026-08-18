import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_ui/material_ui.dart';
import 'package:saver_expense_manager/app/app.dart';
import 'package:saver_expense_manager/home/pages/summary_home/summary_home.dart';
import 'package:saver_expense_manager/l10n/l10n.dart';

class SummaryHomePage extends StatelessWidget {
  const SummaryHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final database = getIt<DatabaseService>();

    return StreamBuilder<List<Category>>(
      stream: database.getCategoriesStream(),
      builder: (context, snapshot) {
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

        if (!snapshot.hasData) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
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
          create: (context) => SummaryHomeCubit(),
          child: SummaryHomeView(categories: categories),
        );
      },
    );
  }
}
