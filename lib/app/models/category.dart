import 'package:equatable/equatable.dart';

/// {@template category}
/// A class that represents a category in the app.
/// {@endtemplate}
class Category extends Equatable {
  /// {@macro category}
  const Category({
    required this.id,
    required this.name,
    required this.icon,
    required this.color,
    required this.type,
  });

  /// Creates an instance of [Category] from a [Map]
  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      icon: json['icon'] as String? ?? '',
      color: json['color'] as String? ?? '',
      type: CategoryType.categoryTypeFromJson(json['type'] as String? ?? ''),
    );
  }

  /// Creates a [Map] from an instance of [Category]
  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'name': name,
      'icon': icon,
      'color': color,
      'type': type.value,
    };
  }

  /// An empty category instance
  static const empty = Category(
    id: '',
    name: '',
    icon: '',
    color: '',
    type: CategoryType.expense,
  );

  /// Category id
  final String id;

  /// Category name
  final String name;

  /// Category icon
  final String icon;

  /// Category color
  final String color;

  /// Category type
  final CategoryType type;

  @override
  List<Object> get props => [
        id,
        name,
        icon,
        color,
        type,
      ];
}

/// An enum that represents the type of category
enum CategoryType {
  /// Represents an expense category
  expense('EXPENSE'),

  /// Represents an income category
  income('INCOME');

  /// Creates an instance of [CategoryType] from a [String]
  const CategoryType(this.value);

  /// The string value of the category type
  final String value;

  /// Creates an instance of [CategoryType] from a [String]
  static CategoryType categoryTypeFromJson(String type) {
    if (type.toUpperCase() == CategoryType.income.value) {
      return CategoryType.income;
    } else {
      return CategoryType.expense;
    }
  }
}
