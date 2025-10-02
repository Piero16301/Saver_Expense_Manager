import 'package:flutter/material.dart';
import 'package:rive/rive.dart' hide Image;
import 'package:saver_expense_manager/l10n/l10n.dart';

class AppLoader {
  AppLoader(this.context);

  final BuildContext context;

  late String _message;
  late double _size;
  bool _isLoading = false;

  Future<void> showLoading({String? message, double size = 120}) async {
    final l10n = AppLocalizations.of(context);

    _message = message ?? l10n.loading;
    _size = size;
    _isLoading = true;

    await showGeneralDialog<void>(
      context: context,
      barrierColor: Colors.black54,
      pageBuilder: (context, animation, secondaryAnimation) => PopScope(
        canPop: false,
        child: Material(
          color: Colors.transparent,
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: _size,
                  height: _size,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      const RiveAnimation.asset('assets/animations/loader.riv'),
                      Image.asset(
                        'assets/images/logo_no_bg.png',
                        width: _size / 3,
                        height: _size / 3,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                Text(_message, style: Theme.of(context).textTheme.bodyLarge),
              ],
            ),
          ),
        ),
      ),
    ).then((_) => _isLoading = false);
  }

  void hideLoading() {
    if (Navigator.of(context).canPop() && _isLoading) {
      Navigator.of(context).pop();
      _isLoading = false;
    }
  }

  bool get isLoading => _isLoading;
}
