/// Performance monitoring constants
class PerformanceConstants {
  PerformanceConstants._();

  // FPS thresholds
  static const double excellentFPS = 55.0;
  static const double goodFPS = 40.0;
  static const double poorFPS = 25.0;
  static const double targetFPS = 55.0;
  static const double maxFPS = 60.0;

  // Frame time thresholds (milliseconds)
  static const double targetFrameTime = 16.67; // 60 FPS
  static const double acceptableFrameTime = 33.33; // 30 FPS
  static const double poorFrameTime = 50.0; // 20 FPS

  // Update intervals
  static const Duration defaultUpdateInterval = Duration(seconds: 1);
  static const Duration fastUpdateInterval = Duration(milliseconds: 500);
  static const Duration slowUpdateInterval = Duration(seconds: 2);

  // Data retention
  static const int maxHistoryDataPoints = 120; // 2 minutes at 1 sample/second
  static const int maxRecentFrames = 60;
  static const int chartDataPoints = 60;

  // Memory thresholds (MB)
  static const double lowMemoryThreshold = 50.0;
  static const double mediumMemoryThreshold = 100.0;
  static const double highMemoryThreshold = 200.0;
  static const double criticalMemoryThreshold = 500.0;

  // CPU thresholds (percentage)
  static const double lowCPUThreshold = 40.0;
  static const double mediumCPUThreshold = 70.0;
  static const double highCPUThreshold = 90.0;

  // UI constants
  static const double overlayOpacity = 0.9;
  static const double overlayPadding = 8.0;
  static const double overlayBorderRadius = 8.0;
  static const double overlayMinWidth = 100.0;
  static const double overlayMaxWidth = 250.0;

  // Animation durations
  static const Duration expandAnimationDuration = Duration(milliseconds: 200);
  static const Duration fadeAnimationDuration = Duration(milliseconds: 150);

  // Text styles
  static const double compactFontSize = 12.0;
  static const double detailedFontSize = 11.0;
  static const double titleFontSize = 14.0;
}
