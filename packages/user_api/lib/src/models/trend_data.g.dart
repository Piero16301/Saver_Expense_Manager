// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'trend_data.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TrendData _$TrendDataFromJson(Map<String, dynamic> json) {
  return TrendData(
    month: json['month'] as String? ?? '',
    value: (json['value'] as num?)?.toDouble() ?? 0.0,
  );
}

Map<String, dynamic> _$TrendDataToJson(TrendData instance) => <String, dynamic>{
      'month': instance.month,
      'value': instance.value,
    };
