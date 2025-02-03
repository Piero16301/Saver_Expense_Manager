import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:saver_expense_manager/app/app.dart';
import 'package:saver_expense_manager/home/expenses_home/expenses_home.dart';
import 'package:saver_expense_manager/l10n/l10n.dart';
import 'package:user_api/user_api.dart';

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
            stream: FirebaseFirestore.instance
                .collection(movementsCollection)
                .where('user', isEqualTo: user!.uid)
                .where('category.type', isEqualTo: expenseType)
                .where(
                  'date',
                  isGreaterThanOrEqualTo: Timestamp.fromDate(
                    DateTime(
                      state.monthSelected!.year,
                      state.monthSelected!.month,
                    ),
                  ),
                )
                .where(
                  'date',
                  isLessThan: Timestamp.fromDate(
                    DateTime(
                      state.monthSelected!.month == 12
                          ? state.monthSelected!.year + 1
                          : state.monthSelected!.year,
                      state.monthSelected!.month == 12
                          ? 1
                          : state.monthSelected!.month + 1,
                    ),
                  ),
                )
                .snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Expanded(
                  child: Center(child: CircularProgressIndicator()),
                );
              }

              if (snapshot.data!.docs.isEmpty) {
                return Expanded(
                  child: Center(child: Text(l10n.homeNoMovements)),
                );
              }

              final movements = snapshot.data!.docs
                  .map(
                    (e) => Movement.fromJson(e.data()! as Map<String, dynamic>),
                  )
                  .toList();
              final data = <ChartData>[];
              final categories = <Category>[];
              for (final element in movements) {
                if (!categories.contains(element.category)) {
                  categories.add(element.category);
                }
              }
              for (final category in categories) {
                final movementsByCategory = movements
                    .where((element) => element.category == category)
                    .toList();
                final total = movementsByCategory.fold<double>(
                  0,
                  (previousValue, element) => previousValue + element.price,
                );
                data.add(ChartData(category: category, value: total));
              }

              return Expanded(
                child: Column(
                  children: [
                    TotalSpentChart(data: data),
                    DoughnutCircularChart(
                      data: data,
                      explodeIndex: state.explodeIndex,
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
