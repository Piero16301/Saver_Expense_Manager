import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:saver_expense_manager/app/app.dart';
import 'package:saver_expense_manager/home/expenses_home/expenses_home.dart';
import 'package:saver_expense_manager/l10n/l10n.dart';

class ExpensesHomeView extends StatelessWidget {
  const ExpensesHomeView({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final l10n = context.l10n;

    return BlocBuilder<ExpensesHomeCubit, ExpensesHomeState>(
      builder: (context, state) => Column(
        children: [
          MonthSelector(
            monthSelected: state.monthSelected!,
            onBack: () => context.read<ExpensesHomeCubit>().previousMonth(),
            onForward: () => context.read<ExpensesHomeCubit>().nextMonth(),
            onChangeMonth: context.read<ExpensesHomeCubit>().changeMonth,
          ),
          StreamBuilder<QuerySnapshot>(
            stream: getMonthMovements(
              userId: user!.uid,
              monthSelected: state.monthSelected!,
              type: expenseType,
            ),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Expanded(
                  child: Center(child: CircularProgressIndicator()),
                );
              }

              if (snapshot.data!.docs.isEmpty) {
                return Expanded(
                  child: Center(child: Text(l10n.homeNoExpenses)),
                );
              }

              final data = buildChartData(
                docs: snapshot.data!.docs
                    as List<QueryDocumentSnapshot<Map<String, dynamic>>>,
              );

              return Expanded(
                child: Column(
                  children: [
                    TotalSpentChart(data: data),
                    const SizedBox(height: 10),
                    DoughnutCircularChart(
                      data: data..sort((a, b) => b.value.compareTo(a.value)),
                      selectedIndex: state.selectedIndex,
                      onPointTap: (p0) => context
                          .read<ExpensesHomeCubit>()
                          .changeExplodeIndex(p0.pointIndex),
                    ),
                    CategoriesListChart(data: data),
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
