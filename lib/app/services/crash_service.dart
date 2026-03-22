import 'dart:async';

import 'package:firebase_crashlytics/firebase_crashlytics.dart';

class CrashService {
  CrashService({FirebaseCrashlytics? crashlytics})
      : _crashlytics = crashlytics ?? FirebaseCrashlytics.instance;

  final FirebaseCrashlytics _crashlytics;

  void recordError(
    dynamic exception,
    StackTrace? stack, {
    dynamic reason,
    Iterable<Object> information = const [],
    bool? fatal,
  }) {
    unawaited(
      _crashlytics.recordError(
        exception,
        stack,
        reason: reason,
        information: information,
        fatal: fatal ?? false,
      ),
    );
  }

  void log(String message) {
    unawaited(_crashlytics.log(message));
  }

  void setCustomKey(String key, Object value) {
    unawaited(_crashlytics.setCustomKey(key, value));
  }

  void setUserIdentifier(String identifier) {
    unawaited(_crashlytics.setUserIdentifier(identifier));
  }
}
