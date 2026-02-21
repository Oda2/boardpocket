import 'dart:async';
import 'package:flutter/foundation.dart';

class AnalyticsService {
  static final AnalyticsService _instance = AnalyticsService._internal();
  factory AnalyticsService() => _instance;
  AnalyticsService._internal();

  bool _isInitialized = true;

  bool get isInitialized => _isInitialized;

  Future<void> init() async {
    _isInitialized = true;
  }

  Future<void> logError(String message, StackTrace? stack) async {
    if (!_isInitialized) return;
    debugPrint('[Analytics] Error: $message');
    if (stack != null) {
      debugPrint('[Analytics] Stack: $stack');
    }
  }

  Future<void> logScreenView(String screenName) async {
    if (!_isInitialized) return;
    debugPrint('[Analytics] Screen: $screenName');
  }

  Future<void> logEvent(String name, {Map<String, Object>? parameters}) async {
    if (!_isInitialized) return;
    debugPrint('[Analytics] Event: $name');
    if (parameters != null) {
      debugPrint('[Analytics] Params: $parameters');
    }
  }
}
