// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'linear_chart_data.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LinearChartData _$LinearChartDataFromJson(Map<String, dynamic> json) {
  return LinearChartData(
    xValue: json['xValue'] as String? ?? '',
    yValue: (json['yValue'] as num?)?.toDouble() ?? 0.0,
  );
}

Map<String, dynamic> _$LinearChartDataToJson(LinearChartData instance) =>
    <String, dynamic>{
      'xValue': instance.xValue,
      'yValue': instance.yValue,
    };
