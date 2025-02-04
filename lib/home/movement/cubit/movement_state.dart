part of 'movement_cubit.dart';

class MovementState extends Equatable {
  const MovementState({
    this.title = '',
    this.description = '',
    this.date,
    this.categories = const <Category>[],
    this.category,
    this.price = 0.0,
    this.company = '',
    this.attachments = const <String>[],
  });

  final String title;
  final String description;
  final DateTime? date;
  final List<Category> categories;
  final Category? category;
  final double price;
  final String company;
  final List<String> attachments;

  MovementState copyWith({
    String? title,
    String? description,
    DateTime? date,
    List<Category>? categories,
    Category? category,
    double? price,
    String? company,
    List<String>? attachments,
  }) {
    return MovementState(
      title: title ?? this.title,
      description: description ?? this.description,
      date: date ?? this.date,
      categories: categories ?? this.categories,
      category: category ?? this.category,
      price: price ?? this.price,
      company: company ?? this.company,
      attachments: attachments ?? this.attachments,
    );
  }

  @override
  List<Object?> get props => [
        title,
        description,
        date,
        categories,
        category,
        price,
        company,
        attachments,
      ];
}
