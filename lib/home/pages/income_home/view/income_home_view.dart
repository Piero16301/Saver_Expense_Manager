import 'package:flutter/foundation.dart' show kIsWeb;
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
        spacing: 8,
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
      children: [
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TotalSpentChart(data: data),
            ConstrainedBox(
              constraints: const BoxConstraints(
                maxHeight: AppVariables.mobileChartMaxHeight,
              ),
              child: DoughnutCircularChart(
                data: data,
                selectedIndex: selectedIndex,
                onPointTap: (p0) => context
                    .read<IncomeHomeCubit>()
                    .changeExplodeIndex(p0.pointIndex),
              ),
            ),
          ],
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
              spacing: 16,
              children: [
                TotalSpentChart(data: data),
                ConstrainedBox(
                  constraints: const BoxConstraints(
                    maxHeight: AppVariables.webChartMaxHeight,
                  ),
                  child: DoughnutCircularChart(
                    data: data,
                    selectedIndex: selectedIndex,
                    onPointTap: (p0) => context
                        .read<IncomeHomeCubit>()
                        .changeExplodeIndex(p0.pointIndex),
                  ),
                ),
              ],
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
