import 'dart:async';
import 'dart:convert';
import 'dart:io';

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

  @visibleForTesting
  static bool? internetConnectionTestValue;

  static Future<bool> hasInternetConnection() async {
    if (internetConnectionTestValue != null) {
      return internetConnectionTestValue!;
    }
    try {
      final result = await InternetAddress.lookup(
        'google.com',
      ).timeout(AppVariables.timeoutDuration);
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } on SocketException catch (_) {
      return false;
    } on TimeoutException catch (_) {
      return false;
    } on Exception catch (_) {
      return false;
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
            HugeIcon(icon: icon, strokeWidth: 2, color: Colors.white),
            Expanded(
              child: Text(
                message ?? '',
                style: const TextStyle(
                  fontVariations: <FontVariation>[
                    FontVariation('wght', 600),
                  ],
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
                    : Colors.blue,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
        duration: AppVariables.snackBarDuration,
      ),
    );
  }

  static DateTime substracMonth(int month) {
    final now = DateTime.now();
    final targetDate = DateTime(now.year, now.month - (month - 1));
    return targetDate;
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

  static List<CategoryData> buildChartData({
    required List<Movement> movements,
  }) {
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

  static List<LinearChartData> buildTrendData({
    required List<Movement> movements,
    required DateTime startMonth,
    required DateTime endMonth,
    required String language,
  }) {
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
          xValue: _capitalizeFirst(DateFormat('MMM', language).format(i)),
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
          xValue: _capitalizeFirst(DateFormat('MMM', language).format(i)),
          yValue: totalIncome,
        ),
      );
      expenseData.add(
        LinearChartData(
          xValue: _capitalizeFirst(DateFormat('MMM', language).format(i)),
          yValue: totalExpense,
        ),
      );
      balanceData.add(
        LinearChartData(
          xValue: _capitalizeFirst(DateFormat('MMM', language).format(i)),
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

  static String _capitalizeFirst(String text) {
    if (text.isEmpty) return text;
    return '${text[0].toUpperCase()}${text.substring(1)}';
  }

  static Future<Movement> buildMovementFromFile({
    required CategoryType movementType,
    required List<Category> categories,
    required String language,
    required String mimeType,
    required Uint8List bytes,
    required ModelType modelType,
  }) async {
    final prompt = getPrompt(
      movementType: movementType,
      categories: categories,
      language: language,
    );

    String? response = '';

    if (modelType.isLocal && getIt<AiService>().isLocalModelAvailable) {
      response = await getIt<AiService>().generateContentLocal(
        textPrompt: PromptPart.text(text: prompt),
        imagePrompt: PromptPart.file(mimeType: mimeType, bytes: bytes),
      );
    } else {
      response = await getIt<AiService>().generateContentRemote(
        prompt: [
          PromptPart.text(text: prompt),
          PromptPart.file(mimeType: mimeType, bytes: bytes),
        ],
        responseMimeType: 'application/json',
      );
    }

    final responseClean =
        response?.replaceAll('```json', '').replaceAll('```', '').trim();
    var responseJson = <String, dynamic>{};
    if (responseClean?[0] == '[') {
      final responseList = jsonDecode(responseClean ?? '') as List<dynamic>;
      responseJson = responseList.first as Map<String, dynamic>? ?? {};
    } else {
      responseJson =
          jsonDecode(responseClean ?? '') as Map<String, dynamic>? ?? {};
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

  static Future<List<String>?> getAntRecommendations({
    required String userId,
    required String language,
    required AppLocalizations l10n,
  }) async {
    final template = getIt<RemoteConfigService>().geminiPromptDetectAntExpense;
    final lookbackDays = getIt<RemoteConfigService>().geminiAntLookbackDays;

    final now = DateTime.now();
    final fromDate = now.subtract(Duration(days: lookbackDays));

    final movements = await getIt<DatabaseService>().getMovements(
      userId: userId,
      from: DateTime(fromDate.year, fromDate.month, fromDate.day),
      to: DateTime(now.year, now.month, now.day, 23, 59, 59, 999),
    );

    final prompt = template
        .replaceAll(
          '{{transactions_list}}',
          movements.map((e) => '- ${getMovementRecap(l10n, e)}').join('\n'),
        )
        .replaceAll('{{language}}', language)
        .replaceAll('{{lookbackDays}}', lookbackDays.toString());

    String? response;
    final aiService = getIt<AiService>();

    final hasInternet = await AppFunctions.hasInternetConnection();

    if (hasInternet) {
      response = await aiService.generateContentRemote(
        prompt: [PromptPart.text(text: prompt)],
      );
    } else {
      if (aiService.isLocalModelAvailable) {
        response = await aiService.generateContentLocal(
          textPrompt: PromptPart.text(text: prompt),
        );
      } else {
        throw Exception('NO_LOCAL_MODEL_AVAILABLE');
      }
    }

    return response?.split('|||').map((e) => e.trim()).toList();
  }

  static String getMovementRecap(AppLocalizations l10n, Movement movement) {
    if (movement.category.type.isExpense) {
      return l10n.movementExpenseRecapTemplate(
        movement.price.toStringAsFixed(2),
        movement.company,
        movement.title,
        AppVariables.formatDate.format(movement.date),
      );
    } else {
      return l10n.movementIncomeRecapTemplate(
        movement.price.toStringAsFixed(2),
        movement.company,
        movement.title,
        AppVariables.formatDate.format(movement.date),
      );
    }
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

  static Widget? getCategoryAnimatedIcon(Category category, double size) {
    switch (category.name) {
      case 'TRANSPORT':
        return TransportAnimatedIcon(
          color: HexColor.fromHex(category.color),
          size: size,
        );
      case 'FEEDING':
        return FeedingAnimatedIcon(
          color: HexColor.fromHex(category.color),
          size: size,
        );
      case 'HEALTH':
        return HealthAnimatedIcon(
          color: HexColor.fromHex(category.color),
          size: size,
        );
      case 'ENTERTAINMENT':
        return EntertainmentAnimatedIcon(
          color: HexColor.fromHex(category.color),
          size: size,
        );
      case 'TRIPS':
        return TripsAnimatedIcon(
          color: HexColor.fromHex(category.color),
          size: size,
        );
      case 'TECHNOLOGY':
        return TechnologyAnimatedIcon(
          color: HexColor.fromHex(category.color),
          size: size,
        );
      case 'EDUCATION':
        return EducationAnimatedIcon(
          color: HexColor.fromHex(category.color),
          size: size,
        );
      case 'FASHION':
        return FashionAnimatedIcon(
          color: HexColor.fromHex(category.color),
          size: size,
        );
      case 'TAXES':
        return TaxesAnimatedIcon(
          color: HexColor.fromHex(category.color),
          size: size,
        );
      case 'INSURANCE':
        return InsuranceAnimatedIcon(
          color: HexColor.fromHex(category.color),
          size: size,
        );
      case 'DWELLING':
        return DwellingAnimatedIcon(
          color: HexColor.fromHex(category.color),
          size: size,
        );
      case 'GIFTS':
        return GiftsAnimatedIcon(
          color: HexColor.fromHex(category.color),
          size: size,
        );
      case 'OTHERS_EXPENSE':
        return OthersExpenseAnimatedIcon(
          color: HexColor.fromHex(category.color),
          size: size,
        );
      case 'SALARY':
        return SalaryAnimatedIcon(
          color: HexColor.fromHex(category.color),
          size: size,
        );
      case 'BUSINESS':
        return BusinessAnimatedIcon(
          color: HexColor.fromHex(category.color),
          size: size,
        );
      case 'FREELANCE':
        return FreelanceAnimatedIcon(
          color: HexColor.fromHex(category.color),
          size: size,
        );
      case 'RENTALS':
        return RentalsAnimatedIcon(
          color: HexColor.fromHex(category.color),
          size: size,
        );
      case 'INVESTMENTS':
        return InvestmentsAnimatedIcon(
          color: HexColor.fromHex(category.color),
          size: size,
        );
      case 'INTERESTS':
        return InterestsAnimatedIcon(
          color: HexColor.fromHex(category.color),
          size: size,
        );
      case 'PENSIONS':
        return PensionsAnimatedIcon(
          color: HexColor.fromHex(category.color),
          size: size,
        );
      case 'DIVIDENDS':
        return DividendsAnimatedIcon(
          color: HexColor.fromHex(category.color),
          size: size,
        );
      case 'AWARDS':
        return AwardsAnimatedIcon(
          color: HexColor.fromHex(category.color),
          size: size,
        );
      case 'REFUNDS':
        return RefundsAnimatedIcon(
          color: HexColor.fromHex(category.color),
          size: size,
        );
      case 'SALES':
        return SalesAnimatedIcon(
          color: HexColor.fromHex(category.color),
          size: size,
        );
      case 'OTHERS_INCOME':
        return OthersIncomeAnimatedIcon(
          color: HexColor.fromHex(category.color),
          size: size,
        );
      default:
        return null;
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
