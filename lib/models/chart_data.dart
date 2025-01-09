import 'package:equatable/equatable.dart';

part 'chart_data.g.dart';

/// {@template chart_data}
/// Chart data model
/// {@endtemplate}
class ChartData extends Equatable {
  /// {@macro chart_data}
  const ChartData({
    required this.id,
    required this.name,
    required this.value,
  });

  /// Creates an instance of [ChartData] from a [Map]
  factory ChartData.fromJson(Map<String, dynamic> json) =>
      _$ChartDataFromJson(json);

  /// Creates a [Map] from an instance of [ChartData]
  Map<String, dynamic> toJson() => _$ChartDataToJson(this);

  /// Chart data id
  final String id;

  /// Chart data name
  final String name;

  /// Chart data value
  final double value;

  /// Empty chart data
  static const empty = ChartData(
    id: '',
    name: '',
    value: 0,
  );

  @override
  List<Object> get props => [
        id,
        name,
        value,
      ];
}
