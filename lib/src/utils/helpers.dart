import 'package:flutter/material.dart';
// External system information library (optional)
import 'package:system_info2/system_info2.dart';

import 'constants.dart';

/// Helper functions for performance monitoring
class PerformanceHelpers {
  PerformanceHelpers._();

  /// Get color based on FPS value
  static Color getFPSColor(double fps) {
    if (fps >= PerformanceConstants.excellentFPS) {
      return Colors.greenAccent;
    } else if (fps >= PerformanceConstants.goodFPS) {
      return Colors.yellowAccent;
    } else if (fps >= PerformanceConstants.poorFPS) {
      return Colors.orangeAccent;
    } else {
      return Colors.redAccent;
    }
  }

  /// Get color based on frame time
  static Color getFrameTimeColor(double frameTime) {
    if (frameTime <= PerformanceConstants.targetFrameTime) {
      return Colors.greenAccent; // 60 FPS
    } else if (frameTime <= PerformanceConstants.acceptableFrameTime) {
      return Colors.yellowAccent; // 30 FPS
    } else if (frameTime <= PerformanceConstants.poorFrameTime) {
      return Colors.orangeAccent; // 20 FPS
    } else {
      return Colors.redAccent;
    }
  }

  /// Get color based on CPU usage
  static Color getCPUColor(double cpuUsage) {
    if (cpuUsage <= PerformanceConstants.lowCPUThreshold) {
      return Colors.greenAccent;
    } else if (cpuUsage <= PerformanceConstants.mediumCPUThreshold) {
      return Colors.yellowAccent;
    } else if (cpuUsage <= PerformanceConstants.highCPUThreshold) {
      return Colors.orangeAccent;
    } else {
      return Colors.redAccent;
    }
  }

  /// Get color based on memory usage
  static Color getMemoryColor(double memoryMB) {
    if (memoryMB <= PerformanceConstants.lowMemoryThreshold) {
      return Colors.greenAccent;
    } else if (memoryMB <= PerformanceConstants.mediumMemoryThreshold) {
      return Colors.yellowAccent;
    } else if (memoryMB <= PerformanceConstants.highMemoryThreshold) {
      return Colors.orangeAccent;
    } else {
      return Colors.redAccent;
    }
  }

  /// Format bytes to readable string
  static String formatBytes(int bytes) {
    if (bytes < 0) return '0 B';
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) {
      return '${(bytes / 1024).toStringAsFixed(1)} KB';
    }
    if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }

  /// Get performance status text
  static String getPerformanceStatus(double fps) {
    if (fps >= PerformanceConstants.excellentFPS) {
      return 'Excellent';
    } else if (fps >= PerformanceConstants.goodFPS) {
      return 'Good';
    } else if (fps >= PerformanceConstants.poorFPS) {
      return 'Fair';
    } else {
      return 'Poor';
    }
  }

  /// Get performance icon
  static IconData getPerformanceIcon(double fps) {
    if (fps >= PerformanceConstants.excellentFPS) {
      return Icons.sentiment_very_satisfied;
    } else if (fps >= PerformanceConstants.goodFPS) {
      return Icons.sentiment_satisfied;
    } else if (fps >= PerformanceConstants.poorFPS) {
      return Icons.sentiment_neutral;
    } else {
      return Icons.sentiment_dissatisfied;
    }
  }

  /// Format duration to readable string
  static String formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);

    if (hours > 0) {
      return '${hours}h ${minutes}m ${seconds}s';
    } else if (minutes > 0) {
      return '${minutes}m ${seconds}s';
    } else {
      return '${seconds}s';
    }
  }

  /// Calculate average from list
  static double calculateAverage(List<double> values) {
    if (values.isEmpty) return 0.0;
    return values.reduce((a, b) => a + b) / values.length;
  }

  /// Get color with opacity
  static Color getColorWithOpacity(Color color, double opacity) {
    return color.withOpacity(opacity.clamp(0.0, 1.0));
  }

  /// Interpolate between two colors based on value
  static Color interpolateColor(
    double value,
    double min,
    double max,
    Color minColor,
    Color maxColor,
  ) {
    final ratio = ((value - min) / (max - min)).clamp(0.0, 1.0);
    return Color.lerp(minColor, maxColor, ratio) ?? minColor;
  }

  /// Get CPU core count using system_info2
  static int getCPUCoreCount() {
    try {
      return SysInfo.cores.length;
    } catch (e) {
      // Fallback to common core counts
      return _getEstimatedCPUCoreCount();
    }
  }

  /// Get estimated CPU core count
  static int _getEstimatedCPUCoreCount() {
    // Most modern devices have at least 4 cores
    return 4;
  }
}
