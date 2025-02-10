import 'package:equatable/equatable.dart';
import 'package:user_api/src/models/models.dart';

part 'category_data.g.dart';

/// {@template category_data}
/// A class that represents a category data for a chart
/// {@endtemplate}
class CategoryData extends Equatable {
  /// {@macro category_data}
  const CategoryData({
    required this.category,
    required this.value,
  });

  /// Creates an instance of [CategoryData] from a [Map]
  factory CategoryData.fromJson(Map<String, dynamic> json) =>
      _$CategoryDataFromJson(json);

  /// Creates a [Map] from an instance of [CategoryData]
  Map<String, dynamic> toJson() => _$CategoryDataToJson(this);

  /// Chart data category
  final Category category;

  /// Chart data value
  final double value;

  @override
  List<Object> get props => [
        category,
        value,
      ];
}
