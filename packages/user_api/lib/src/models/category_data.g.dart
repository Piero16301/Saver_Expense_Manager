// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'category_data.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CategoryData _$CategoryDataFromJson(Map<String, dynamic> json) {
  return CategoryData(
    category:
        Category.fromJson(json['category'] as Map<String, dynamic>? ?? {}),
    value: (json['value'] as num?)?.toDouble() ?? 0.0,
  );
}

Map<String, dynamic> _$CategoryDataToJson(CategoryData instance) =>
    <String, dynamic>{
      'category': instance.category.toJson(),
      'value': instance.value,
    };
