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
    required this.type,
  });

  /// Creates an instance of [Movement] from a [Map]
  factory Movement.fromJson(Map<String, dynamic> json) =>
      _$MovementFromJson(json);

  /// Creates a [Map] from an instance of [Movement]
  Map<String, dynamic> toJson() => _$MovementToJson(this);

  /// Movement id
  final String id;

  /// Movement created at
  final DateTime createdAt;

  /// Movement updated at
  final DateTime updatedAt;

  /// Movement name
  final String name;

  /// Movement description
  final String description;

  /// Movement date
  final String date;

  /// Movement category
  final Category category;

  /// Movement company
  final String company;

  /// Movement price
  final double price;

  /// Movement type
  final MovementType type;

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
        type,
      ];
}

enum MovementType { income, expense }
