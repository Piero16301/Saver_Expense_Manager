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
            spacing: 20,
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
    final l10n = context.l10n;

    return Center(
      child: Column(
        spacing: 10,
        children: [
          CircleAvatar(
            radius: 50,
            child: Icon(
              getIconData(category.icon),
              size: 70,
              color: Theme.of(context).colorScheme.secondary,
            ),
          ),
          Text(
            getCategoryName(category.name, l10n).toUpperCase(),
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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
    return Column(
      children: [
        MonthRangeSelector(
          startMonth: startMonth,
          endMonth: endMonth,
        ),
      ],
    );
  }
}

class TabMovementsCategory extends StatelessWidget {
  const TabMovementsCategory({super.key});

  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}
