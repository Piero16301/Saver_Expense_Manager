import 'dart:async';

import 'package:flutter/material.dart';
import 'package:rive/rive.dart';
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
                      const AppLoaderWidget(),
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

class AppLoaderWidget extends StatefulWidget {
  const AppLoaderWidget({super.key});

  @override
  State<AppLoaderWidget> createState() => _AppLoaderWidgetState();
}

class _AppLoaderWidgetState extends State<AppLoaderWidget> {
  File? file;
  Artboard? artboard;
  SingleAnimationPainter? painter;
  bool isInitialized = false;

  @override
  void initState() {
    super.initState();
    unawaited(_init());
  }

  Future<void> _init() async {
    final riveFile = (await File.asset(
      'assets/animations/loader.riv',
      riveFactory: Factory.rive,
    ))!;
    final rivePainter = SingleAnimationPainter('Animation 1');
    final riveArtboard = riveFile.defaultArtboard();

    if (mounted) {
      setState(() {
        file = riveFile;
        painter = rivePainter;
        artboard = riveArtboard;
        isInitialized = true;
      });
    }
  }

  @override
  void dispose() {
    painter?.dispose();
    artboard?.dispose();
    file?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!isInitialized || artboard == null || painter == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return RiveArtboardWidget(
      artboard: artboard!,
      painter: painter!,
    );
  }
}
