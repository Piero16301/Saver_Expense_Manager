import 'package:equatable/equatable.dart';
import 'package:user_api/src/models/models.dart';

part 'chart_data.g.dart';

/// {@template chart_data}
/// A class that represents a chart data in the app.
/// {@endtemplate}
class ChartData extends Equatable {
  /// {@macro chart_data}
  const ChartData({
    required this.category,
    required this.value,
  });

  /// Creates an instance of [ChartData] from a [Map]
  factory ChartData.fromJson(Map<String, dynamic> json) =>
      _$ChartDataFromJson(json);

  /// Creates a [Map] from an instance of [ChartData]
  Map<String, dynamic> toJson() => _$ChartDataToJson(this);

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
