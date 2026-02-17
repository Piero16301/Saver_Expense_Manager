import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_ai/firebase_ai.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:intl/intl.dart';
import 'package:saver_expense_manager/app/app.dart';
import 'package:saver_expense_manager/l10n/l10n.dart';

class AppFunctions {
  static String highResPicture({
    String? url,
    ImageResolutionType resolution = ImageResolutionType.low,
  }) {
    if (url == null) return '';
    switch (resolution) {
      case ImageResolutionType.low:
        return url.replaceAll('s96-c', 's200-c');
      case ImageResolutionType.medium:
        return url.replaceAll('s96-c', 's400-c');
      case ImageResolutionType.high:
        return url.replaceAll('s96-c', 's600-c');
    }
  }

  static int getInitialTabIndex(String initialTab) {
    switch (initialTab) {
      case AppVariables.expensesTab:
        return 0;
      case AppVariables.movementsTab:
        return 1;
      case AppVariables.summaryTab:
        return 2;
      case AppVariables.incomesTab:
        return 3;
      default:
        return 0;
    }
  }

  static void showSnackBar(
    BuildContext context, {
    String? message,
    SnackBarType type = SnackBarType.info,
  }) {
    List<List<dynamic>> icon;
    switch (type) {
      case SnackBarType.success:
        icon = HugeIcons.strokeRoundedCheckmarkCircle02;
      case SnackBarType.error:
        icon = HugeIcons.strokeRoundedAlertCircle;
      case SnackBarType.warning:
        icon = HugeIcons.strokeRoundedAlert02;
      case SnackBarType.info:
        icon = HugeIcons.strokeRoundedInformationCircle;
    }

    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          spacing: 12,
          children: [
            HugeIcon(
              icon: icon,
              strokeWidth: 2,
              color: Colors.white,
            ),
            Expanded(
              child: Text(
                message ?? '',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
        closeIconColor: Colors.white,
        backgroundColor: type.isSuccess
            ? Colors.green
            : type.isError
                ? Colors.red
                : type.isWarning
                    ? Colors.orange
                    : Theme.of(context).colorScheme.primary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 5),
      ),
    );
  }

  static DateTime substracMonth(int month) {
    final now = DateTime.now();
    final targetDate = DateTime(now.year, now.month - (month - 1));
    return targetDate;
  }

  static Stream<QuerySnapshot<Object?>>? getMonthMovements({
    required String userId,
    required DateTime monthSelected,
    required CategoryType type,
  }) {
    return FirebaseFirestore.instance
        .collection(AppVariables.movementsCollection)
        .where('user', isEqualTo: userId)
        .where('category.type', isEqualTo: type.value)
        .where(
          'date',
          isGreaterThanOrEqualTo: Timestamp.fromDate(
            DateTime(monthSelected.year, monthSelected.month),
          ),
        )
        .where(
          'date',
          isLessThan: Timestamp.fromDate(
            DateTime(
              monthSelected.month == 12
                  ? monthSelected.year + 1
                  : monthSelected.year,
              monthSelected.month == 12 ? 1 : monthSelected.month + 1,
            ),
          ),
        )
        .snapshots();
  }

  static Stream<QuerySnapshot<Object?>>? getUserMovementsRange({
    required String userId,
    required DateTime startMonth,
    required DateTime endMonth,
  }) {
    return FirebaseFirestore.instance
        .collection(AppVariables.movementsCollection)
        .where('user', isEqualTo: userId)
        .where(
          'date',
          isGreaterThanOrEqualTo: Timestamp.fromDate(
            DateTime(startMonth.year, startMonth.month),
          ),
        )
        .where(
          'date',
          isLessThan: Timestamp.fromDate(
            DateTime(
              endMonth.month == 12 ? endMonth.year + 1 : endMonth.year,
              endMonth.month == 12 ? 1 : endMonth.month + 1,
            ),
          ),
        )
        .snapshots();
  }

  static (double, double, double, double) calculateIncomesAndExpenses({
    required List<Movement> movements,
    required DateTime endMonth,
  }) {
    final pastMonth = DateTime(endMonth.year, endMonth.month - 1);
    final currentMonth = DateTime(endMonth.year, endMonth.month);

    // Filtrar movimientos del mes pasado
    final pastMonthMovements = movements.where((movement) {
      return movement.date.year == pastMonth.year &&
          movement.date.month == pastMonth.month;
    }).toList();

    // Filtrar movimientos del presente mes
    final currentMonthMovements = movements.where((movement) {
      return movement.date.year == currentMonth.year &&
          movement.date.month == currentMonth.month;
    }).toList();

    // Calcular ingresos y gastos del mes pasado
    final pastMonthIncomes = pastMonthMovements
        .where((m) => m.category.type == CategoryType.income)
        .fold<double>(0, (s, m) => s + m.price);
    final pastMonthExpenses = pastMonthMovements
        .where((m) => m.category.type == CategoryType.expense)
        .fold<double>(0, (s, m) => s + m.price);

    // Calcular ingresos y gastos del presente mes
    final currentMonthIncomes = currentMonthMovements
        .where((m) => m.category.type == CategoryType.income)
        .fold<double>(0, (s, m) => s + m.price);
    final currentMonthExpenses = currentMonthMovements
        .where((m) => m.category.type == CategoryType.expense)
        .fold<double>(0, (s, m) => s + m.price);

    return (
      pastMonthIncomes,
      pastMonthExpenses,
      currentMonthIncomes,
      currentMonthExpenses,
    );
  }

  static Map<String, CategoryExpenseData> calculateCategoryAmounts({
    required List<Movement> movements,
    required CategoryType filterType,
  }) {
    final categoryTotals = <String, double>{};
    final categoryMap = <String, Category>{};

    for (final movement in movements) {
      if (movement.category.type == filterType) {
        final categoryId = movement.category.id;

        categoryMap[categoryId] = movement.category;
        categoryTotals[categoryId] =
            (categoryTotals[categoryId] ?? 0) + movement.price;
      }
    }

    final categoryExpenses = <String, CategoryExpenseData>{};
    for (final entry in categoryTotals.entries) {
      if (entry.value > 0) {
        categoryExpenses[entry.key] = CategoryExpenseData(
          category: categoryMap[entry.key]!,
          totalExpense: entry.value,
        );
      }
    }

    return categoryExpenses;
  }

  static Query<Map<String, dynamic>> getCategoryMovements({
    required String userId,
    required DateTime monthSelected,
    required Category category,
  }) {
    return FirebaseFirestore.instance
        .collection(AppVariables.movementsCollection)
        .where('user', isEqualTo: userId)
        .where('category.id', isEqualTo: category.id)
        .where(
          'date',
          isGreaterThanOrEqualTo: Timestamp.fromDate(
            DateTime(monthSelected.year, monthSelected.month),
          ),
        )
        .where(
          'date',
          isLessThan: Timestamp.fromDate(
            DateTime(
              monthSelected.month == 12
                  ? monthSelected.year + 1
                  : monthSelected.year,
              monthSelected.month == 12 ? 1 : monthSelected.month + 1,
            ),
          ),
        )
        .orderBy('date', descending: true);
  }

  static Query<Map<String, dynamic>> getExpenseTypeMovements({
    required String userId,
    required DateTime monthSelected,
    required CategoryType expenseType,
  }) {
    return FirebaseFirestore.instance
        .collection(AppVariables.movementsCollection)
        .where('user', isEqualTo: userId)
        .where('category.type', isEqualTo: expenseType.value)
        .where(
          'date',
          isGreaterThanOrEqualTo: Timestamp.fromDate(
            DateTime(monthSelected.year, monthSelected.month),
          ),
        )
        .where(
          'date',
          isLessThan: Timestamp.fromDate(
            DateTime(
              monthSelected.month == 12
                  ? monthSelected.year + 1
                  : monthSelected.year,
              monthSelected.month == 12 ? 1 : monthSelected.month + 1,
            ),
          ),
        )
        .orderBy('date', descending: true);
  }

  static Query<Map<String, dynamic>> getUserMovements({
    required String userId,
    required CategoryType? type,
    required Category? category,
  }) {
    var query = FirebaseFirestore.instance
        .collection(AppVariables.movementsCollection)
        .where('user', isEqualTo: userId);

    if (type != null) {
      query = query.where(
        'category.type',
        isEqualTo: type == CategoryType.expense
            ? CategoryType.expense.value
            : CategoryType.income.value,
      );
    }

    if (category != null) {
      query = query.where('category.id', isEqualTo: category.id);
    }

    return query.orderBy('date', descending: true);
  }

  static List<CategoryData> buildChartData({
    required List<QueryDocumentSnapshot<Map<String, dynamic>>> docs,
  }) {
    final movements = docs.map((e) => Movement.fromJson(e.data())).toList();
    final data = <CategoryData>[];
    final categories = <Category>[];
    for (final element in movements) {
      if (!categories.contains(element.category)) {
        categories.add(element.category);
      }
    }
    for (final category in categories) {
      final movementsByCategory =
          movements.where((element) => element.category == category).toList();
      final total = movementsByCategory.fold<double>(
        0,
        (previousValue, element) => previousValue + element.price,
      );
      data.add(CategoryData(category: category, value: total));
    }
    return data..sort((a, b) => b.value.compareTo(a.value));
  }

  static Stream<QuerySnapshot<Object?>>? getTrendChart({
    required String userId,
    required DateTime startMonth,
    required DateTime endMonth,
    required Category category,
  }) {
    return FirebaseFirestore.instance
        .collection(AppVariables.movementsCollection)
        .where('user', isEqualTo: userId)
        .where('category.id', isEqualTo: category.id)
        .where(
          'date',
          isGreaterThanOrEqualTo: Timestamp.fromDate(
            DateTime(startMonth.year, startMonth.month),
          ),
        )
        .where(
          'date',
          isLessThan: Timestamp.fromDate(
            DateTime(
              endMonth.month == 12 ? endMonth.year + 1 : endMonth.year,
              endMonth.month == 12 ? 1 : endMonth.month + 1,
            ),
          ),
        )
        .snapshots();
  }

  static List<LinearChartData> buildTrendData({
    required List<QueryDocumentSnapshot<Map<String, dynamic>>> docs,
    required DateTime startMonth,
    required DateTime endMonth,
    required String language,
  }) {
    final movements = docs.map((e) => Movement.fromJson(e.data())).toList();
    final data = <LinearChartData>[];
    for (var i = startMonth;
        i.isBefore(endMonth) || i.isAtSameMomentAs(endMonth);
        i = DateTime(
      i.month == 12 ? i.year + 1 : i.year,
      i.month == 12 ? 1 : i.month + 1,
    )) {
      final movementsByMonth = movements
          .where(
            (element) =>
                element.date.year == i.year && element.date.month == i.month,
          )
          .toList();
      final total = movementsByMonth.fold<double>(
        0,
        (previousValue, element) => previousValue + element.price,
      );
      data.add(
        LinearChartData(
          xValue: DateFormat('MMM', language).format(i),
          yValue: total,
        ),
      );
    }
    return data;
  }

  static List<List<LinearChartData>> buildResumeTrendData({
    required List<Movement> movements,
    required DateTime startMonth,
    required DateTime endMonth,
    required String language,
    required Map<ResumeItemType, bool> selResumeItems,
  }) {
    final data = <List<LinearChartData>>[];
    final incomeData = <LinearChartData>[];
    final expenseData = <LinearChartData>[];
    final balanceData = <LinearChartData>[];
    for (var i = startMonth;
        i.isBefore(endMonth) || i.isAtSameMomentAs(endMonth);
        i = DateTime(
      i.month == 12 ? i.year + 1 : i.year,
      i.month == 12 ? 1 : i.month + 1,
    )) {
      final movementsByMonth = movements
          .where(
            (element) =>
                element.date.year == i.year && element.date.month == i.month,
          )
          .toList();
      final totalIncome = movementsByMonth.fold<double>(
        0,
        (previousValue, element) => element.category.type == CategoryType.income
            ? previousValue + element.price
            : previousValue,
      );
      final totalExpense = movementsByMonth.fold<double>(
        0,
        (previousValue, element) =>
            element.category.type == CategoryType.expense
                ? previousValue + element.price
                : previousValue,
      );
      final balance = totalIncome - totalExpense;
      incomeData.add(
        LinearChartData(
          xValue: DateFormat('MMM', language).format(i),
          yValue: totalIncome,
        ),
      );
      expenseData.add(
        LinearChartData(
          xValue: DateFormat('MMM', language).format(i),
          yValue: totalExpense,
        ),
      );
      balanceData.add(
        LinearChartData(
          xValue: DateFormat('MMM', language).format(i),
          yValue: balance,
        ),
      );
    }

    if (selResumeItems[ResumeItemType.income] ?? false) {
      data.add(incomeData);
    }
    if (selResumeItems[ResumeItemType.expense] ?? false) {
      data.add(expenseData);
    }
    if (selResumeItems[ResumeItemType.balance] ?? false) {
      data.add(balanceData);
    }

    return data;
  }

  static Future<Movement> buildMovementFromFile({
    required CategoryType movementType,
    required List<Category> categories,
    required String language,
    required String mimeType,
    required Uint8List bytes,
  }) async {
    final prompt = getPrompt(
      movementType: movementType,
      categories: categories,
      language: language,
    );

    final response = await getIt<AiService>().model.generateContent([
      Content.text(prompt),
      Content.inlineData(mimeType, bytes),
    ]);

    var responseJson = <String, dynamic>{};
    if (response.text?[0] == '[') {
      final responseList = jsonDecode(response.text ?? '') as List<dynamic>;
      responseJson = responseList.first as Map<String, dynamic>? ?? {};
    } else {
      responseJson =
          jsonDecode(response.text ?? '') as Map<String, dynamic>? ?? {};
    }

    final movement = Movement.fromAiService(responseJson, categories);

    return movement;
  }

  static String getPrompt({
    required CategoryType movementType,
    required List<Category> categories,
    required String language,
  }) {
    final template =
        getIt<RemoteConfigService>().geminiPromptExtractReceiptData;
    final type = movementType.name.toLowerCase();
    final categoriesStr = categories.map((e) => e.name).join(', ');

    return template
        .replaceAll('{{type}}', type)
        .replaceAll('{{language}}', language)
        .replaceAll('{{categories}}', categoriesStr);
  }

  static String getCategoryName(String category, AppLocalizations l10n) {
    switch (category) {
      case 'TRANSPORT':
        return l10n.categoryTransport;
      case 'FEEDING':
        return l10n.categoryFeeding;
      case 'HEALTH':
        return l10n.categoryHealth;
      case 'ENTERTAINMENT':
        return l10n.categoryEntertainment;
      case 'TRIPS':
        return l10n.categoryTrips;
      case 'TECHNOLOGY':
        return l10n.categoryTechnology;
      case 'EDUCATION':
        return l10n.categoryEducation;
      case 'FASHION':
        return l10n.categoryFashion;
      case 'TAXES':
        return l10n.categoryTaxes;
      case 'INSURANCE':
        return l10n.categoryInsurance;
      case 'DWELLING':
        return l10n.categoryDwelling;
      case 'GIFTS':
        return l10n.categoryGifts;
      case 'OTHERS_EXPENSE':
        return l10n.categoryOthersExpense;
      case 'SALARY':
        return l10n.categorySalary;
      case 'BUSINESS':
        return l10n.categoryBusiness;
      case 'FREELANCE':
        return l10n.categoryFreelance;
      case 'RENTALS':
        return l10n.categoryRentals;
      case 'INVESTMENTS':
        return l10n.categoryInvestments;
      case 'INTERESTS':
        return l10n.categoryInterests;
      case 'PENSIONS':
        return l10n.categoryPensions;
      case 'DIVIDENDS':
        return l10n.categoryDividends;
      case 'AWARDS':
        return l10n.categoryAwards;
      case 'REFUNDS':
        return l10n.categoryRefunds;
      case 'SALES':
        return l10n.categorySales;
      case 'OTHERS_INCOME':
        return l10n.categoryOthersIncome;
      default:
        return '';
    }
  }

  static List<List<dynamic>> getCategoryIcon(String icon) {
    switch (icon) {
      case 'DIRECTIONS_CAR':
        return HugeIcons.strokeRoundedCar01;
      case 'RESTAURANT':
        return HugeIcons.strokeRoundedRestaurant01;
      case 'LOCAL_HOSPITAL':
        return HugeIcons.strokeRoundedHospital01;
      case 'MOVIE':
        return HugeIcons.strokeRoundedVideo01;
      case 'CARD_TRAVEL':
        return HugeIcons.strokeRoundedTravelBag;
      case 'COMPUTER':
        return HugeIcons.strokeRoundedComputerDesk01;
      case 'SCHOOL':
        return HugeIcons.strokeRoundedSchool;
      case 'CHECKROOM':
        return HugeIcons.strokeRoundedShirt01;
      case 'PAYMENTS':
        return HugeIcons.strokeRoundedPayment01;
      case 'SECURITY':
        return HugeIcons.strokeRoundedSecurity;
      case 'HOUSE':
        return HugeIcons.strokeRoundedHome01;
      case 'GIFT':
        return HugeIcons.strokeRoundedGift;
      case 'CATEGORY':
        return HugeIcons.strokeRoundedMore;
      case 'ATTACH_MONEY':
        return HugeIcons.strokeRoundedDollar01;
      case 'BUSINESS':
        return HugeIcons.strokeRoundedBuilding01;
      case 'PERSON_SEARCH':
        return HugeIcons.strokeRoundedUserSearch01;
      case 'APARTMENT':
        return HugeIcons.strokeRoundedBuilding03;
      case 'TRENDING_UP':
        return HugeIcons.strokeRoundedArrowUpRight01;
      case 'PERCENT':
        return HugeIcons.strokeRoundedPercent;
      case 'CARD_MEMBERSHIP':
        return HugeIcons.strokeRoundedCreditCard;
      case 'MONETIZATION_ON':
        return HugeIcons.strokeRoundedDollarCircle;
      case 'CARD_GIFTCARD':
        return HugeIcons.strokeRoundedGiftCard;
      case 'RECEIPT_LONG':
        return HugeIcons.strokeRoundedInvoice01;
      case 'LOCAL_OFFER':
        return HugeIcons.strokeRoundedTag01;
      default:
        return HugeIcons.strokeRoundedAlert02;
    }
  }

  static String getTypeName(CategoryType type, AppLocalizations l10n) {
    switch (type) {
      case CategoryType.expense:
        return l10n.expenseName;
      case CategoryType.income:
        return l10n.incomeName;
    }
  }

  static List<List<dynamic>> getTypeIcon(CategoryType type) {
    switch (type) {
      case CategoryType.expense:
        return HugeIcons.strokeRoundedMoneyRemove01;
      case CategoryType.income:
        return HugeIcons.strokeRoundedMoneyAdd01;
    }
  }
}
