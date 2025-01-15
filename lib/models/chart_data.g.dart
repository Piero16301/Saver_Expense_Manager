// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chart_data.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ChartData _$ChartDataFromJson(Map<String, dynamic> json) {
  return ChartData(
    name: json['name'] as String? ?? '',
    value: (json['value'] as num?)?.toDouble() ?? 0.0,
    color: json['color'] as String? ?? '',
  );
}

Map<String, dynamic> _$ChartDataToJson(ChartData instance) => <String, dynamic>{
      'name': instance.name,
      'value': instance.value,
      'color': instance.color,
    };
