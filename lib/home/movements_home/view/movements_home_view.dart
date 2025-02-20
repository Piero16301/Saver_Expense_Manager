import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:intl/intl.dart';
import 'package:saver_expense_manager/app/app.dart';
import 'package:saver_expense_manager/home/movements_home/movements_home.dart';
import 'package:saver_expense_manager/l10n/l10n.dart';
import 'package:user_api/user_api.dart';

class MovementsHomeView extends StatefulWidget {
  const MovementsHomeView({super.key});

  @override
  State<MovementsHomeView> createState() => _MovementsHomeViewState();
}

class _MovementsHomeViewState extends State<MovementsHomeView> {
  final PagingController<QueryDocumentSnapshot<Object?>?, Movement>
      pagingController = PagingController(firstPageKey: null);

  @override
  void initState() {
    pagingController.addPageRequestListener(_fetchPage);
    super.initState();
  }

  Future<void> _fetchPage(QueryDocumentSnapshot<Object?>? pageKey) async {
    try {
      final newItemsSnapshot =
          await context.read<MovementsHomeCubit>().getMovements(
                userId: FirebaseAuth.instance.currentUser!.uid,
                lastDocument: pageKey,
              );
      final isLastPage = newItemsSnapshot.docs.length < pageSize;
      if (isLastPage) {
        final newItems = newItemsSnapshot.docs
            .map((doc) => Movement.fromJson(doc.data()))
            .toList();
        pagingController.appendLastPage(newItems);
      } else {
        final nextPageKey = newItemsSnapshot.docs.last;
        final newItems = newItemsSnapshot.docs
            .map((doc) => Movement.fromJson(doc.data()))
            .toList();
        pagingController.appendPage(newItems, nextPageKey);
      }
    } catch (error) {
      pagingController.error = error;
    }
  }

  @override
  void dispose() {
    pagingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MovementsHomeCubit, MovementsHomeState>(
      builder: (context, state) => Padding(
        padding: const EdgeInsets.only(bottom: 20),
        child: Column(
          spacing: 20,
          children: [
            FilterMovementsHome(pagingController: pagingController),
            ListMovementsHome(pagingController: pagingController),
          ],
        ),
      ),
    );
  }
}

class FilterMovementsHome extends StatelessWidget {
  const FilterMovementsHome({
    required this.pagingController,
    super.key,
  });

  final PagingController<QueryDocumentSnapshot<Object?>?, Movement>
      pagingController;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final categories = context
        .select<AppCubit, List<Category>>((cubit) => cubit.state.categories)
      ..sort(
        (a, b) => getCategoryName(a.name, l10n)
            .compareTo(getCategoryName(b.name, l10n)),
      );

    return BlocBuilder<MovementsHomeCubit, MovementsHomeState>(
      builder: (context, state) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: AppDropdownField<CategoryType>(
                  label: l10n.movementType,
                  options: [CategoryType.expense, CategoryType.income]
                      .map(
                        (type) => DropdownMenuEntry<CategoryType>(
                          value: type,
                          label: getTypeName(type, l10n),
                          leadingIcon: Icon(getTypeIcon(type)),
                        ),
                      )
                      .toList(),
                  selected: state.filterType,
                  leadingIcon: state.filterType != null
                      ? getTypeIcon(state.filterType!)
                      : null,
                  onSelected: (type) {
                    context.read<MovementsHomeCubit>().changeFilterType(type);
                    pagingController.refresh();
                  },
                ),
              ),
              if (state.filterType != null) const SizedBox(width: 10),
              if (state.filterType != null)
                IconButton(
                  onPressed: () {
                    context.read<MovementsHomeCubit>().clearFilterType();
                    pagingController.refresh();
                  },
                  icon: const Icon(Icons.clear),
                ),
            ],
          ),
          if (state.filterType != null) const SizedBox(height: 20),
          if (state.filterType != null)
            Row(
              children: [
                Expanded(
                  child: AppDropdownField<Category>(
                    label: l10n.movementCategory,
                    options: categories
                        .where((c) => c.type == state.filterType)
                        .map(
                          (category) => DropdownMenuEntry<Category>(
                            value: category,
                            label: getCategoryName(category.name, l10n),
                            leadingIcon: Icon(getCategoryIcon(category.icon)),
                          ),
                        )
                        .toList(),
                    selected: state.filterCategory,
                    leadingIcon: state.filterCategory != null
                        ? getCategoryIcon(state.filterCategory!.icon)
                        : null,
                    onSelected: (category) {
                      context
                          .read<MovementsHomeCubit>()
                          .changeFilterCategory(category);
                      pagingController.refresh();
                    },
                  ),
                ),
                if (state.filterCategory != null) const SizedBox(width: 10),
                if (state.filterCategory != null)
                  IconButton(
                    onPressed: () {
                      context.read<MovementsHomeCubit>().clearFilterCategory();
                      pagingController.refresh();
                    },
                    icon: const Icon(Icons.clear),
                  ),
              ],
            ),
        ],
      ),
    );
  }
}

class ListMovementsHome extends StatelessWidget {
  const ListMovementsHome({
    required this.pagingController,
    super.key,
  });

  final PagingController<QueryDocumentSnapshot<Object?>?, Movement>
      pagingController;

  @override
  Widget build(BuildContext context) {
    final locale =
        context.select<AppCubit, Locale>((cubit) => cubit.state.locale!);
    final l10n = context.l10n;

    return Expanded(
      child: RefreshIndicator(
        onRefresh: () => Future.sync(pagingController.refresh),
        child: PagedListView<QueryDocumentSnapshot<Object?>?, Movement>(
          physics: const BouncingScrollPhysics(),
          pagingController: pagingController,
          builderDelegate: PagedChildBuilderDelegate<Movement>(
            animateTransitions: true,
            firstPageErrorIndicatorBuilder: (context) => Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(l10n.movementsError),
                  TextButton(
                    onPressed: pagingController.refresh,
                    child: Text(l10n.movementsRetry),
                  ),
                ],
              ),
            ),
            newPageErrorIndicatorBuilder: (context) => Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(l10n.movementsError),
                  TextButton(
                    onPressed: pagingController.retryLastFailedRequest,
                    child: Text(l10n.movementsRetry),
                  ),
                ],
              ),
            ),
            noItemsFoundIndicatorBuilder: (context) => Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(l10n.movementsNoData),
                ],
              ),
            ),
            itemBuilder: (context, item, index) => ListTile(
              onTap: () async {
                final result = await context.pushNamed<bool>(
                      'movement',
                      pathParameters: {
                        'type': item.category.type == CategoryType.income
                            ? incomeType
                            : expenseType,
                        'screenType': 'EDIT',
                      },
                      extra: item,
                    ) ??
                    false;

                if (result) {
                  pagingController.refresh();
                }
              },
              contentPadding: const EdgeInsets.only(left: 16, right: 16),
              title: Text(
                item.title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              subtitle: Text(
                DateFormat.yMMMMd(locale.languageCode).format(item.date),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              trailing: Container(
                width: 80,
                decoration: BoxDecoration(
                  color: (item.category.type == CategoryType.expense
                          ? Colors.red
                          : Colors.green)
                      .withValues(
                    alpha: 0.3,
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 5),
                  child: Text(
                    moneyFormat.format(item.price),
                    style: const TextStyle(fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
              leading: Icon(
                getCategoryIcon(item.category.icon),
                size: 30,
                color: HexColor.fromHex(item.category.color),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
