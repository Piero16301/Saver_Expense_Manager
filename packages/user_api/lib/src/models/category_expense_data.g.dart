// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'category_expense_data.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CategoryExpenseData _$CategoryExpenseDataFromJson(Map<String, dynamic> json) {
  return CategoryExpenseData(
    category:
        Category.fromJson(json['category'] as Map<String, dynamic>? ?? {}),
    totalExpense: (json['totalExpense'] as num?)?.toDouble() ?? 0.0,
  );
}

Map<String, dynamic> _$CategoryExpenseDataToJson(
  CategoryExpenseData instance,
) =>
    <String, dynamic>{
      'category': instance.category.toJson(),
      'totalExpense': instance.totalExpense,
    };
