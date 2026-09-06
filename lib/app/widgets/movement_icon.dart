import 'package:hugeicons/hugeicons.dart';
import 'package:material_ui/material_ui.dart';
import 'package:saver_expense_manager/app/app.dart';

class MovementIcon extends StatelessWidget {
  const MovementIcon({required this.movement, super.key});

  final Movement movement;

  @override
  Widget build(BuildContext context) {
    final customLogoKey = AppVariables.companiesWithLogo.firstWhere((company) {
      return movement.company.toLowerCase().contains(company);
    }, orElse: () => '');

    if (customLogoKey.isNotEmpty) {
      return CircleAvatar(
        radius: 22,
        backgroundImage: AssetImage('assets/logos/$customLogoKey.png'),
      );
    }

    return CircleAvatar(
      radius: 22,
      backgroundColor: HexColor.fromHex(movement.category.color),
      child: HugeIcon(
        icon: AppFunctions.getCategoryIcon(movement.category.icon),
        size: 34,
        color: Theme.of(context).cardColor,
        strokeWidth: 2,
      ),
    );
  }
}
