// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chart_data.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ChartData _$ChartDataFromJson(Map<String, dynamic> json) {
  return ChartData(
    id: json['id'] as String? ?? '',
    name: json['name'] as String? ?? '',
    value: (json['value'] as num?)?.toDouble() ?? 0,
  );
}

Map<String, dynamic> _$ChartDataToJson(ChartData instance) => <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'value': instance.value,
    };
