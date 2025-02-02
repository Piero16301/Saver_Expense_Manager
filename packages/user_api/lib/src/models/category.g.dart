// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'category.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Category _$CategoryFromJson(Map<String, dynamic> json) {
  return Category(
    id: json['id'] as String? ?? '',
    createdAt:
        (json['createdAt'] as Timestamp? ?? Timestamp.now()).toDate().toLocal(),
    updatedAt:
        (json['updatedAt'] as Timestamp? ?? Timestamp.now()).toDate().toLocal(),
    name: json['name'] as String? ?? '',
    icon: json['icon'] as String? ?? '',
    color: json['color'] as String? ?? '',
    type: _$CategoryTypeFromJson(json['type'] as String? ?? ''),
  );
}

Map<String, dynamic> _$CategoryToJson(Category instance) => <String, dynamic>{
      'id': instance.id,
      'createdAt': instance.createdAt.toUtc(),
      'updatedAt': instance.updatedAt.toUtc(),
      'name': instance.name,
      'icon': instance.icon,
      'color': instance.color,
      'type': _$CategoryTypeEnumMap[instance.type],
    };

CategoryType _$CategoryTypeFromJson(String type) {
  if (type == 'INCOME') {
    return CategoryType.income;
  } else {
    return CategoryType.expense;
  }
}

const _$CategoryTypeEnumMap = {
  CategoryType.income: 'INCOME',
  CategoryType.expense: 'EXPENSE',
};
