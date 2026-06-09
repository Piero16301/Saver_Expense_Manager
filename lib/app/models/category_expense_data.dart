import 'package:equatable/equatable.dart';
import 'package:saver_expense_manager/app/models/models.dart';

/// {@template category_expense_data}
/// A class that represents expense data for a category
/// {@endtemplate}
class CategoryExpenseData extends Equatable {
  /// {@macro category_expense_data}
  const CategoryExpenseData({
    required this.category,
    required this.totalExpense,
  });

  /// Creates an instance of [CategoryExpenseData] from a [Map]
  factory CategoryExpenseData.fromJson(Map<String, dynamic> json) {
    return CategoryExpenseData(
      category: Category.fromJson(
        json['category'] as Map<String, dynamic>? ?? {},
      ),
      totalExpense: (json['totalExpense'] as num?)?.toDouble() ?? 0.0,
    );
  }

  /// Creates a [Map] from an instance of [CategoryExpenseData]
  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'category': category.toJson(),
      'totalExpense': totalExpense,
    };
  }

  /// Category associated with the expense data
  final Category category;

  /// Total expense for the category
  final double totalExpense;

  @override
  List<Object> get props => [category, totalExpense];
}
