import 'package:equatable/equatable.dart';

part 'linear_chart_data.g.dart';

/// {@template linear_chart_data}
/// A class that represents a linear chart data point
/// {@endtemplate}
class LinearChartData extends Equatable {
  /// {@macro linear_chart_data}
  const LinearChartData({
    required this.xValue,
    required this.yValue,
  });

  /// Creates an instance of [LinearChartData] from a [Map]
  factory LinearChartData.fromJson(Map<String, dynamic> json) =>
      _$LinearChartDataFromJson(json);

  /// Creates a [Map] from an instance of [LinearChartData]
  Map<String, dynamic> toJson() => _$LinearChartDataToJson(this);

  /// Chart data label
  final String xValue;

  /// Chart data value
  final double yValue;

  @override
  List<Object> get props => [
        xValue,
        yValue,
      ];
}
