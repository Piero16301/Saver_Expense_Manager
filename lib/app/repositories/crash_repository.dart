import 'dart:async';

import 'package:firebase_crashlytics/firebase_crashlytics.dart';

abstract class CrashRepository {
  void recordError(
    dynamic exception,
    StackTrace? stack, {
    dynamic reason,
    Iterable<Object> information = const [],
    bool? fatal,
  });
  void log(String message);
  void setCustomKey(String key, Object value);
  void setUserIdentifier(String identifier);
}

class MockCrashRecord {
  const new({
    required this.exception,
    this.stack,
    this.reason,
    this.information = const [],
    this.fatal = false,
  });

  final dynamic exception;
  final StackTrace? stack;
  final dynamic reason;
  final Iterable<Object> information;
  final bool fatal;
}

class MockCrashRepository implements CrashRepository {
  final List<String> _logs = [];
  final List<MockCrashRecord> _recordedErrors = [];
  final Map<String, Object> _customKeys = {};
  String? _userIdentifier;

  List<String> get logs => List.unmodifiable(_logs);
  List<MockCrashRecord> get recordedErrors =>
      List.unmodifiable(_recordedErrors);
  Map<String, Object> get customKeys => Map.unmodifiable(_customKeys);
  String? get userIdentifier => _userIdentifier;

  @override
  void log(String message) {
    _logs.add(message);
  }

  @override
  void recordError(
    dynamic exception,
    StackTrace? stack, {
    dynamic reason,
    Iterable<Object> information = const [],
    bool? fatal,
  }) {
    _recordedErrors.add(
      MockCrashRecord(
        exception: exception,
        stack: stack,
        reason: reason,
        information: information,
        fatal: fatal ?? false,
      ),
    );
  }

  @override
  void setCustomKey(String key, Object value) {
    _customKeys[key] = value;
  }

  @override
  void setUserIdentifier(String identifier) {
    _userIdentifier = identifier;
  }
}

class CrashlyticsCrashRepository implements CrashRepository {
  new({FirebaseCrashlytics? crashlytics})
    : _crashlytics = crashlytics ?? FirebaseCrashlytics.instance;

  final FirebaseCrashlytics _crashlytics;

  @override
  void log(String message) {
    unawaited(_crashlytics.log(message));
  }

  @override
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

  @override
  void setCustomKey(String key, Object value) {
    unawaited(_crashlytics.setCustomKey(key, value));
  }

  @override
  void setUserIdentifier(String identifier) {
    unawaited(_crashlytics.setUserIdentifier(identifier));
  }
}
