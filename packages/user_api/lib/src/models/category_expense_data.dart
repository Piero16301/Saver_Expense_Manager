import 'package:equatable/equatable.dart';
import 'package:user_api/src/models/models.dart';

part 'category_expense_data.g.dart';

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
  factory CategoryExpenseData.fromJson(Map<String, dynamic> json) =>
      _$CategoryExpenseDataFromJson(json);

  /// Creates a [Map] from an instance of [CategoryExpenseData]
  Map<String, dynamic> toJson() => _$CategoryExpenseDataToJson(this);

  /// Category associated with the expense data
  final Category category;

  /// Total expense for the category
  final double totalExpense;

  @override
  List<Object> get props => [
        category,
        totalExpense,
      ];
}
