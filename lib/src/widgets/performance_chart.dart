import 'package:flutter/material.dart';
import '../core/performance_tracker.dart';
import '../models/performance_metrics.dart';
import '../utils/constants.dart';
import '../utils/helpers.dart';

/// Performance chart widget displaying FPS history
class PerformanceChart extends StatefulWidget {
  const PerformanceChart({
    super.key,
    this.maxDataPoints = PerformanceConstants.chartDataPoints,
    this.updateInterval = PerformanceConstants.defaultUpdateInterval,
    this.height = 200,
    this.showGrid = true,
    this.showReferences = true,
  });

  /// Maximum number of data points to display
  final int maxDataPoints;

  /// Update interval for chart
  final Duration updateInterval;

  /// Height of the chart
  final double height;

  /// Show grid lines
  final bool showGrid;

  /// Show FPS reference lines
  final bool showReferences;

  @override
  State<PerformanceChart> createState() => _PerformanceChartState();
}

class _PerformanceChartState extends State<PerformanceChart> {
  final PerformanceTracker _tracker = PerformanceTracker();
  final List<double> _fpsData = [];
  PerformanceMetrics? _latestMetrics;

  @override
  void initState() {
    super.initState();
    _tracker.startTracking(updateInterval: widget.updateInterval);
    _tracker.metricsStream.listen((metrics) {
      if (mounted) {
        setState(() {
          _latestMetrics = metrics;
          _fpsData.add(metrics.fps);

          if (_fpsData.length > widget.maxDataPoints) {
            _fpsData.removeAt(0);
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _tracker.stopTracking();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: widget.height,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.black87,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          const SizedBox(height: 16),
          Expanded(
            child: _fpsData.isEmpty
                ? _buildEmptyState()
                : CustomPaint(
                    painter: _ChartPainter(
                      data: _fpsData,
                      showGrid: widget.showGrid,
                      showReferences: widget.showReferences,
                    ),
                    size: Size.infinite,
                  ),
          ),
          if (_latestMetrics != null) ...[
            const SizedBox(height: 8),
            _buildStats(),
          ],
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        const Icon(
          Icons.show_chart,
          color: Colors.white,
          size: 20,
        ),
        const SizedBox(width: 8),
        const Text(
          'Performance Monitor',
          style: TextStyle(
            color: Colors.white,
            fontSize: PerformanceConstants.titleFontSize,
            fontWeight: FontWeight.bold,
          ),
        ),
        const Spacer(),
        if (_latestMetrics != null)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: PerformanceHelpers.getFPSColor(_latestMetrics!.fps)
                  .withOpacity(0.2),
              borderRadius: BorderRadius.circular(4),
              border: Border.all(
                color: PerformanceHelpers.getFPSColor(_latestMetrics!.fps),
                width: 1,
              ),
            ),
            child: Text(
              PerformanceHelpers.getPerformanceStatus(_latestMetrics!.fps),
              style: TextStyle(
                color: PerformanceHelpers.getFPSColor(_latestMetrics!.fps),
                fontSize: 11,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.hourglass_empty,
            color: Colors.grey,
            size: 48,
          ),
          SizedBox(height: 8),
          Text(
            'Collecting performance data...',
            style: TextStyle(
              color: Colors.grey,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStats() {
    final metrics = _latestMetrics!;

    return Row(
      children: [
        _buildStatItem(
          'Current',
          '${metrics.fps.toStringAsFixed(0)} FPS',
          PerformanceHelpers.getFPSColor(metrics.fps),
        ),
        const SizedBox(width: 16),
        if (metrics.minFps != null)
          _buildStatItem(
            'Min',
            metrics.minFps!.toStringAsFixed(0),
            Colors.grey,
          ),
        const SizedBox(width: 16),
        if (metrics.maxFps != null)
          _buildStatItem(
            'Max',
            metrics.maxFps!.toStringAsFixed(0),
            Colors.grey,
          ),
        const SizedBox(width: 16),
        if (metrics.avgFps != null)
          _buildStatItem(
            'Avg',
            metrics.avgFps!.toStringAsFixed(0),
            Colors.grey,
          ),
      ],
    );
  }

  Widget _buildStatItem(String label, String value, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.grey[400],
            fontSize: 10,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            color: color,
            fontSize: 12,
            fontWeight: FontWeight.bold,
            fontFamily: 'monospace',
          ),
        ),
      ],
    );
  }
}

class _ChartPainter extends CustomPainter {
  _ChartPainter({
    required this.data,
    required this.showGrid,
    required this.showReferences,
  });
  final List<double> data;
  final bool showGrid;
  final bool showReferences;

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty) return;

    const maxFPS = PerformanceConstants.maxFPS;

    // Draw grid
    if (showGrid) {
      _drawGrid(canvas, size);
    }

    // Draw reference lines
    if (showReferences) {
      _drawReferenceLine(
        canvas,
        size,
        PerformanceConstants.targetFPS,
        maxFPS,
        Colors.yellowAccent.withOpacity(0.3),
        '60 FPS',
      );
    }

    // Draw FPS line
    _drawFPSLine(canvas, size, maxFPS);
  }

  void _drawGrid(Canvas canvas, Size size) {
    final gridPaint = Paint()
      ..color = Colors.grey.withOpacity(0.1)
      ..strokeWidth = 1;

    // Horizontal lines
    for (var i = 0; i <= 4; i++) {
      final y = size.height * (i / 4);
      canvas.drawLine(
        Offset(0, y),
        Offset(size.width, y),
        gridPaint,
      );
    }

    // Vertical lines
    for (var i = 0; i <= 5; i++) {
      final x = size.width * (i / 5);
      canvas.drawLine(
        Offset(x, 0),
        Offset(x, size.height),
        gridPaint,
      );
    }
  }

  void _drawReferenceLine(
    Canvas canvas,
    Size size,
    double fps,
    double maxFPS,
    Color color,
    String label,
  ) {
    final y = size.height - (fps / maxFPS * size.height);
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    canvas.drawLine(
      Offset(0, y),
      Offset(size.width, y),
      paint,
    );

    // Draw label
    final textPainter = TextPainter(
      text: TextSpan(
        text: label,
        style: TextStyle(
          color: color,
          fontSize: 10,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(canvas, Offset(4, y - 14));
  }

  void _drawFPSLine(Canvas canvas, Size size, double maxFPS) {
    if (data.isEmpty) return;

    final path = Path();
    final gradientPath = Path();

    for (var i = 0; i < data.length; i++) {
      // Handle edge case when data.length == 1
      final x = data.length == 1
          ? size.width / 2
          : (size.width / (data.length - 1)) * i;
      final fps = data[i].clamp(0.0, maxFPS);
      final y = size.height - (fps / maxFPS * size.height);

      if (i == 0) {
        path.moveTo(x, y);
        gradientPath.moveTo(x, size.height);
        gradientPath.lineTo(x, y);
      } else {
        path.lineTo(x, y);
        gradientPath.lineTo(x, y);
      }
    }

    // Close gradient path
    gradientPath.lineTo(size.width, size.height);
    gradientPath.close();

    // Draw gradient fill
    final gradientPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Colors.greenAccent.withOpacity(0.3),
          Colors.greenAccent.withOpacity(0.0),
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    canvas.drawPath(gradientPath, gradientPaint);

    // Draw line
    final linePaint = Paint()
      ..color = Colors.greenAccent
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    canvas.drawPath(path, linePaint);

    // Draw points
    final pointPaint = Paint()
      ..color = Colors.greenAccent
      ..style = PaintingStyle.fill;

    for (var i = 0; i < data.length; i++) {
      if (i % 3 == 0) {
        // Draw every 3rd point to avoid clutter
        // Handle edge case when data.length == 1
        final x = data.length == 1
            ? size.width / 2
            : (size.width / (data.length - 1)) * i;
        final fps = data[i].clamp(0.0, maxFPS);
        final y = size.height - (fps / maxFPS * size.height);
        canvas.drawCircle(Offset(x, y), 2, pointPaint);
      }
    }
  }

  @override
  bool shouldRepaint(_ChartPainter oldDelegate) =>
      data != oldDelegate.data ||
      showGrid != oldDelegate.showGrid ||
      showReferences != oldDelegate.showReferences;
}
