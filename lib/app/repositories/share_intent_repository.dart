import 'dart:async';

import 'package:flutter/services.dart';
import 'package:saver_expense_manager/app/app.dart';

abstract class ShareIntentRepository {
  Future<void> initialize();
  SharedFile? consumePendingSharedFile();
  Stream<SharedFile> get sharedFileStream;
  Future<void> dispose();
}

class MockShareIntentRepository implements ShareIntentRepository {
  @override
  Future<void> initialize() async {}

  @override
  SharedFile? consumePendingSharedFile() => null;

  @override
  Stream<SharedFile> get sharedFileStream => const Stream.empty();

  @override
  Future<void> dispose() async {}
}

class MethodChannelShareIntentRepository implements ShareIntentRepository {
  new({MethodChannel? channel})
    : _channel =
          channel ??
          const MethodChannel('com.pmorales.saver.expense.manager/share');

  final MethodChannel _channel;
  final StreamController<SharedFile> _controller =
      StreamController<SharedFile>.broadcast();
  SharedFile? _pendingSharedFile;

  @override
  Stream<SharedFile> get sharedFileStream => _controller.stream;

  @override
  Future<void> initialize() async {
    _channel.setMethodCallHandler(_handleMethodCall);
    try {
      final raw = await _channel.invokeMapMethod<Object?, Object?>(
        'getInitialSharedFile',
      );
      if (raw != null) {
        _handleIncomingPayload(raw);
      }
    } on MissingPluginException {
      // Platform does not implement share intent handling.
    } on PlatformException {
      // Ignore native share fetch errors during startup.
    }
  }

  Future<void> _handleMethodCall(MethodCall call) async {
    if (call.method == 'onSharedFile' && call.arguments is Map) {
      _handleIncomingPayload(call.arguments as Map<Object?, Object?>);
    }
  }

  void _handleIncomingPayload(Map<Object?, Object?> raw) {
    final sharedFile = SharedFile.fromMap(raw);
    if (!sharedFile.isSupported) return;

    if (_controller.hasListener) {
      _controller.add(sharedFile);
    } else {
      _pendingSharedFile = sharedFile;
    }
  }

  @override
  SharedFile? consumePendingSharedFile() {
    final file = _pendingSharedFile;
    _pendingSharedFile = null;
    return file;
  }

  @override
  Future<void> dispose() async {
    _channel.setMethodCallHandler(null);
    await _controller.close();
  }
}
