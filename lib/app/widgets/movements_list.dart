import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:saver_expense_manager/app/app.dart';
import 'package:user_api/user_api.dart';

class MovementsList extends StatelessWidget {
  const MovementsList({
    required this.movements,
    super.key,
  });

  final List<Movement> movements;

  @override
  Widget build(BuildContext context) {
    final locale =
        context.select<AppCubit, Locale>((cubit) => cubit.state.locale!);

    return Expanded(
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          children: movements
              .map(
                (e) => ListTile(
                  onTap: () {},
                  contentPadding: const EdgeInsets.only(left: 16, right: 16),
                  title: Text(
                    e.title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  subtitle: Text(
                    e.description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  trailing: Container(
                    width: 80,
                    decoration: BoxDecoration(
                      color: HexColor.fromHex(e.category.color).withValues(
                        alpha: 0.5,
                      ),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 5),
                      child: Text(
                        moneyFormat.format(e.price),
                        style: const TextStyle(fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                  leading: Text(
                    largeDateFormat(locale.languageCode)
                        .format(e.date)
                        .replaceFirst(' ', '\n')
                        .toUpperCase(),
                    textAlign: TextAlign.center,
                  ),
                ),
              )
              .toList(),
        ),
      ),
    );
  }
}
