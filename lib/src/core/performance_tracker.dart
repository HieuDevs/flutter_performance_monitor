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

  // FPS tracking
  final List<Duration> _frameDurations = [];
  final List<double> _fpsHistory = [];
  int _frameCount = 0;
  DateTime? _lastFrameTime;
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

  bool _isTracking = false;
  bool get isTracking => _isTracking;

  /// Start performance tracking
  void startTracking({
    Duration updateInterval = PerformanceConstants.defaultUpdateInterval,
  }) {
    if (_isTracking) return;

    _isTracking = true;
    _frameCount = 0;
    _frameDurations.clear();
    _fpsHistory.clear();
    _lastFrameTime = DateTime.now();
    _startTime = DateTime.now();
    _minFps = null;
    _maxFps = null;
    _totalFps = 0.0;
    _fpsReadings = 0;

    // Start frame callback
    SchedulerBinding.instance.addPostFrameCallback(_onFrame);

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

  /// Frame callback for FPS tracking
  void _onFrame(Duration duration) {
    if (!_isTracking) return;

    final now = DateTime.now();
    if (_lastFrameTime != null) {
      final frameDuration = now.difference(_lastFrameTime!);
      _frameDurations.add(frameDuration);

      // Keep only recent frames
      if (_frameDurations.length > PerformanceConstants.maxRecentFrames) {
        _frameDurations.removeAt(0);
      }
    }

    _frameCount++;
    _lastFrameTime = now;

    // Schedule next frame callback
    SchedulerBinding.instance.addPostFrameCallback(_onFrame);
  }

  /// Calculate and emit performance metrics
  void _calculateMetrics() {
    if (_frameDurations.isEmpty || !_isTracking) return;

    // Calculate average frame duration
    final avgFrameDuration =
        _frameDurations.map((d) => d.inMicroseconds).reduce((a, b) => a + b) /
            _frameDurations.length;

    // Calculate FPS
    final fps =
        (1000000 / avgFrameDuration).clamp(0.0, PerformanceConstants.maxFPS);
    final frameTime = avgFrameDuration / 1000; // Convert to milliseconds

    // Update FPS history
    _fpsHistory.add(fps);
    if (_fpsHistory.length > PerformanceConstants.chartDataPoints) {
      _fpsHistory.removeAt(0);
    }

    // Update statistics
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
    final cpuUsage = _estimateCPUUsage(fps);

    // Create metrics
    final metrics = PerformanceMetrics(
      fps: fps,
      frameTime: frameTime,
      frameCount: _frameCount,
      cpuUsage: cpuUsage,
      memoryUsage: _currentMemory,
      timestamp: DateTime.now(),
      minFps: _minFps,
      maxFps: _maxFps,
      avgFps: avgFps,
    );

    _metricsController.add(metrics);
  }

  /// Estimate CPU usage based on FPS
  double _estimateCPUUsage(double fps) {
    // Simple heuristic: lower FPS = higher CPU usage
    // This is a rough estimation
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
    if (_startTime == null) return null;
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
    // Only reset start time if currently tracking
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
    _frameDurations.clear();
    _lastFrameTime = null;
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
    if (!_isTracking) return;

    _isTracking = false;
    _updateTimer?.cancel();
    _updateTimer = null;
    _memoryProfiler.stopMonitoring();
    _frameDurations.clear();

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
