import 'package:equatable/equatable.dart';

part 'chart_data.g.dart';

/// {@template chart_data}
/// A class that represents a chart data in the app.
/// {@endtemplate}
class ChartData extends Equatable {
  /// {@macro chart_data}
  const ChartData({
    required this.name,
    required this.value,
    required this.color,
  });

  /// Creates an instance of [ChartData] from a [Map]
  factory ChartData.fromJson(Map<String, dynamic> json) =>
      _$ChartDataFromJson(json);

  /// Creates a [Map] from an instance of [ChartData]
  Map<String, dynamic> toJson() => _$ChartDataToJson(this);

  /// Chart data name
  final String name;

  /// Chart data value
  final double value;

  /// Chart data color
  final String color;

  @override
  List<Object> get props => [
        name,
        value,
        color,
      ];
}
