// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chart_data.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ChartData _$ChartDataFromJson(Map<String, dynamic> json) {
  return ChartData(
    category:
        Category.fromJson(json['category'] as Map<String, dynamic>? ?? {}),
    value: (json['value'] as num?)?.toDouble() ?? 0.0,
  );
}

Map<String, dynamic> _$ChartDataToJson(ChartData instance) => <String, dynamic>{
      'category': instance.category.toJson(),
      'value': instance.value,
    };
