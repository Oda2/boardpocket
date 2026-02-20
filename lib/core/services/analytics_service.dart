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
    _analytics = FirebaseAnalytics.instance;
    if (!kIsWeb) {
      _setupErrorTracking();
    }
    _isInitialized = true;
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
    await analytics.logEvent(
      name: 'error',
      parameters: {'message': message, 'stack': stack?.toString() ?? ''},
    );
  }

  Future<void> logScreenView(String screenName) async {
    if (!_isInitialized) return;
    await analytics.logScreenView(screenName: screenName);
  }

  Future<void> logEvent(String name, {Map<String, Object>? parameters}) async {
    if (!_isInitialized) return;
    await analytics.logEvent(name: name, parameters: parameters);
  }
}
