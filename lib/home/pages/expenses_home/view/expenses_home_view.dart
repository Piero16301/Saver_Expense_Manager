import 'package:expressive_kit/expressive_kit.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_ui/material_ui.dart';
import 'package:saver_expense_manager/app/app.dart';
import 'package:saver_expense_manager/home/home.dart';
import 'package:saver_expense_manager/l10n/l10n.dart';

class ExpensesHomeView extends StatelessWidget {
  const ExpensesHomeView({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = getIt<AuthService>();
    final user = auth.currentUser;
    final l10n = AppLocalizations.of(context);
    final database = getIt<DatabaseService>();
    final isLandscape =
        MediaQuery.orientationOf(context) == Orientation.landscape;

    return BlocBuilder<ExpensesHomeCubit, ExpensesHomeState>(
      builder: (context, state) => Column(
        children: [
          const SizedBox(height: 12),
          StreamBuilder<List<Movement>>(
            stream: database.getMovementsStream(
              userId: user!.uid,
              startDate: DateTime(
                state.monthSelected!.year,
                state.monthSelected!.month,
              ),
              endDate: DateTime(
                state.monthSelected!.year,
                state.monthSelected!.month + 1,
              ),
              type: CategoryType.expense,
              orderByDate: true,
            ),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Expanded(
                  child: Center(
                    child: ExpressiveCircularProgressIndicator(
                      size: 40,
                      strokeWidth: 4,
                    ),
                  ),
                );
              }

              if (snapshot.data!.isEmpty) {
                return Expanded(
                  child: Center(child: Text(l10n.homeNoExpenses)),
                );
              }

              final data = AppFunctions.buildChartData(
                movements: snapshot.data!,
              )..sort((a, b) => b.value.compareTo(a.value));

              return Expanded(
                child: isLandscape
                    ? ExpensesHomeWebView(
                        data: data,
                        selectedIndex: state.selectedIndex,
                        monthSelected: state.monthSelected!,
                      )
                    : ExpensesHomeMobileView(
                        data: data,
                        selectedIndex: state.selectedIndex,
                        monthSelected: state.monthSelected!,
                      ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class ExpensesHomeMobileView extends StatelessWidget {
  const ExpensesHomeMobileView({
    required this.data,
    required this.selectedIndex,
    required this.monthSelected,
    super.key,
  });

  final List<CategoryData> data;
  final int selectedIndex;
  final DateTime monthSelected;

  @override
  Widget build(BuildContext context) {
    return Column(
      spacing: 16,
      children: [
        CategorySummaryCard(
          data: data,
          selectedIndex: selectedIndex,
          onCategorySelected: (index) =>
              context.read<ExpensesHomeCubit>().changeExplodeIndex(index),
        ),
        MovementsListChart(
          expenseType: CategoryType.expense,
          monthSelected: monthSelected,
        ),
      ],
    );
  }
}

class ExpensesHomeWebView extends StatelessWidget {
  const ExpensesHomeWebView({
    required this.data,
    required this.selectedIndex,
    required this.monthSelected,
    super.key,
  });

  final List<CategoryData> data;
  final int selectedIndex;
  final DateTime monthSelected;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: 20,
      children: [
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: CategorySummaryCard(
              data: data,
              selectedIndex: selectedIndex,
              isExpanded: true,
              onCategorySelected: (index) =>
                  context.read<ExpensesHomeCubit>().changeExplodeIndex(index),
            ),
          ),
        ),
        MovementsListChart(
          expenseType: CategoryType.expense,
          monthSelected: monthSelected,
        ),
      ],
    );
  }
}
