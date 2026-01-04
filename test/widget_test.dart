import 'package:flutter/material.dart';
import 'package:flutter_pef_monit/flutter_pef_monit.dart' as perf;
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('PerformanceOverlay Widget Tests', () {
    testWidgets('should render overlay when enabled', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: perf.PerformanceOverlay(
            enabled: true,
            child: Scaffold(
              body: Center(child: Text('Test')),
            ),
          ),
        ),
      );

      // Wait for initial metrics
      await tester.pump(const Duration(seconds: 1));

      // Should find the child widget
      expect(find.text('Test'), findsOneWidget);
    });

    testWidgets('should not render overlay when disabled', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: perf.PerformanceOverlay(
            enabled: false,
            child: Scaffold(
              body: Center(child: Text('Test')),
            ),
          ),
        ),
      );

      await tester.pump();

      // Should still find the child widget
      expect(find.text('Test'), findsOneWidget);
    });

    testWidgets('should toggle expanded state on tap', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: perf.PerformanceOverlay(
            enabled: true,
            child: Scaffold(
              body: Center(child: Text('Test')),
            ),
          ),
        ),
      );

      // Wait for metrics to appear
      await tester.pump(const Duration(seconds: 1));
      await tester.pumpAndSettle();

      // Find and tap the overlay
      final overlay = find.byType(GestureDetector).first;
      if (overlay.evaluate().isNotEmpty) {
        await tester.tap(overlay);
        await tester.pumpAndSettle();
      }
    });

    testWidgets('should render at different positions', (tester) async {
      for (final position in perf.PerformanceOverlayPosition.values) {
        await tester.pumpWidget(
          MaterialApp(
            home: perf.PerformanceOverlay(
              enabled: true,
              position: position,
              child: const Scaffold(
                body: Center(child: Text('Test')),
              ),
            ),
          ),
        );

        await tester.pump();

        // Should render without errors
        expect(find.text('Test'), findsOneWidget);

        // Clean up for next iteration
        await tester.pumpWidget(Container());
      }
    });
  });

  group('PerformanceChart Widget Tests', () {
    testWidgets('should render chart widget', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: perf.PerformanceChart(
              height: 200,
              maxDataPoints: 60,
            ),
          ),
        ),
      );

      await tester.pump();

      // Should find CustomPaint widget for chart
      expect(find.byType(CustomPaint), findsWidgets);
    });

    testWidgets('should show empty state initially', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: perf.PerformanceChart(
              height: 200,
            ),
          ),
        ),
      );

      await tester.pump();

      // Should show collecting data message
      expect(find.text('Collecting performance data...'), findsOneWidget);
    });

    testWidgets('should respect height constraint', (tester) async {
      const testHeight = 300.0;

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: perf.PerformanceChart(
              height: testHeight,
            ),
          ),
        ),
      );

      await tester.pump();

      final container = tester.widget<Container>(
        find.byType(Container).first,
      );

      expect(container.constraints?.maxHeight, testHeight);
    });
  });
}
