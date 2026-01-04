import 'package:flutter/material.dart';

import '../core/performance_tracker.dart';
import '../models/performance_metrics.dart';
import '../utils/constants.dart';
import '../utils/helpers.dart';
import 'performance_chart.dart';
import 'performance_dialog.dart';

/// Position of the performance overlay
enum PerformanceOverlayPosition {
  topLeft,
  topRight,
  bottomLeft,
  bottomRight,
}

/// Performance monitoring overlay widget
class PerformanceOverlay extends StatefulWidget {
  const PerformanceOverlay({
    super.key,
    required this.child,
    this.position = PerformanceOverlayPosition.topRight,
    this.enabled = true,
    this.backgroundColor = Colors.black87,
    this.textStyle,
    this.showDetailed = false,
    this.padding = const EdgeInsets.all(PerformanceConstants.overlayPadding),
    this.opacity = PerformanceConstants.overlayOpacity,
    this.updateInterval = PerformanceConstants.defaultUpdateInterval,
  });

  /// Child widget to wrap
  final Widget child;

  /// Position of the overlay
  final PerformanceOverlayPosition position;

  /// Enable/disable monitoring
  final bool enabled;

  /// Background color of overlay
  final Color backgroundColor;

  /// Custom text style
  final TextStyle? textStyle;

  /// Show detailed metrics by default
  final bool showDetailed;

  /// Padding around overlay content
  final EdgeInsets padding;

  /// Overlay opacity
  final double opacity;

  /// Update interval for metrics
  final Duration updateInterval;

  @override
  State<PerformanceOverlay> createState() => _PerformanceOverlayState();
}

class _PerformanceOverlayState extends State<PerformanceOverlay> {
  final PerformanceTracker _tracker = PerformanceTracker();
  PerformanceMetrics? _currentMetrics;
  bool _isExpanded = false;
  Offset _position = Offset.zero;

  @override
  void initState() {
    super.initState();
    _initializePosition();
    if (widget.enabled) {
      _tracker.startTracking(updateInterval: widget.updateInterval);
      _tracker.metricsStream.listen((metrics) {
        if (mounted) {
          setState(() {
            _currentMetrics = metrics;
          });
        }
      });
    }
  }

  @override
  void didUpdateWidget(PerformanceOverlay oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.enabled != oldWidget.enabled) {
      if (widget.enabled) {
        _tracker.startTracking(updateInterval: widget.updateInterval);
      } else {
        _tracker.stopTracking();
      }
    }
  }

  @override
  void dispose() {
    _tracker.stopTracking();
    super.dispose();
  }

  void _initializePosition() {
    // Initialize position based on the position enum
    // We'll use a post-frame callback to get the screen size
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      final screenSize = MediaQuery.of(context).size;
      const overlaySize = Size(120, 80); // Approximate initial size

      double left, top;
      switch (widget.position) {
        case PerformanceOverlayPosition.topLeft:
          left = 16;
          top = 40;
          break;
        case PerformanceOverlayPosition.topRight:
          left = screenSize.width - overlaySize.width - 16;
          top = 40;
          break;
        case PerformanceOverlayPosition.bottomLeft:
          left = 16;
          top = screenSize.height - overlaySize.height - 40;
          break;
        case PerformanceOverlayPosition.bottomRight:
          left = screenSize.width - overlaySize.width - 16;
          top = screenSize.height - overlaySize.height - 40;
          break;
      }

      setState(() {
        _position = Offset(left, top);
      });
    });
  }

  void _onPanUpdate(DragUpdateDetails details) {
    setState(() {
      _position += details.delta;

      // Apply screen constraints
      final screenSize = MediaQuery.of(context).size;
      const overlaySize = Size(120, 80); // Approximate size

      // Constrain to screen bounds with some padding
      _position = Offset(
        _position.dx.clamp(0.0, screenSize.width - overlaySize.width),
        _position.dy.clamp(0.0, screenSize.height - overlaySize.height),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.child,
        if (widget.enabled && _currentMetrics != null)
          Positioned(
            top: _position.dy,
            left: _position.dx,
            child: SafeArea(
              child: GestureDetector(
                onPanUpdate: _onPanUpdate,
                onTap: _toggleExpanded,
                onDoubleTap: _showChartDialog,
                onLongPress: _showDetailDialog,
                child: Opacity(
                  opacity: widget.opacity,
                  child: Material(
                    color: Colors.transparent,
                    child: Container(
                      constraints: const BoxConstraints(
                        minWidth: PerformanceConstants.overlayMinWidth,
                        maxWidth: PerformanceConstants.overlayMaxWidth,
                      ),
                      padding: widget.padding,
                      decoration: BoxDecoration(
                        color: widget.backgroundColor,
                        borderRadius: BorderRadius.circular(
                          PerformanceConstants.overlayBorderRadius,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: AnimatedCrossFade(
                        firstChild: _buildCompactView(),
                        secondChild: _buildDetailedView(),
                        crossFadeState: (_isExpanded || widget.showDetailed)
                            ? CrossFadeState.showSecond
                            : CrossFadeState.showFirst,
                        duration: PerformanceConstants.expandAnimationDuration,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  void _toggleExpanded() {
    setState(() {
      _isExpanded = !_isExpanded;
    });
  }

  void _showDetailDialog() {
    if (_currentMetrics == null) {
      return;
    }

    showDialog<void>(
      context: context,
      builder: (context) => PerformanceDialog(
        metrics: _currentMetrics!,
        tracker: _tracker,
      ),
    );
  }

  void _showChartDialog() {
    showDialog<void>(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          constraints: const BoxConstraints(maxWidth: 500, maxHeight: 400),
          child: const PerformanceChart(
            height: 300,
            maxDataPoints: 100,
            showGrid: true,
            showReferences: true,
          ),
        ),
      ),
    );
  }

  Widget _buildCompactView() {
    final fps = _currentMetrics!.fps;
    final color = PerformanceHelpers.getFPSColor(fps);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.speed, color: color, size: 16),
        const SizedBox(width: 4),
        Text(
          '${fps.toStringAsFixed(0)} FPS',
          style: widget.textStyle ??
              TextStyle(
                color: color,
                fontSize: PerformanceConstants.compactFontSize,
                fontWeight: FontWeight.bold,
                fontFamily: 'monospace',
              ),
        ),
      ],
    );
  }

  Widget _buildDetailedView() {
    final metrics = _currentMetrics!;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildMetricRow(
          'FPS',
          metrics.fps.toStringAsFixed(1),
          PerformanceHelpers.getFPSColor(metrics.fps),
          Icons.speed,
        ),
        const SizedBox(height: 4),
        _buildMetricRow(
          'Frame',
          '${metrics.frameTime.toStringAsFixed(1)} ms',
          PerformanceHelpers.getFrameTimeColor(metrics.frameTime),
          Icons.access_time,
        ),
        const SizedBox(height: 4),
        _buildMetricRow(
          'CPU',
          '${metrics.cpuUsage.toStringAsFixed(0)}%',
          PerformanceHelpers.getCPUColor(metrics.cpuUsage),
          Icons.memory,
        ),
        if (metrics.memoryUsage > 0) ...[
          const SizedBox(height: 4),
          _buildMetricRow(
            'Memory',
            '${metrics.memoryUsage.toStringAsFixed(0)} MB',
            PerformanceHelpers.getMemoryColor(metrics.memoryUsage),
            Icons.storage,
          ),
        ],
        const SizedBox(height: 4),
        _buildMetricRow(
          'Frames',
          '${metrics.frameCount}',
          Colors.grey,
          Icons.grid_on,
        ),
      ],
    );
  }

  Widget _buildMetricRow(
    String label,
    String value,
    Color color,
    IconData icon,
  ) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: color, size: 14),
        const SizedBox(width: 4),
        Flexible(
          child: Text(
            label,
            style: widget.textStyle ??
                TextStyle(
                  color: Colors.grey.shade300,
                  fontSize: PerformanceConstants.detailedFontSize,
                  fontFamily: 'monospace',
                ),
          ),
        ),
        const SizedBox(width: 4),
        Text(
          value,
          style: widget.textStyle ??
              TextStyle(
                color: color,
                fontSize: PerformanceConstants.detailedFontSize,
                fontWeight: FontWeight.bold,
                fontFamily: 'monospace',
              ),
        ),
      ],
    );
  }
}
