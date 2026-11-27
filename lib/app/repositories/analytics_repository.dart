import 'dart:async';

import 'package:firebase_analytics/firebase_analytics.dart';

abstract class AnalyticsRepository {
  void logEvent({required String name, Map<String, Object>? parameters});
  void setCurrentScreen({required String screenName});
  void setUserId({required String id});
}

class MockAnalyticsEvent {
  const new({required this.name, this.parameters});

  final String name;
  final Map<String, Object>? parameters;
}

class MockAnalyticsRepository implements AnalyticsRepository {
  final List<MockAnalyticsEvent> _loggedEvents = [];
  String? _currentScreen;
  String? _userId;

  List<MockAnalyticsEvent> get loggedEvents => List.unmodifiable(_loggedEvents);
  String? get currentScreen => _currentScreen;
  String? get userId => _userId;

  @override
  void logEvent({required String name, Map<String, Object>? parameters}) {
    _loggedEvents.add(MockAnalyticsEvent(name: name, parameters: parameters));
  }

  @override
  void setCurrentScreen({required String screenName}) {
    _currentScreen = screenName;
    logEvent(name: 'screen_view', parameters: {'screen_name': screenName});
  }

  @override
  void setUserId({required String id}) {
    _userId = id;
  }
}

class FirebaseAnalyticsRepository implements AnalyticsRepository {
  new({FirebaseAnalytics? analytics})
    : _analytics = analytics ?? FirebaseAnalytics.instance;

  final FirebaseAnalytics _analytics;

  @override
  void logEvent({required String name, Map<String, Object>? parameters}) {
    unawaited(_analytics.logEvent(name: name, parameters: parameters));
  }

  @override
  void setCurrentScreen({required String screenName}) {
    unawaited(
      _analytics.logEvent(
        name: 'screen_view',
        parameters: {'screen_name': screenName},
      ),
    );
  }

  @override
  void setUserId({required String id}) {
    unawaited(_analytics.setUserId(id: id));
  }
}
