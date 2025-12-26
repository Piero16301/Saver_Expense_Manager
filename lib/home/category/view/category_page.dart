import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:saver_expense_manager/home/category/category.dart';
import 'package:user_api/user_api.dart';

class CategoryPage extends StatelessWidget {
  const CategoryPage({
    required this.category,
    super.key,
  });

  static const String pageName = 'category';
  static const String pagePath = 'category';

  final Category category;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => CategoryCubit()..init(category),
      child: const CategoryView(),
    );
  }
}
