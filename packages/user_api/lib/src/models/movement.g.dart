// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'movement.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

/// Default datetime value
const defaultDatetime = '2000-01-01 00:00:00';

Movement _$MovementFromJson(Map<String, dynamic> json) {
  return Movement(
    id: json['id'] as String,
    createdAt: DateTime.parse(json['createdAt'] as String? ?? defaultDatetime)
        .toLocal(),
    updatedAt: DateTime.parse(json['updatedAt'] as String? ?? defaultDatetime)
        .toLocal(),
    name: json['name'] as String? ?? '',
    description: json['description'] as String? ?? '',
    date: json['date'] as String? ?? '',
    category:
        Category.fromJson(json['category'] as Map<String, dynamic>? ?? {}),
    price: (json['price'] as num?)?.toDouble() ?? 0.0,
    type: _$MovementTypeFromJson(json['type'] as String? ?? 'EXPENSE'),
    company: json['company'] as String? ?? '',
    attachments: (json['attachments'] as List<dynamic>?)
            ?.map((e) => e as String? ?? '')
            .toList() ??
        [],
  );
}

Map<String, dynamic> _$MovementToJson(Movement instance) => <String, dynamic>{
      'id': instance.id,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
      'name': instance.name,
      'description': instance.description,
      'date': instance.date,
      'category': instance.category.toJson(),
      'price': instance.price,
      'type': _$MovementTypeEnumMap[instance.type],
      'company': instance.company,
      'attachments': instance.attachments,
    };

MovementType _$MovementTypeFromJson(String type) {
  if (type == 'INCOME') {
    return MovementType.income;
  } else {
    return MovementType.expense;
  }
}

const _$MovementTypeEnumMap = {
  MovementType.income: 'INCOME',
  MovementType.expense: 'EXPENSE',
};
