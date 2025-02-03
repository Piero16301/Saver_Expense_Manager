import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:saver_expense_manager/app/app.dart';
import 'package:saver_expense_manager/home/income_home/income_home.dart';
import 'package:saver_expense_manager/l10n/l10n.dart';

class IncomeHomeView extends StatelessWidget {
  const IncomeHomeView({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final l10n = context.l10n;

    return BlocBuilder<IncomeHomeCubit, IncomeHomeState>(
      builder: (context, state) => Column(
        children: [
          MonthSelector(
            monthSelected: state.monthSelected!,
            onBack: () => context.read<IncomeHomeCubit>().previousMonth(),
            onForward: () => context.read<IncomeHomeCubit>().nextMonth(),
            onChangeMonth: context.read<IncomeHomeCubit>().changeMonth,
          ),
          StreamBuilder<QuerySnapshot>(
            stream: getCategoriesChart(
              userId: user!.uid,
              monthSelected: state.monthSelected!,
              type: incomeType,
            ),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Expanded(
                  child: Center(child: CircularProgressIndicator()),
                );
              }

              if (snapshot.data!.docs.isEmpty) {
                return Expanded(
                  child: Center(child: Text(l10n.homeNoIncomes)),
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
                      data: data,
                      selectedIndex: state.selectedIndex,
                      onPointTap: (p0) => context
                          .read<IncomeHomeCubit>()
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
