import 'package:equatable/equatable.dart';

part 'trend_data.g.dart';

/// {@template trend_data}
/// A class that represents a trend data for a chart
/// {@endtemplate}
class TrendData extends Equatable {
  /// {@macro trend_data}
  const TrendData({
    required this.month,
    required this.value,
  });

  /// Creates an instance of [TrendData] from a [Map]
  factory TrendData.fromJson(Map<String, dynamic> json) =>
      _$TrendDataFromJson(json);

  /// Creates a [Map] from an instance of [TrendData]
  Map<String, dynamic> toJson() => _$TrendDataToJson(this);

  /// Chart data date
  final String month;

  /// Chart data value
  final double value;

  @override
  List<Object> get props => [
        month,
        value,
      ];
}
