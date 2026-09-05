import 'package:flutter/foundation.dart' show kIsWeb;
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
        spacing: 8,
        children: [
          ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: AppVariables.tabletMaxWidth,
            ),
            child: MonthSelector(
              monthSelected: state.monthSelected!,
              onBack: () => context.read<ExpensesHomeCubit>().previousMonth(),
              onForward: () => context.read<ExpensesHomeCubit>().nextMonth(),
              onChangeMonth: context.read<ExpensesHomeCubit>().changeMonth,
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
              type: CategoryType.expense,
              orderByDate: true,
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

              final Widget doughnutChart = DoughnutCircularChart(
                data: data..sort((a, b) => b.value.compareTo(a.value)),
                selectedIndex: state.selectedIndex,
                onPointTap: (p0) => context
                    .read<ExpensesHomeCubit>()
                    .changeExplodeIndex(p0.pointIndex),
              );

              final list = MovementsListChart(
                expenseType: CategoryType.expense,
                monthSelected: state.monthSelected!,
              );

              return Expanded(
                child: isLandscape
                    ? Row(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        spacing: 16,
                        children: [
                          Expanded(
                            child: SingleChildScrollView(
                              physics: const AlwaysScrollableScrollPhysics(
                                parent: kIsWeb
                                    ? ClampingScrollPhysics()
                                    : BouncingScrollPhysics(),
                              ),
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
                              ConstrainedBox(
                                constraints: const BoxConstraints(
                                  maxHeight: AppVariables.tabletMaxHeight,
                                ),
                                child: doughnutChart,
                              ),
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
