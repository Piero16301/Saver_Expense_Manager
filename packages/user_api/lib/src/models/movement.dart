import 'package:equatable/equatable.dart';
import 'package:user_api/src/models/models.dart';

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
    required this.title,
    required this.description,
    required this.date,
    required this.category,
    required this.price,
    this.company = '',
    this.attachments = const <String>[],
  });

  /// Creates an instance of [Movement] from a [Map]
  factory Movement.fromJson(Map<String, dynamic> json) =>
      _$MovementFromJson(json);

  /// Creates a [Map] from an instance of [Movement]
  Map<String, dynamic> toJson() => _$MovementToJson(this);

  /// An empty movement instance
  static final empty = Movement(
    id: '',
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(),
    title: '',
    description: '',
    date: '',
    category: Category.empty,
    price: 0,
  );

  /// Movement id
  final String id;

  /// Movement created at
  final DateTime createdAt;

  /// Movement updated at
  final DateTime updatedAt;

  /// Movement title
  final String title;

  /// Movement description
  final String description;

  /// Movement date
  final String date;

  /// Movement category
  final Category category;

  /// Movement price
  final double price;

  /// Movement company
  final String company;

  /// Movement attachments
  final List<String> attachments;

  /// Copies the current instance of [Movement] with some new values
  Movement copyWith({
    String? id,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? title,
    String? description,
    String? date,
    Category? category,
    double? price,
    String? company,
    List<String>? attachments,
  }) {
    return Movement(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      title: title ?? this.title,
      description: description ?? this.description,
      date: date ?? this.date,
      category: category ?? this.category,
      price: price ?? this.price,
      company: company ?? this.company,
      attachments: attachments ?? this.attachments,
    );
  }

  @override
  List<Object> get props => [
        id,
        createdAt,
        updatedAt,
        title,
        description,
        date,
        category,
        price,
        company,
        attachments,
      ];
}
