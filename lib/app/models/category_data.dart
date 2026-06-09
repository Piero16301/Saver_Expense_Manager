import 'package:equatable/equatable.dart';
import 'package:saver_expense_manager/app/models/models.dart';

/// {@template category_data}
/// A class that represents a category data for a chart
/// {@endtemplate}
class CategoryData extends Equatable {
  /// {@macro category_data}
  const CategoryData({required this.category, required this.value});

  /// Creates an instance of [CategoryData] from a [Map]
  factory CategoryData.fromJson(Map<String, dynamic> json) {
    return CategoryData(
      category: Category.fromJson(
        json['category'] as Map<String, dynamic>? ?? {},
      ),
      value: (json['value'] as num?)?.toDouble() ?? 0.0,
    );
  }

  /// Creates a [Map] from an instance of [CategoryData]
  Map<String, dynamic> toJson() {
    return <String, dynamic>{'category': category.toJson(), 'value': value};
  }

  /// Chart data category
  final Category category;

  /// Chart data value
  final double value;

  @override
  List<Object> get props => [category, value];
}
