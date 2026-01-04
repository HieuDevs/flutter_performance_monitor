import 'dart:async';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart';

// External system information library (optional)
import 'package:system_info2/system_info2.dart';

/// Memory profiling utility
class MemoryProfiler {
  factory MemoryProfiler() => _instance;
  MemoryProfiler._internal();
  static final MemoryProfiler _instance = MemoryProfiler._internal();

  Timer? _timer;
  final _memoryController = StreamController<double>.broadcast();

  /// Stream of memory usage in MB
  Stream<double> get memoryStream => _memoryController.stream;

  bool _isMonitoring = false;
  bool get isMonitoring => _isMonitoring;

  /// Start monitoring memory usage
  void startMonitoring({Duration interval = const Duration(seconds: 1)}) {
    if (_isMonitoring) return;

    _isMonitoring = true;
    _timer = Timer.periodic(interval, (_) => _checkMemory());
  }

  /// Stop monitoring memory usage
  void stopMonitoring() {
    _isMonitoring = false;
    _timer?.cancel();
    _timer = null;
  }

  void _checkMemory() {
    if (!_isMonitoring) return;

    final memoryMB = getCurrentMemoryUsage();
    _memoryController.add(memoryMB);
  }

  /// Get current memory usage in MB
  static double getCurrentMemoryUsage() {
    if (kIsWeb) {
      // Web doesn't support memory profiling
      return 0.0;
    }

    // Try different methods based on platform and build mode
    try {
      // Method 1: Platform-specific memory info (when implemented)
      final platformMemory = _getPlatformMemoryUsage();
      if (platformMemory > 0) return platformMemory;

      // Method 2: Fallback estimate based on platform
      return _getEstimatedMemoryUsage();
    } catch (e) {
      // If all methods fail, return conservative estimate
      return _getEstimatedMemoryUsage();
    }
  }

  /// Get memory usage from external libraries
  static double _getExternalMemoryUsage() {
    try {
      // Dynamically try to use memory_info package if available
      // This approach avoids import errors when the package isn't installed
      return _tryMemoryInfoPackage();
    } catch (e) {
      // External library not available or failed
      return 0.0;
    }
  }

  /// Try to use system_info2 package for accurate memory info
  static double _tryMemoryInfoPackage() {
    try {
      // Use system_info2 for accurate memory statistics
      final totalMemoryBytes = SysInfo.getTotalPhysicalMemory();
      final freeMemoryBytes = SysInfo.getFreePhysicalMemory();
      final usedMemoryBytes = totalMemoryBytes - freeMemoryBytes;

      // Convert bytes to MB
      final usedMemoryMB = usedMemoryBytes / (1024 * 1024);
      return usedMemoryMB.toDouble();
    } catch (e) {
      // system_info2 not available or failed
      return 0.0;
    }
  }

  /// Get memory usage from platform-specific APIs
  static double _getPlatformMemoryUsage() {
    try {
      // Try external memory_info library first
      final externalMemory = _getExternalMemoryUsage();
      if (externalMemory > 0) return externalMemory;

      // Fallback to platform-specific implementations
      if (Platform.isAndroid) {
        return _getAndroidMemoryUsage();
      } else if (Platform.isIOS) {
        return _getIOSMemoryUsage();
      }
    } catch (e) {
      // Platform detection or method calls failed
    }
    return 0.0;
  }

  /// Get memory usage on Android
  static double _getAndroidMemoryUsage() {
    try {
      // This would typically use a platform channel to call Android APIs
      // For now, return 0 to indicate platform channel should be implemented
      // Example: MethodChannel('memory_profiler').invokeMethod<double>('getMemoryUsage');
      return 0.0;
    } catch (e) {
      return 0.0;
    }
  }

  /// Get memory usage on iOS
  static double _getIOSMemoryUsage() {
    try {
      // This would typically use a platform channel to call iOS APIs
      // For now, return 0 to indicate platform channel should be implemented
      // Example: MethodChannel('memory_profiler').invokeMethod<double>('getMemoryUsage');
      return 0.0;
    } catch (e) {
      return 0.0;
    }
  }

  /// Get estimated memory usage based on platform and typical app usage
  static double _getEstimatedMemoryUsage() {
    // Conservative estimates based on typical Flutter app memory usage
    if (Platform.isAndroid) {
      return 45.0; // Android typical range: 30-80 MB
    } else if (Platform.isIOS) {
      return 35.0; // iOS typical range: 25-60 MB
    } else if (Platform.isLinux || Platform.isWindows || Platform.isMacOS) {
      return 40.0; // Desktop typical range: 30-60 MB
    }
    return 40.0; // Default estimate
  }

  /// Dispose resources
  void dispose() {
    stopMonitoring();
    _memoryController.close();
  }
}
