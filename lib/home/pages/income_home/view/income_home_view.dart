import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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
        spacing: 16,
        children: [
          ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: AppVariables.tabletMaxWidth,
            ),
            child: MonthSelector(
              monthSelected: state.monthSelected!,
              onBack: () => context.read<IncomeHomeCubit>().previousMonth(),
              onForward: () => context.read<IncomeHomeCubit>().nextMonth(),
              onChangeMonth: context.read<IncomeHomeCubit>().changeMonth,
            ),
          ),
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
                  child: Center(child: CircularProgressIndicator()),
                );
              }

              if (snapshot.data!.isEmpty) {
                return Expanded(child: Center(child: Text(l10n.homeNoIncomes)));
              }

              final data = AppFunctions.buildChartData(
                movements: snapshot.data!,
              );

              final Widget doughnutChart = DoughnutCircularChart(
                data: data,
                selectedIndex: state.selectedIndex,
                onPointTap: (p0) => context
                    .read<IncomeHomeCubit>()
                    .changeExplodeIndex(p0.pointIndex),
              );

              final list = MovementsListChart(
                expenseType: CategoryType.income,
                monthSelected: state.monthSelected!,
              );

              return Expanded(
                child: isLandscape
                    ? Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        spacing: 16,
                        children: [
                          Expanded(
                            child: SingleChildScrollView(
                              physics: const BouncingScrollPhysics(),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                spacing: isLandscape ? 16 : 0,
                                children: [
                                  TotalSpentChart(data: data),
                                  ConstrainedBox(
                                    constraints: const BoxConstraints(
                                      maxHeight: AppVariables.tabletMaxHeight,
                                    ),
                                    child: doughnutChart,
                                  ),
                                ],
                              ),
                            ),
                          ),
                          list,
                        ],
                      )
                    : Column(
                        children: [
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            spacing: isLandscape ? 16 : 0,
                            children: [
                              TotalSpentChart(data: data),
                              doughnutChart,
                            ],
                          ),
                          list,
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
