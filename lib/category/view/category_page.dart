import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_ui/material_ui.dart';
import 'package:saver_expense_manager/app/app.dart';
import 'package:saver_expense_manager/category/category.dart';

class CategoryPage extends StatelessWidget {
  const CategoryPage({required this.category, super.key});

  final Category category;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => CategoryCubit()..init(category),
      child: const CategoryView(),
    );
  }
}
