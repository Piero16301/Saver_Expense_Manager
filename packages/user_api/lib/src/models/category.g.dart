// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'category.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Category _$CategoryFromJson(Map<String, dynamic> json) {
  return Category(
    id: json['id'] as String? ?? '',
    createdAt: DateTime.parse(json['createdAt'] as String? ?? defaultDatetime)
        .toLocal(),
    updatedAt: DateTime.parse(json['updatedAt'] as String? ?? defaultDatetime)
        .toLocal(),
    name: json['name'] as String? ?? '',
    icon: json['icon'] as String? ?? '',
    color: json['color'] as String? ?? '',
  );
}

Map<String, dynamic> _$CategoryToJson(Category instance) => <String, dynamic>{
      'id': instance.id,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
      'name': instance.name,
      'icon': instance.icon,
      'color': instance.color,
    };
