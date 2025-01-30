import 'package:flutter/material.dart';
import 'package:saver_expense_manager/app/app.dart';
import 'package:user_api/user_api.dart';

class CategoriesListChart extends StatelessWidget {
  const CategoriesListChart({
    required this.data,
    super.key,
  });

  final List<ChartData> data;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          children: data
              .map(
                (e) => ListTile(
                  contentPadding: const EdgeInsets.only(left: 16),
                  title: Text(e.name),
                  subtitle: Text('\$${e.value.toStringAsFixed(2)}'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: HexColor.fromHex(e.color).withValues(
                            alpha: 0.3,
                          ),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Padding(
                          padding: EdgeInsets.symmetric(
                            vertical: 5,
                            horizontal: 10,
                          ),
                          child: Text(
                            '18%',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.arrow_forward_ios),
                        onPressed: () {},
                      ),
                    ],
                  ),
                  leading: const Icon(Icons.account_box),
                ),
              )
              .toList(),
        ),
      ),
    );
  }
}
