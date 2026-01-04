import 'dart:async';
import 'dart:developer' as developer;
import 'package:flutter/foundation.dart';
import 'package:flutter/scheduler.dart';
import '../models/performance_metrics.dart';
import '../utils/constants.dart';
import 'memory_profiler.dart';

/// Core performance tracking service
class PerformanceTracker {
  factory PerformanceTracker() => _instance;

  /// Create a new instance for testing (not singleton)
  @visibleForTesting
  factory PerformanceTracker.testInstance() => PerformanceTracker._internal();

  PerformanceTracker._internal();
  static final PerformanceTracker _instance = PerformanceTracker._internal();

  final _metricsController = StreamController<PerformanceMetrics>.broadcast();

  /// Stream of performance metrics
  Stream<PerformanceMetrics> get metricsStream => _metricsController.stream;

  // FPS tracking with timestamps
  final List<int> _frameTimestamps = []; // Store microseconds since epoch
  int _frameCount = 0;
  DateTime? _startTime;
  Timer? _updateTimer;

  // Memory tracking
  final MemoryProfiler _memoryProfiler = MemoryProfiler();
  double _currentMemory = 0.0;

  // Statistics
  double? _minFps;
  double? _maxFps;
  double? _totalFps = 0.0;
  int _fpsReadings = 0;
  final List<double> _fpsHistory = [];

  bool _isTracking = false;
  bool get isTracking => _isTracking;

  /// Start performance tracking
  void startTracking({
    Duration updateInterval = PerformanceConstants.defaultUpdateInterval,
  }) {
    if (_isTracking) {
      return;
    }

    _isTracking = true;
    _frameCount = 0;
    _frameTimestamps.clear();
    _fpsHistory.clear();
    _startTime = DateTime.now();
    _minFps = null;
    _maxFps = null;
    _totalFps = 0.0;
    _fpsReadings = 0;

    // Start frame callback
    _scheduleFrameCallback();

    // Start memory monitoring
    _memoryProfiler.startMonitoring();
    _memoryProfiler.memoryStream.listen((memory) {
      _currentMemory = memory;
    });

    // Start periodic metrics calculation
    _updateTimer = Timer.periodic(updateInterval, (_) => _calculateMetrics());

    developer.log(
      'Performance tracking started',
      name: 'PerformanceTracker',
    );
  }

  /// Schedule frame callback
  void _scheduleFrameCallback() {
    if (!_isTracking) {
      return;
    }

    SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
      if (!_isTracking) {
        return;
      }

      _onFrame(timeStamp);
      _scheduleFrameCallback(); // Schedule next frame
    });

    // Force a frame to be scheduled
    SchedulerBinding.instance.scheduleFrame();
  }

  /// Frame callback for FPS tracking
  void _onFrame(Duration timeStamp) {
    if (!_isTracking) {
      return;
    }

    final nowMicros = DateTime.now().microsecondsSinceEpoch;
    _frameTimestamps.add(nowMicros);
    _frameCount++;

    // Keep only last 2 seconds of frame timestamps
    final twoSecondsAgo = nowMicros - 2000000; // 2 seconds in microseconds
    _frameTimestamps.removeWhere((ts) => ts < twoSecondsAgo);
  }

  /// Calculate and emit performance metrics
  void _calculateMetrics() {
    if (!_isTracking) {
      return;
    }

    final now = DateTime.now();
    final nowMicros = now.microsecondsSinceEpoch;

    double fps;
    double frameTime;

    // Calculate FPS from frame timestamps in the last second
    final oneSecondAgo = nowMicros - 1000000; // 1 second in microseconds
    final recentFrames = _frameTimestamps.where((ts) => ts >= oneSecondAgo).toList();

    if (recentFrames.length >= 2) {
      // Calculate FPS: number of frames in the time window
      final timeSpan = recentFrames.last - recentFrames.first;
      if (timeSpan > 0) {
        // FPS = (number of frames - 1) / time span in seconds
        fps = ((recentFrames.length - 1) * 1000000 / timeSpan)
            .clamp(0.0, PerformanceConstants.maxFPS);

        // Calculate average frame time
        final frameTimes = <int>[];
        for (var i = 1; i < recentFrames.length; i++) {
          frameTimes.add(recentFrames[i] - recentFrames[i - 1]);
        }
        final avgFrameTimeMicros = frameTimes.isNotEmpty
            ? frameTimes.reduce((a, b) => a + b) / frameTimes.length
            : 16667; // Default 60 FPS
        frameTime = avgFrameTimeMicros / 1000; // Convert to milliseconds
      } else {
        fps = PerformanceConstants.targetFPS;
        frameTime = PerformanceConstants.targetFrameTime;
      }
    } else if (recentFrames.length == 1) {
      // Only one frame in window - app might be idle or just started
      fps = PerformanceConstants.targetFPS;
      frameTime = PerformanceConstants.targetFrameTime;
    } else {
      // No frames in the last second - app is completely idle
      fps = PerformanceConstants.targetFPS;
      frameTime = PerformanceConstants.targetFrameTime;
    }

    // Update FPS history
    _fpsHistory.add(fps);
    if (_fpsHistory.length > PerformanceConstants.chartDataPoints) {
      _fpsHistory.removeAt(0);
    }

    // Update statistics (always update to track idle periods correctly)
    if (_minFps == null || fps < _minFps!) {
      _minFps = fps;
    }
    if (_maxFps == null || fps > _maxFps!) {
      _maxFps = fps;
    }
    _totalFps = (_totalFps ?? 0.0) + fps;
    _fpsReadings++;

    final avgFps = _totalFps! / _fpsReadings;

    // Estimate CPU usage
    final cpuUsage = _estimateCPUUsage(fps, recentFrames.length);

    // Create metrics
    final metrics = PerformanceMetrics(
      fps: fps,
      frameTime: frameTime,
      frameCount: _frameCount,
      cpuUsage: cpuUsage,
      memoryUsage: _currentMemory,
      timestamp: now,
      minFps: _minFps,
      maxFps: _maxFps,
      avgFps: avgFps,
    );

    _metricsController.add(metrics);
  }

  /// Estimate CPU usage based on FPS and frame activity
  double _estimateCPUUsage(double fps, int recentFrameCount) {
    // If very few frames, app is idle
    if (recentFrameCount < 5) {
      return 5.0; // Idle CPU usage
    }

    // Simple heuristic: lower FPS = higher CPU usage
    if (fps >= PerformanceConstants.excellentFPS) {
      return 30.0;
    } else if (fps >= PerformanceConstants.goodFPS) {
      return 50.0;
    } else if (fps >= PerformanceConstants.poorFPS) {
      return 70.0;
    } else {
      return 90.0;
    }
  }

  /// Get FPS history for charts
  List<double> getFPSHistory() => List.unmodifiable(_fpsHistory);

  /// Get tracking duration
  Duration? getTrackingDuration() {
    if (_startTime == null) {
      return null;
    }
    return DateTime.now().difference(_startTime!);
  }

  /// Reset statistics
  void resetStatistics() {
    _minFps = null;
    _maxFps = null;
    _totalFps = 0.0;
    _fpsReadings = 0;
    _fpsHistory.clear();
    _frameCount = 0;
    _frameTimestamps.clear();

    if (_isTracking) {
      _startTime = DateTime.now();
    }

    developer.log(
      'Statistics reset',
      name: 'PerformanceTracker',
    );
  }

  /// Reset all state (for testing purposes)
  @visibleForTesting
  void resetAllState() {
    _minFps = null;
    _maxFps = null;
    _totalFps = 0.0;
    _fpsReadings = 0;
    _fpsHistory.clear();
    _frameCount = 0;
    _frameTimestamps.clear();
    _startTime = null;
    _currentMemory = 0.0;
    _isTracking = false;
    if (_updateTimer != null) {
      _updateTimer!.cancel();
      _updateTimer = null;
    }
  }

  /// Stop performance tracking
  void stopTracking() {
    if (!_isTracking) {
      return;
    }

    _isTracking = false;
    _updateTimer?.cancel();
    _updateTimer = null;
    _memoryProfiler.stopMonitoring();
    _frameTimestamps.clear();

    developer.log(
      'Performance tracking stopped',
      name: 'PerformanceTracker',
    );
  }

  /// Dispose all resources
  void dispose() {
    stopTracking();
    _metricsController.close();
    _memoryProfiler.dispose();
  }
}
