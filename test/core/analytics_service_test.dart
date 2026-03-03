import 'package:flutter_test/flutter_test.dart';
import 'package:boardpocket/core/services/analytics_service.dart';

void main() {
  group('AnalyticsService', () {
    late AnalyticsService analyticsService;

    setUp(() {
      analyticsService = AnalyticsService();
    });

    test('should have singleton instance', () {
      final instance1 = AnalyticsService();
      final instance2 = AnalyticsService();
      expect(identical(instance1, instance2), true);
    });

    test('should be initialized by default', () {
      expect(analyticsService.isInitialized, true);
    });

    test('should init successfully', () async {
      await analyticsService.init();
      expect(analyticsService.isInitialized, true);
    });

    test('should log error without throwing', () async {
      await analyticsService.logError('Test error', null);
      expect(analyticsService.isInitialized, true);
    });

    test('should log error with stack trace', () async {
      final stack = StackTrace.current;
      await analyticsService.logError('Test error', stack);
      expect(analyticsService.isInitialized, true);
    });

    test('should log screen view without throwing', () async {
      await analyticsService.logScreenView('TestScreen');
      expect(analyticsService.isInitialized, true);
    });

    test('should log event without throwing', () async {
      await analyticsService.logEvent('test_event');
      expect(analyticsService.isInitialized, true);
    });

    test('should log event with parameters', () async {
      await analyticsService.logEvent(
        'test_event',
        parameters: {'key': 'value'},
      );
      expect(analyticsService.isInitialized, true);
    });
  });
}
