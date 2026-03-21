import 'dart:async';

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/widgets.dart';

class AnalyticsService {
  AnalyticsService({FirebaseAnalytics? analytics}) {
    _analytics = analytics ?? FirebaseAnalytics.instance;
  }

  late final FirebaseAnalytics _analytics;

  FirebaseAnalytics get analytics => _analytics;

  void logEvent({
    required String name,
    Map<String, Object>? parameters,
  }) {
    unawaited(_analytics.logEvent(name: name, parameters: parameters));
  }

  void setCurrentScreen({required String screenName}) {
    unawaited(
      _analytics.logEvent(
        name: 'screen_view',
        parameters: {'screen_name': screenName},
      ),
    );
  }

  void setUserId({required String id}) {
    unawaited(_analytics.setUserId(id: id));
  }

  NavigatorObserver getRouteObserver() {
    return AppRouteObserver(analyticsService: this);
  }
}

class AppRouteObserver extends NavigatorObserver {
  AppRouteObserver({required this.analyticsService});

  final AnalyticsService analyticsService;

  void _sendScreenView(PageRoute<dynamic> route) {
    final screenName = route.settings.name;
    if (screenName != null) {
      analyticsService.setCurrentScreen(screenName: screenName);
    }
  }

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPush(route, previousRoute);
    if (route is PageRoute) {
      _sendScreenView(route);
    }
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPop(route, previousRoute);
    if (previousRoute is PageRoute && route is PageRoute) {
      _sendScreenView(previousRoute);
    }
  }

  @override
  void didRemove(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didRemove(route, previousRoute);
    if (previousRoute is PageRoute) {
      _sendScreenView(previousRoute);
    }
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    super.didReplace(newRoute: newRoute, oldRoute: oldRoute);
    if (newRoute is PageRoute) {
      _sendScreenView(newRoute);
    }
  }

  @override
  void didChangeTop(
    Route<dynamic> topRoute,
    Route<dynamic>? previousTopRoute,
  ) {
    super.didChangeTop(topRoute, previousTopRoute);
    if (topRoute is PageRoute) {
      _sendScreenView(topRoute);
    }
  }
}
