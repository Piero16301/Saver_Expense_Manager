import 'package:expressive_kit/expressive_kit.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_ui/material_ui.dart';
import 'package:saver_expense_manager/app/app.dart';
import 'package:saver_expense_manager/home/home.dart';
import 'package:saver_expense_manager/l10n/l10n.dart';

class IncomeHomeView extends StatelessWidget {
  const IncomeHomeView({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = getIt<AuthService>();
    final user = auth.currentUser;
    final l10n = AppLocalizations.of(context);
    final database = getIt<DatabaseService>();
    final isLandscape =
        MediaQuery.orientationOf(context) == Orientation.landscape;

    return BlocBuilder<IncomeHomeCubit, IncomeHomeState>(
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
              type: CategoryType.income,
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
                return Expanded(child: Center(child: Text(l10n.homeNoIncomes)));
              }

              final data = AppFunctions.buildChartData(
                movements: snapshot.data!,
              )..sort((a, b) => b.value.compareTo(a.value));

              return Expanded(
                child: isLandscape
                    ? IncomeHomeWebView(
                        data: data,
                        selectedIndex: state.selectedIndex,
                        monthSelected: state.monthSelected!,
                      )
                    : IncomeHomeMobileView(
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

class IncomeHomeMobileView extends StatelessWidget {
  const IncomeHomeMobileView({
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
              context.read<IncomeHomeCubit>().changeExplodeIndex(index),
        ),
        MovementsListChart(
          expenseType: CategoryType.income,
          monthSelected: monthSelected,
        ),
      ],
    );
  }
}

class IncomeHomeWebView extends StatelessWidget {
  const IncomeHomeWebView({
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
                  context.read<IncomeHomeCubit>().changeExplodeIndex(index),
            ),
          ),
        ),
        MovementsListChart(
          expenseType: CategoryType.income,
          monthSelected: monthSelected,
        ),
      ],
    );
  }
}
