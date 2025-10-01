import 'package:flutter/widgets.dart';
import 'package:saver_expense_manager/l10n/gen/app_localizations.dart';

export 'package:saver_expense_manager/l10n/gen/app_localizations.dart';

extension AppLocalizationsX on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this);
}
