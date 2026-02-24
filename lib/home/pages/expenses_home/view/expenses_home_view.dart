import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:saver_expense_manager/app/app.dart';
import 'package:saver_expense_manager/home/home.dart';
import 'package:saver_expense_manager/l10n/l10n.dart';

class ExpensesHomeView extends StatelessWidget {
  const ExpensesHomeView({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = getIt<AuthenticationService>();
    final user = auth.currentUser;
    final l10n = AppLocalizations.of(context);
    final database = getIt<DatabaseService>();

    return BlocBuilder<ExpensesHomeCubit, ExpensesHomeState>(
      builder: (context, state) => Column(
        children: [
          MonthSelector(
            monthSelected: state.monthSelected!,
            onBack: () => context.read<ExpensesHomeCubit>().previousMonth(),
            onForward: () => context.read<ExpensesHomeCubit>().nextMonth(),
            onChangeMonth: context.read<ExpensesHomeCubit>().changeMonth,
          ),
          StreamBuilder<List<Movement>>(
            stream: database.getMonthMovementsStream(
              userId: user!.uid,
              monthSelected: state.monthSelected!,
              type: CategoryType.expense,
            ),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Expanded(
                  child: Center(child: CircularProgressIndicator()),
                );
              }

              if (snapshot.data!.isEmpty) {
                return Expanded(
                  child: Center(child: Text(l10n.homeNoExpenses)),
                );
              }

              final data = AppFunctions.buildChartData(
                movements: snapshot.data!,
              );

              return Expanded(
                child: Column(
                  children: [
                    TotalSpentChart(data: data),
                    DoughnutCircularChart(
                      data: data..sort((a, b) => b.value.compareTo(a.value)),
                      selectedIndex: state.selectedIndex,
                      onPointTap: (p0) => context
                          .read<ExpensesHomeCubit>()
                          .changeExplodeIndex(p0.pointIndex),
                    ),
                    MovementsListChart(
                      expenseType: CategoryType.expense,
                      monthSelected: state.monthSelected!,
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
