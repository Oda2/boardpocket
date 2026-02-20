import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class AnalyticsService {
  static final AnalyticsService _instance = AnalyticsService._internal();
  factory AnalyticsService() => _instance;
  AnalyticsService._internal();

  FirebaseAnalytics? _analytics;
  bool _isInitialized = false;

  FirebaseAnalytics get analytics {
    if (_analytics == null) {
      return FirebaseAnalytics.instance;
    }
    return _analytics!;
  }

  Future<void> init() async {
    if (kIsWeb) {
      return;
    }
    try {
      _analytics = FirebaseAnalytics.instance;
      _setupErrorTracking();
      _isInitialized = true;
    } catch (e) {
      _isInitialized = false;
    }
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
    if (!_isInitialized) return;
    try {
      await analytics.logEvent(
        name: 'error',
        parameters: {'message': message, 'stack': stack?.toString() ?? ''},
      );
    } catch (_) {}
  }

  Future<void> logScreenView(String screenName) async {
    if (!_isInitialized) return;
    try {
      await analytics.logScreenView(screenName: screenName);
    } catch (_) {}
  }

  Future<void> logEvent(String name, {Map<String, Object>? parameters}) async {
    if (!_isInitialized) return;
    try {
      await analytics.logEvent(name: name, parameters: parameters);
    } catch (_) {}
  }
}
