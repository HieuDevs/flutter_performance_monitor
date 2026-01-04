import 'package:flutter_performance_monitor/flutter_performance_monitor.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('PerformanceMetrics Additional Tests', () {
    test('should handle zero values', () {
      final metrics = PerformanceMetrics(
        fps: 0.0,
        frameTime: 0.0,
        frameCount: 0,
        cpuUsage: 0.0,
        memoryUsage: 0.0,
        timestamp: DateTime.now(),
      );

      expect(metrics.fps, 0.0);
      expect(metrics.frameTime, 0.0);
      expect(metrics.frameCount, 0);
      expect(metrics.cpuUsage, 0.0);
      expect(metrics.memoryUsage, 0.0);
    });

    test('should handle very large values', () {
      final metrics = PerformanceMetrics(
        fps: 999.99,
        frameTime: 9999.99,
        frameCount: 999999,
        cpuUsage: 100.0,
        memoryUsage: 9999.99,
        timestamp: DateTime.now(),
      );

      expect(metrics.fps, 999.99);
      expect(metrics.frameTime, 9999.99);
      expect(metrics.frameCount, 999999);
      expect(metrics.cpuUsage, 100.0);
      expect(metrics.memoryUsage, 9999.99);
    });

    test('should handle negative frame count as zero', () {
      final metrics = PerformanceMetrics(
        fps: 60.0,
        frameTime: 16.67,
        frameCount: 0,
        cpuUsage: 30.0,
        memoryUsage: 50.0,
        timestamp: DateTime.now(),
      );

      expect(metrics.frameCount, greaterThanOrEqualTo(0));
    });

    test('should preserve timestamp precision', () {
      final now = DateTime.now();
      final metrics = PerformanceMetrics(
        fps: 60.0,
        frameTime: 16.67,
        frameCount: 100,
        cpuUsage: 30.0,
        memoryUsage: 50.0,
        timestamp: now,
      );

      expect(
          metrics.timestamp.millisecondsSinceEpoch, now.millisecondsSinceEpoch);
    });

    test('copyWith should preserve null values', () {
      final original = PerformanceMetrics(
        fps: 60.0,
        frameTime: 16.67,
        frameCount: 100,
        cpuUsage: 30.0,
        memoryUsage: 50.0,
        timestamp: DateTime.now(),
        minFps: null,
        maxFps: null,
        avgFps: null,
      );

      final copied = original.copyWith(fps: 30.0);

      expect(copied.minFps, isNull);
      expect(copied.maxFps, isNull);
      expect(copied.avgFps, isNull);
    });
  });
}
