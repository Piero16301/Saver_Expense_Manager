import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:intl/intl.dart';
import 'package:user_api/src/models/models.dart';

part 'movement.g.dart';

/// {@template movement}
/// A class that represents a movement in the app.
/// {@endtemplate}
class Movement extends Equatable {
  /// {@macro movement}
  const Movement({
    required this.id,
    required this.title,
    required this.description,
    required this.date,
    required this.category,
    required this.price,
    required this.user,
    this.company = '',
    this.attachments = const <String>[],
  });

  /// Creates an instance of [Movement] from a [Map]
  factory Movement.fromJson(Map<String, dynamic> json) =>
      _$MovementFromJson(json);

  /// Creates an instance of [Movement] from a model [Map]
  factory Movement.fromModel(
    Map<String, dynamic> json,
    List<Category> categories,
  ) =>
      _$MovementFromModel(json, categories);

  /// Creates a [Map] from an instance of [Movement]
  Map<String, dynamic> toJson() => _$MovementToJson(this);

  /// An empty movement instance
  static final empty = Movement(
    id: '',
    title: '',
    description: '',
    date: DateTime.now(),
    category: Category.empty,
    price: 0,
    user: '',
  );

  /// Movement id
  final String id;

  /// Movement title
  final String title;

  /// Movement description
  final String description;

  /// Movement date
  final DateTime date;

  /// Movement category
  final Category category;

  /// Movement price
  final double price;

  /// Movement company
  final String company;

  /// Movement attachments
  final List<String> attachments;

  /// Movement user
  final String user;

  /// Copies the current instance of [Movement] with some new values
  Movement copyWith({
    String? id,
    String? title,
    String? description,
    DateTime? date,
    Category? category,
    double? price,
    String? company,
    List<String>? attachments,
    String? user,
  }) {
    return Movement(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      date: date ?? this.date,
      category: category ?? this.category,
      price: price ?? this.price,
      company: company ?? this.company,
      attachments: attachments ?? this.attachments,
      user: user ?? this.user,
    );
  }

  @override
  List<Object> get props => [
        id,
        title,
        description,
        date,
        category,
        price,
        company,
        attachments,
        user,
      ];
}
