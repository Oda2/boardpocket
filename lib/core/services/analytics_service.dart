import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:firebase_analytics/firebase_analytics.dart';

class AnalyticsService {
  static final AnalyticsService _instance = AnalyticsService._internal();
  factory AnalyticsService() => _instance;
  AnalyticsService._internal();

  FirebaseAnalytics? _analytics;

  FirebaseAnalytics get analytics => _analytics ?? FirebaseAnalytics.instance;

  Future<void> init() async {
    _analytics = FirebaseAnalytics.instance;
    _setupErrorTracking();
  }

  void _setupErrorTracking() {
    FlutterError.onError = (details) {
      logError(details.exceptionAsString(), details.stack);
    };

    PlatformDispatcher.instance.onError = (error, stack) {
      logError(error.toString(), stack);
      return true;
    };
  }

  Future<void> logError(String message, StackTrace? stack) async {
    await analytics.logEvent(
      name: 'error',
      parameters: {'message': message, 'stack': stack?.toString() ?? ''},
    );
  }

  Future<void> logScreenView(String screenName) async {
    await analytics.logScreenView(screenName: screenName);
  }

  Future<void> logEvent(String name, {Map<String, Object>? parameters}) async {
    await analytics.logEvent(name: name, parameters: parameters);
  }
}
