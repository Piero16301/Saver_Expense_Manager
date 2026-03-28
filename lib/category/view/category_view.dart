import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:saver_expense_manager/app/app.dart';
import 'package:saver_expense_manager/category/category.dart';
import 'package:saver_expense_manager/l10n/l10n.dart';

class CategoryView extends StatelessWidget {
  const CategoryView({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isLandscape =
        MediaQuery.orientationOf(context) == Orientation.landscape;

    return BlocBuilder<CategoryCubit, CategoryState>(
      builder: (context, state) => Scaffold(
        appBar: AppBar(
          title: Text(
            l10n.categoryDetailsTitle,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          notificationPredicate: (notification) => false,
          leading: IconButton(
            onPressed: () => context.pop(),
            icon: const HugeIcon(
              icon: HugeIcons.strokeRoundedArrowLeft01,
              strokeWidth: 2,
            ),
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.only(
            right: 30,
            left: 30,
            bottom: 30,
            top: 10,
          ),
          child: isLandscape
              ? Row(
                  spacing: 10,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: CategoryIconAndName(category: state.category),
                    ),
                    CategoryTabBar(category: state.category),
                  ],
                )
              : Column(
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
  const CategoryIconAndName({required this.category, super.key});

  final Category category;

  @override
  Widget build(BuildContext context) {
    final category = context.select<CategoryCubit, Category>(
      (cubit) => cubit.state.category,
    );
    final l10n = AppLocalizations.of(context);

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      spacing: 10,
      children: [
        SizedBox.square(
          dimension: 200,
          child: AppFunctions.getCategoryAnimatedIcon(category, 90) ??
              HugeIcon(
                icon: AppFunctions.getCategoryIcon(category.icon),
                size: 70,
                color: HexColor.fromHex(category.color),
                strokeWidth: 2,
              ),
        ),
        Text(
          AppFunctions.getCategoryName(category.name, l10n).toUpperCase(),
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
      ],
    );
  }
}

class CategoryTabBar extends StatefulWidget {
  const CategoryTabBar({required this.category, super.key});

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
    final l10n = AppLocalizations.of(context);

    return Expanded(
      child: Column(
        children: [
          TabBar(
            controller: _tabController,
            tabs: [
              Tab(
                text: l10n.categoryTabTrend,
                icon: const HugeIcon(
                  icon: HugeIcons.strokeRoundedChartLineData01,
                ),
              ),
              Tab(
                text: l10n.categoryTabMovements,
                icon: const HugeIcon(
                  icon: HugeIcons.strokeRoundedListView,
                ),
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
  DateTime startMonth =
      AppFunctions.substracMonth(AppVariables.deafultMonthsTrend);

  @override
  Widget build(BuildContext context) {
    final category = context.select<CategoryCubit, Category>(
      (cubit) => cubit.state.category,
    );
    final language = context.select<AppCubit, Locale>(
      (cubit) => cubit.state.language,
    );
    final auth = getIt<AuthService>();
    final user = auth.currentUser;
    final l10n = AppLocalizations.of(context);
    final database = getIt<DatabaseService>();

    return Column(
      children: [
        const SizedBox(height: 20),
        ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: AppVariables.tabletMaxWidth,
          ),
          child: MonthRangeSelector(
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
        ),
        const SizedBox(height: 20),
        StreamBuilder<List<Movement>>(
          stream: database.getMovementsStream(
            userId: user!.uid,
            startDate: startMonth,
            endDate: endMonth,
            categoryId: category.id,
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
                child: Center(child: Text(l10n.categoryNoTrendData)),
              );
            }

            final data = AppFunctions.buildTrendData(
              movements: snapshot.data!,
              startMonth: startMonth,
              endMonth: endMonth,
              language: language.toString(),
            );

            return Expanded(
              child: LinearChart(
                titles: [AppFunctions.getCategoryName(category.name, l10n)],
                colors: [HexColor.fromHex(category.color)],
                data: [data],
              ),
            );
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
    final category = context.select<CategoryCubit, Category>(
      (cubit) => cubit.state.category,
    );

    return Column(
      children: [
        const SizedBox(height: 20),
        ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: AppVariables.tabletMaxWidth,
          ),
          child: MonthSelector(
            monthSelected: monthSelected,
            onBack: () {
              if (monthSelected.month == 1) {
                setState(() {
                  monthSelected = DateTime(monthSelected.year - 1, 12);
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
        ),
        const SizedBox(height: 10),
        MovementsList(filterCategory: category, monthSelected: monthSelected),
      ],
    );
  }
}
