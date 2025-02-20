import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:saver_expense_manager/app/app.dart';
import 'package:saver_expense_manager/home/category/category.dart';
import 'package:saver_expense_manager/l10n/l10n.dart';
import 'package:user_api/user_api.dart';

class CategoryView extends StatelessWidget {
  const CategoryView({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return BlocBuilder<CategoryCubit, CategoryState>(
      builder: (context, state) => Scaffold(
        appBar: AppBar(
          title: Text(
            state.category.type == CategoryType.expense
                ? l10n.categoryExpenseTitle
                : l10n.categoryIncomeTitle,
          ),
          centerTitle: true,
          notificationPredicate: (notification) => false,
        ),
        body: Padding(
          padding:
              const EdgeInsets.only(right: 30, left: 30, bottom: 30, top: 20),
          child: Column(
            spacing: 10,
            children: [
              CategoryIconAndName(category: state.category),
              CategoryTabBar(category: state.category),
            ],
          ),
        ),
      ),
    );
  }
}

class CategoryIconAndName extends StatelessWidget {
  const CategoryIconAndName({
    required this.category,
    super.key,
  });

  final Category category;

  @override
  Widget build(BuildContext context) {
    final category = context.select<CategoryCubit, Category>(
      (cubit) => cubit.state.category,
    );
    final l10n = context.l10n;

    return Center(
      child: Column(
        spacing: 10,
        children: [
          CircleAvatar(
            radius: 60,
            backgroundColor:
                HexColor.fromHex(category.color).withValues(alpha: 0.3),
            child: Icon(
              getCategoryIcon(category.icon),
              size: 70,
              color: HexColor.fromHex(category.color),
            ),
          ),
          Text(
            getCategoryName(category.name, l10n).toUpperCase(),
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}

class CategoryTabBar extends StatefulWidget {
  const CategoryTabBar({
    required this.category,
    super.key,
  });

  final Category category;

  @override
  State<CategoryTabBar> createState() => _CategoryTabBarState();
}

class _CategoryTabBarState extends State<CategoryTabBar>
    with TickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    _tabController = TabController(length: 2, vsync: this);
    super.initState();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Expanded(
      child: Column(
        children: [
          TabBar(
            controller: _tabController,
            labelStyle: const TextStyle(fontWeight: FontWeight.bold),
            tabs: [
              Tab(
                text: l10n.categoryTabTrend,
                icon: const Icon(Icons.trending_up),
              ),
              Tab(
                text: l10n.categoryTabMovements,
                icon: const Icon(Icons.list),
              ),
            ],
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: const [
                TabTrendCategory(),
                TabMovementsCategory(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class TabTrendCategory extends StatefulWidget {
  const TabTrendCategory({super.key});

  @override
  State<TabTrendCategory> createState() => _TabTrendCategoryState();
}

class _TabTrendCategoryState extends State<TabTrendCategory> {
  DateTime endMonth = DateTime.now();
  DateTime startMonth = DateTime(DateTime.now().year - 1, DateTime.now().month);

  @override
  Widget build(BuildContext context) {
    final category = context
        .select<CategoryCubit, Category>((cubit) => cubit.state.category);
    final locale =
        context.select<AppCubit, Locale>((cubit) => cubit.state.locale!);
    final user = FirebaseAuth.instance.currentUser;
    final l10n = context.l10n;

    return Column(
      children: [
        const SizedBox(height: 20),
        MonthRangeSelector(
          startMonth: startMonth,
          endMonth: endMonth,
          onChangeStartMonth: (date) {
            if (date != null) {
              setState(() {
                startMonth = date;
              });
            }
          },
          onChangeEndMonth: (date) {
            if (date != null) {
              setState(() {
                endMonth = date;
              });
            }
          },
        ),
        const SizedBox(height: 20),
        StreamBuilder<QuerySnapshot>(
          stream: getTrendChart(
            userId: user!.uid,
            startMonth: startMonth,
            endMonth: endMonth,
            category: category,
          ),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Expanded(
                child: Center(child: CircularProgressIndicator()),
              );
            }

            if (snapshot.data!.docs.isEmpty) {
              return Expanded(
                child: Center(child: Text(l10n.categoryNoTrendData)),
              );
            }

            final data = buildTrendData(
              docs: snapshot.data!.docs
                  as List<QueryDocumentSnapshot<Map<String, dynamic>>>,
              startMonth: startMonth,
              endMonth: endMonth,
              locale: locale,
            );

            return LinearChart(category: category, data: data);
          },
        ),
      ],
    );
  }
}

class TabMovementsCategory extends StatefulWidget {
  const TabMovementsCategory({super.key});

  @override
  State<TabMovementsCategory> createState() => _TabMovementsCategoryState();
}

class _TabMovementsCategoryState extends State<TabMovementsCategory> {
  DateTime monthSelected = DateTime.now();

  @override
  Widget build(BuildContext context) {
    final category = context
        .select<CategoryCubit, Category>((cubit) => cubit.state.category);
    final user = FirebaseAuth.instance.currentUser;
    final l10n = context.l10n;

    return Column(
      children: [
        const SizedBox(height: 20),
        MonthSelector(
          monthSelected: monthSelected,
          onBack: () {
            if (monthSelected.month == 1) {
              setState(() {
                monthSelected = DateTime(
                  monthSelected.year - 1,
                  12,
                );
              });
            } else {
              setState(() {
                monthSelected = DateTime(
                  monthSelected.year,
                  monthSelected.month - 1,
                );
              });
            }
          },
          onForward: () {
            if (monthSelected.month == 12) {
              setState(() {
                monthSelected = DateTime(monthSelected.year + 1);
              });
            } else {
              setState(() {
                monthSelected = DateTime(
                  monthSelected.year,
                  monthSelected.month + 1,
                );
              });
            }
          },
          onChangeMonth: (month) => setState(() {
            if (month != null) {
              monthSelected = DateTime(month.year, month.month);
            }
          }),
        ),
        const SizedBox(height: 10),
        StreamBuilder<QuerySnapshot>(
          stream: getCategoryMovements(
            userId: user!.uid,
            monthSelected: monthSelected,
            category: category,
          ),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Expanded(
                child: Center(child: CircularProgressIndicator()),
              );
            }

            if (snapshot.data!.docs.isEmpty) {
              return Expanded(
                child: Center(child: Text(l10n.categoryNoMovements)),
              );
            }

            final movements = snapshot.data!.docs
                .map(
                  (e) => Movement.fromJson(e.data()! as Map<String, dynamic>),
                )
                .toList();

            return MovementsList(movements: movements);
          },
        ),
      ],
    );
  }
}
