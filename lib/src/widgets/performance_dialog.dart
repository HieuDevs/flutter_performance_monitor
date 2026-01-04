import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../core/performance_tracker.dart';
import '../models/performance_metrics.dart';
import '../utils/helpers.dart';

/// Detailed performance information dialog
class PerformanceDialog extends StatelessWidget {
  const PerformanceDialog({
    super.key,
    required this.metrics,
    required this.tracker,
  });
  final PerformanceMetrics metrics;
  final PerformanceTracker tracker;

  @override
  Widget build(BuildContext context) {
    final duration = tracker.getTrackingDuration();

    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 400, maxHeight: 600),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.black87,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.5),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Icon(
                    PerformanceHelpers.getPerformanceIcon(metrics.fps),
                    color: PerformanceHelpers.getFPSColor(metrics.fps),
                    size: 32,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Performance Details',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          PerformanceHelpers.getPerformanceStatus(metrics.fps),
                          style: TextStyle(
                            color: PerformanceHelpers.getFPSColor(metrics.fps),
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const Divider(color: Colors.grey, height: 32),

              // Metrics
              _buildMetricCard(
                'FPS (Frames Per Second)',
                metrics.fps.toStringAsFixed(2),
                PerformanceHelpers.getFPSColor(metrics.fps),
                Icons.speed,
                subtitle: 'Target: 60 FPS',
              ),
              const SizedBox(height: 12),
              _buildMetricCard(
                'Frame Time',
                '${metrics.frameTime.toStringAsFixed(2)} ms',
                PerformanceHelpers.getFrameTimeColor(metrics.frameTime),
                Icons.access_time,
                subtitle: 'Target: ≤16.67 ms',
              ),
              const SizedBox(height: 12),
              _buildMetricCard(
                'CPU Usage (Estimated)',
                '${metrics.cpuUsage.toStringAsFixed(1)}%',
                PerformanceHelpers.getCPUColor(metrics.cpuUsage),
                Icons.memory,
              ),
              if (metrics.memoryUsage > 0) ...[
                const SizedBox(height: 12),
                _buildMetricCard(
                  'Memory Usage',
                  '${metrics.memoryUsage.toStringAsFixed(1)} MB',
                  PerformanceHelpers.getMemoryColor(metrics.memoryUsage),
                  Icons.storage,
                ),
              ],

              const Divider(color: Colors.grey, height: 32),

              // Statistics
              const Text(
                'Statistics',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              _buildStatRow('Total Frames', '${metrics.frameCount}'),
              if (metrics.minFps != null)
                _buildStatRow(
                    'Minimum FPS', metrics.minFps!.toStringAsFixed(1)),
              if (metrics.maxFps != null)
                _buildStatRow(
                    'Maximum FPS', metrics.maxFps!.toStringAsFixed(1)),
              if (metrics.avgFps != null)
                _buildStatRow(
                    'Average FPS', metrics.avgFps!.toStringAsFixed(1)),
              if (duration != null)
                _buildStatRow(
                  'Tracking Duration',
                  PerformanceHelpers.formatDuration(duration),
                ),

              const SizedBox(height: 20),

              // Actions
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        _copyToClipboard(context);
                      },
                      icon: const Icon(Icons.copy, size: 18),
                      label: const Text('Copy Data'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.white,
                        side: const BorderSide(color: Colors.grey),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        tracker.resetStatistics();
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Statistics reset'),
                            duration: Duration(seconds: 2),
                          ),
                        );
                        Navigator.of(context).pop();
                      },
                      icon: const Icon(Icons.refresh, size: 18),
                      label: const Text('Reset'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMetricCard(
    String title,
    String value,
    Color color,
    IconData icon, {
    String? subtitle,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: Colors.grey.shade400,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: TextStyle(
                    color: color,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'monospace',
                  ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 10,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: Colors.grey.shade400,
              fontSize: 13,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.bold,
              fontFamily: 'monospace',
            ),
          ),
        ],
      ),
    );
  }

  void _copyToClipboard(BuildContext context) {
    final data = metrics.toMap();
    final text = data.entries.map((e) => '${e.key}: ${e.value}').join('\n');

    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Performance data copied to clipboard'),
        duration: Duration(seconds: 2),
      ),
    );
  }
}
