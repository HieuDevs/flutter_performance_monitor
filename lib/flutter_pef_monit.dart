/// Flutter Performance Monitor Library
///
/// A comprehensive performance monitoring solution for Flutter applications.
///
/// Features:
/// - Real-time FPS monitoring
/// - Frame time tracking
/// - Memory usage monitoring
/// - CPU usage estimation
/// - Performance charts
/// - Customizable overlays
///
/// Example:
/// ```dart
/// import 'package:flutter_pef_monit/flutter_pef_monit.dart';
///
/// void main() {
///   runApp(
///     PerformanceOverlay(
///       enabled: true,
///       child: MyApp(),
///     ),
///   );
/// }
/// ```
library flutter_pef_monit;

export 'src/core/memory_profiler.dart';
// Core
export 'src/core/performance_tracker.dart';
// Models
export 'src/models/performance_metrics.dart';
// Utils
export 'src/utils/constants.dart';
export 'src/utils/helpers.dart';
export 'src/widgets/performance_chart.dart';
export 'src/widgets/performance_dialog.dart';
// Widgets
export 'src/widgets/performance_overlay.dart';
