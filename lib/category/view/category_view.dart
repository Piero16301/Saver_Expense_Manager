import 'package:expressive_kit/expressive_kit.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:material_ui/material_ui.dart';
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
        appBar: ExpressiveTopAppBar(
          centerTitle: false,
          leading: Padding(
            padding: const EdgeInsets.all(8),
            child: ExpressiveIconButton.circle(
              icon: const HugeIcon(
                icon: HugeIcons.strokeRoundedArrowLeft01,
                strokeWidth: 2,
              ),
              onPressed: () => context.pop(),
            ),
          ),
          title: Text(
            AppFunctions.getCategoryName(state.category.name, l10n),
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
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
                      child: CategoryIcon(category: state.category),
                    ),
                    CategoryTabBar(category: state.category),
                  ],
                )
              : Column(
                  spacing: 10,
                  children: [
                    CategoryIcon(category: state.category),
                    CategoryTabBar(category: state.category),
                  ],
                ),
        ),
      ),
    );
  }
}

class CategoryIcon extends StatelessWidget {
  const CategoryIcon({required this.category, super.key});

  final Category category;

  @override
  Widget build(BuildContext context) {
    final category = context.select<CategoryCubit, Category>(
      (cubit) => cubit.state.category,
    );
    final categoryColor = HexColor.fromHex(category.color);

    return SizedBox(
      height: 150,
      width: 150,
      child: Center(
        child:
            AppFunctions.getCategoryAnimatedIcon(category, 150) ??
            HugeIcon(
              icon: AppFunctions.getCategoryIcon(category.icon),
              size: 70,
              color: categoryColor,
              strokeWidth: 2,
            ),
      ),
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
          ListenableBuilder(
            listenable: _tabController,
            builder: (context, _) => ExpressiveButtonGroup<int>(
              selectedValue: _tabController.index,
              onSelected: _tabController.animateTo,
              items: [
                ExpressiveButtonGroupItem(
                  value: 0,
                  label: l10n.categoryTabTrend,
                  icon: const HugeIcon(
                    icon: HugeIcons.strokeRoundedChartLineData01,
                    size: 18,
                  ),
                ),
                ExpressiveButtonGroupItem(
                  value: 1,
                  label: l10n.categoryTabMovements,
                  icon: const HugeIcon(
                    icon: HugeIcons.strokeRoundedListView,
                    size: 18,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: const [TabTrendCategory(), TabMovementsCategory()],
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
  DateTime startMonth = AppFunctions.substracMonth(
    AppVariables.deafultMonthsTrend,
  );

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
        const SizedBox(height: 10),
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
                child: Center(
                  child: ExpressiveCircularProgressIndicator(
                    size: 40,
                    strokeWidth: 4,
                  ),
                ),
              );
            }

            if (snapshot.data!.isEmpty) {
              return Expanded(
                child: ExpressiveCard(
                  margin: EdgeInsets.zero,
                  padding: const EdgeInsets.all(24),
                  child: Center(child: Text(l10n.categoryNoTrendData)),
                ),
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
        const SizedBox(height: 20),
        MovementsList(filterCategory: category, monthSelected: monthSelected),
      ],
    );
  }
}
