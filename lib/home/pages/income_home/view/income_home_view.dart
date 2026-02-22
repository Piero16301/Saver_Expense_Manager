import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:saver_expense_manager/app/app.dart';
import 'package:saver_expense_manager/home/home.dart';
import 'package:saver_expense_manager/l10n/l10n.dart';

class IncomeHomeView extends StatelessWidget {
  const IncomeHomeView({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = getIt<AuthenticationService>();
    final user = auth.currentUser;
    final l10n = AppLocalizations.of(context);
    final databaseService = getIt<DatabaseService>();

    return BlocBuilder<IncomeHomeCubit, IncomeHomeState>(
      builder: (context, state) => Column(
        children: [
          MonthSelector(
            monthSelected: state.monthSelected!,
            onBack: () => context.read<IncomeHomeCubit>().previousMonth(),
            onForward: () => context.read<IncomeHomeCubit>().nextMonth(),
            onChangeMonth: context.read<IncomeHomeCubit>().changeMonth,
          ),
          StreamBuilder<List<Movement>>(
            stream: databaseService.getMonthMovementsStream(
              userId: user!.uid,
              monthSelected: state.monthSelected!,
              type: CategoryType.income,
            ),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Expanded(
                  child: Center(child: CircularProgressIndicator()),
                );
              }

              if (snapshot.data!.isEmpty) {
                return Expanded(child: Center(child: Text(l10n.homeNoIncomes)));
              }

              final data = AppFunctions.buildChartData(
                movements: snapshot.data!,
              );

              return Expanded(
                child: Column(
                  children: [
                    TotalSpentChart(data: data),
                    DoughnutCircularChart(
                      data: data,
                      selectedIndex: state.selectedIndex,
                      onPointTap: (p0) => context
                          .read<IncomeHomeCubit>()
                          .changeExplodeIndex(p0.pointIndex),
                    ),
                    MovementsListChart(
                      expenseType: CategoryType.income,
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
