// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'movement.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Movement _$MovementFromJson(Map<String, dynamic> json) {
  return Movement(
    id: json['id'] as String,
    title: json['name'] as String? ?? '',
    description: json['description'] as String? ?? '',
    date: json['date'] as String? ?? '',
    category:
        Category.fromJson(json['category'] as Map<String, dynamic>? ?? {}),
    price: (json['price'] as num?)?.toDouble() ?? 0.0,
    company: json['company'] as String? ?? '',
    attachments: (json['attachments'] as List<dynamic>?)
            ?.map((e) => e as String? ?? '')
            .toList() ??
        [],
    user: json['user'] as String? ?? '',
  );
}

Map<String, dynamic> _$MovementToJson(Movement instance) => <String, dynamic>{
      'id': instance.id,
      'name': instance.title,
      'description': instance.description,
      'date': instance.date,
      'category': instance.category.toJson(),
      'price': instance.price,
      'company': instance.company,
      'attachments': instance.attachments,
      'user': instance.user,
    };
