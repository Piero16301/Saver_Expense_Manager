import 'package:equatable/equatable.dart';
import 'package:saver_expense_manager/app/app.dart';

part 'category.g.dart';

/// {@template category}
/// A class that represents a category in the app.
/// {@endtemplate}
class Category extends Equatable {
  /// {@macro category}
  const Category({
    required this.id,
    required this.createdAt,
    required this.updatedAt,
    required this.name,
    required this.color,
  });

  /// Creates an instance of [Category] from a [Map]
  factory Category.fromJson(Map<String, dynamic> json) =>
      _$CategoryFromJson(json);

  /// Creates a [Map] from an instance of [Category]
  Map<String, dynamic> toJson() => _$CategoryToJson(this);

  /// Category id
  final String id;

  /// Category created at
  final DateTime createdAt;

  /// Category updated at
  final DateTime updatedAt;

  /// Category name
  final String name;

  /// Category color
  final String color;

  @override
  List<Object> get props => [
        id,
        createdAt,
        updatedAt,
        name,
        color,
      ];
}
