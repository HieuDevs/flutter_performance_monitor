/// Performance metrics data model
class PerformanceMetrics {
  const PerformanceMetrics({
    required this.fps,
    required this.frameTime,
    required this.frameCount,
    required this.cpuUsage,
    required this.memoryUsage,
    required this.timestamp,
    this.minFps,
    this.maxFps,
    this.avgFps,
  });

  /// Create from map
  factory PerformanceMetrics.fromMap(Map<String, dynamic> map) {
    return PerformanceMetrics(
      fps: map['fps'] as double,
      frameTime: map['frameTime'] as double,
      frameCount: map['frameCount'] as int,
      cpuUsage: map['cpuUsage'] as double,
      memoryUsage: map['memoryUsage'] as double,
      timestamp: DateTime.parse(map['timestamp'] as String),
      minFps: map['minFps'] as double?,
      maxFps: map['maxFps'] as double?,
      avgFps: map['avgFps'] as double?,
    );
  }

  /// Frames per second
  final double fps;

  /// Frame render time in milliseconds
  final double frameTime;

  /// Total frame count since tracking started
  final int frameCount;

  /// Estimated CPU usage percentage (0-100)
  final double cpuUsage;

  /// Memory usage in megabytes
  final double memoryUsage;

  /// Timestamp when metrics were collected
  final DateTime timestamp;

  /// Minimum FPS in current session
  final double? minFps;

  /// Maximum FPS in current session
  final double? maxFps;

  /// Average FPS in current session
  final double? avgFps;

  /// Create a copy with updated values
  PerformanceMetrics copyWith({
    double? fps,
    double? frameTime,
    int? frameCount,
    double? cpuUsage,
    double? memoryUsage,
    DateTime? timestamp,
    double? minFps,
    double? maxFps,
    double? avgFps,
  }) {
    return PerformanceMetrics(
      fps: fps ?? this.fps,
      frameTime: frameTime ?? this.frameTime,
      frameCount: frameCount ?? this.frameCount,
      cpuUsage: cpuUsage ?? this.cpuUsage,
      memoryUsage: memoryUsage ?? this.memoryUsage,
      timestamp: timestamp ?? this.timestamp,
      minFps: minFps ?? this.minFps,
      maxFps: maxFps ?? this.maxFps,
      avgFps: avgFps ?? this.avgFps,
    );
  }

  /// Convert to map
  Map<String, dynamic> toMap() {
    return {
      'fps': fps,
      'frameTime': frameTime,
      'frameCount': frameCount,
      'cpuUsage': cpuUsage,
      'memoryUsage': memoryUsage,
      'timestamp': timestamp.toIso8601String(),
      'minFps': minFps,
      'maxFps': maxFps,
      'avgFps': avgFps,
    };
  }

  @override
  String toString() {
    return 'PerformanceMetrics(fps: ${fps.toStringAsFixed(1)}, '
        'frameTime: ${frameTime.toStringAsFixed(2)}ms, '
        'frameCount: $frameCount, '
        'cpuUsage: ${cpuUsage.toStringAsFixed(1)}%, '
        'memoryUsage: ${memoryUsage.toStringAsFixed(1)}MB)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }

    return other is PerformanceMetrics &&
        other.fps == fps &&
        other.frameTime == frameTime &&
        other.frameCount == frameCount &&
        other.cpuUsage == cpuUsage &&
        other.memoryUsage == memoryUsage &&
        other.timestamp == timestamp;
  }

  @override
  int get hashCode {
    return Object.hash(
      fps,
      frameTime,
      frameCount,
      cpuUsage,
      memoryUsage,
      timestamp,
    );
  }
}
