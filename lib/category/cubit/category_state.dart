part of 'category_cubit.dart';

class CategoryState extends Equatable {
  const CategoryState({this.category = Category.empty});

  final Category category;

  CategoryState copyWith({Category? category}) {
    return CategoryState(category: category ?? this.category);
  }

  @override
  List<Object> get props => [category];
}
