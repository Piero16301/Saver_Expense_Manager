import 'package:equatable/equatable.dart';
import 'package:saver_expense_manager/app/app.dart';
import 'package:saver_expense_manager/models/models.dart';

part 'movement.g.dart';

/// {@template movement}
/// A class that represents a movement in the app.
/// {@endtemplate}
class Movement extends Equatable {
  /// {@macro movement}
  const Movement({
    required this.id,
    required this.createdAt,
    required this.updatedAt,
    required this.name,
    required this.description,
    required this.date,
    required this.category,
    required this.company,
    required this.price,
  });

  /// Creates an instance of [Movement] from a [Map]
  factory Movement.fromJson(Map<String, dynamic> json) =>
      _$MovementFromJson(json);

  /// Creates a [Map] from an instance of [Movement]
  Map<String, dynamic> toJson() => _$MovementToJson(this);

  /// Chart data id
  final String id;

  /// Chart data created at
  final DateTime createdAt;

  /// Chart data updated at
  final DateTime updatedAt;

  /// Chart data name
  final String name;

  /// Chart data description
  final String description;

  /// Chart data date
  final String date;

  /// Chart data category
  final Category category;

  /// Chart data company
  final String company;

  /// Chart data price
  final double price;

  @override
  List<Object> get props => [
        id,
        createdAt,
        updatedAt,
        name,
        description,
        date,
        category,
        company,
        price,
      ];
}
