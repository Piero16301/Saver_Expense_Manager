import 'package:equatable/equatable.dart';

part 'category.g.dart';

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
  factory Category.fromJson(Map<String, dynamic> json) =>
      _$CategoryFromJson(json);

  /// Creates a [Map] from an instance of [Category]
  Map<String, dynamic> toJson() => _$CategoryToJson(this);

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
  /// Represents an income category
  income,

  /// Represents an expense category
  expense,
}
