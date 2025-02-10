import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:saver_expense_manager/app/app.dart';
import 'package:saver_expense_manager/l10n/l10n.dart';
import 'package:user_api/user_api.dart';

String? highResPicture(String? url) {
  if (url == null) return null;
  return url.replaceAll('s96-c', 's400-c');
}

Stream<QuerySnapshot<Object?>>? getCategoriesChart({
  required String userId,
  required DateTime monthSelected,
  required String type,
}) {
  return FirebaseFirestore.instance
      .collection(movementsCollection)
      .where('user', isEqualTo: userId)
      .where('category.type', isEqualTo: type)
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

List<CategoryData> buildChartData({
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

Stream<QuerySnapshot<Object?>>? getTrendChart({
  required String userId,
  required DateTime startMonth,
  required DateTime endMonth,
  required Category category,
}) {
  return FirebaseFirestore.instance
      .collection(movementsCollection)
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

List<TrendData> buildTrendData({
  required List<QueryDocumentSnapshot<Map<String, dynamic>>> docs,
  required DateTime startMonth,
  required DateTime endMonth,
  required Locale locale,
}) {
  final movements = docs.map((e) => Movement.fromJson(e.data())).toList();
  final data = <TrendData>[];
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
      TrendData(
        month: DateFormat('MMM yyyy', locale.languageCode).format(i),
        value: total,
      ),
    );
  }
  return data;
}

String getCategoryName(String category, AppLocalizations l10n) {
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
    case 'GIFTS':
      return l10n.categoryGifts;
    case 'REFUNDS':
      return l10n.categoryRefunds;
    case 'SALES':
      return l10n.categorySales;
    default:
      return l10n.categoryOthers;
  }
}

IconData getIconData(String icon) {
  switch (icon) {
    case 'DIRECTIONS_CAR':
      return Icons.directions_car;
    case 'RESTAURANT':
      return Icons.restaurant;
    case 'LOCAL_HOSPITAL':
      return Icons.local_hospital;
    case 'MOVIE':
      return Icons.movie;
    case 'CARD_TRAVEL':
      return Icons.card_travel;
    case 'COMPUTER':
      return Icons.computer;
    case 'SCHOOL':
      return Icons.school;
    case 'CHECKROOM':
      return Icons.checkroom;
    case 'PAYMENTS':
      return Icons.payments;
    case 'SECURITY':
      return Icons.security;
    case 'HOUSE':
      return Icons.house;
    case 'CATEGORY':
      return Icons.category;
    case 'ATTACH_MONEY':
      return Icons.attach_money;
    case 'BUSINESS':
      return Icons.business;
    case 'PERSON_SEARCH':
      return Icons.person_search;
    case 'APARTMENT':
      return Icons.apartment;
    case 'TRENDING_UP':
      return Icons.trending_up;
    case 'PERCENT':
      return Icons.percent;
    case 'CARD_MEMBERSHIP':
      return Icons.card_membership;
    case 'MONETIZATION_ON':
      return Icons.monetization_on;
    case 'CARD_GIFTCARD':
      return Icons.card_giftcard;
    case 'RECEIPT_LONG':
      return Icons.receipt_long;
    case 'LOCAL_OFFER':
      return Icons.local_offer;
    default:
      return Icons.error;
  }
}
