# Flutter Performance Monitor Example

This comprehensive example app demonstrates all features of the `flutter_pef_monit` package with interactive performance testing scenarios.

## Features Demonstrated

- **PerformanceOverlay**: Floating real-time performance monitor
- **PerformanceChart**: Interactive FPS history visualization
- **PerformanceDialog**: Detailed metrics and statistics
- **Advanced Testing**: Multiple performance stress testing scenarios
- **Interactive Controls**: Live configuration of performance parameters
- **Real-time Monitoring**: Live FPS, memory, CPU, and frame time tracking

## Getting Started

1. **Install dependencies:**
   ```bash
   flutter pub get
   ```

2. **Run the app:**
   ```bash
   flutter run
   ```

## Demo Features

### Performance Testing Controls

The app includes a comprehensive control panel with:

- **Performance Chart Toggle**: Show/hide real-time FPS graph
- **Heavy Animation Test**: GPU-intensive rotating gradient animation
- **Animation Speed Control**: Adjustable animation speed (0.5x - 5.0x)
- **Scrollable List Test**: Large list rendering performance
- **List Size Control**: Adjustable list items (100 - 5000)

### Stress Testing

- **Stress Test Button**: One-click extreme performance testing
- **Automatic Configuration**: Enables all tests simultaneously
- **Real-time Feedback**: Watch performance metrics respond to load

### Performance Visualization

- **Real-time Overlay**: Always-visible performance metrics
- **Interactive Chart**: 60-point FPS history with trend analysis
- **Color-coded Metrics**: Visual performance status indicators
- **Detailed Dialog**: Comprehensive statistics and data export

## Usage Guide

### Basic Interaction

1. **Performance Overlay** (top-right):
   - **Tap**: Toggle compact/detailed view
   - **Long press**: Open detailed metrics dialog

2. **Control Panel** (middle section):
   - Enable/disable different performance tests
   - Adjust parameters with sliders
   - Monitor current settings

3. **Content Area** (bottom):
   - View active performance tests
   - Interact with scrollable lists
   - Observe visual effects

4. **Floating Actions**:
   - **Refresh**: Force UI rebuild
   - **Stress Test**: One-click extreme testing

### Performance Testing Scenarios

#### Heavy Animation Test
- Rotating gradient container with shadows
- Adjustable speed from 0.5x to 5.0x
- Tests GPU rendering performance
- Visual complexity stress test

#### Scrollable List Test
- Large lists from 100 to 5000 items
- Card-based layout with interactions
- Tests UI rendering and scrolling performance
- Memory usage scaling test

#### Combined Stress Test
- Enables all tests simultaneously
- Maximum performance load scenario
- Real-time performance degradation observation

## API Usage Examples

### Complete App Integration
```dart
import 'package:flutter/material.dart';
import 'package:flutter_pef_monit/flutter_pef_monit.dart';

void main() {
  runApp(
    MaterialApp(
      home: PerformanceOverlay(
        enabled: true,
        position: PerformanceOverlayPosition.topRight,
        child: MyHomePage(),
      ),
    ),
  );
}
```

### Advanced Configuration
```dart
PerformanceOverlay(
  enabled: true,
  position: PerformanceOverlayPosition.bottomLeft,
  showDetailed: false,
  backgroundColor: Colors.black87,
  opacity: 0.9,
  updateInterval: Duration(milliseconds: 250),
  child: MyApp(),
)
```

### Chart Integration
```dart
Column(
  children: [
    PerformanceChart(
      height: 200,
      maxDataPoints: 60,
      showGrid: true,
      showReferences: true,
    ),
    // Your app content
  ],
)
```

### Programmatic Control
```dart
final tracker = PerformanceTracker();

// Start monitoring
tracker.startTracking();

// Listen to metrics
tracker.metricsStream.listen((metrics) {
  print('FPS: ${metrics.fps}');
  print('Memory: ${metrics.memoryUsage} MB');
});

// Get statistics
final duration = tracker.getTrackingDuration();
tracker.resetStatistics();
```

## Performance Insights

### What to Observe

- **FPS Changes**: Watch how different tests affect frame rate
- **Memory Scaling**: See memory usage increase with list size
- **CPU Estimation**: Observe CPU load based on animation complexity
- **Frame Time**: Monitor rendering time variations

### Expected Results

- **Heavy Animation**: Significant FPS drop with higher speeds
- **Large Lists**: Gradual performance degradation with size
- **Combined Tests**: Severe performance impact under stress
- **Recovery**: Quick performance restoration when tests disabled

## Advanced Features

### Data Export
- Long press overlay to access detailed dialog
- Copy performance data to clipboard
- Reset statistics functionality
- Session duration tracking

### Real-time Statistics
- Min/Max/Average FPS tracking
- Session-based performance analysis
- Frame count monitoring
- Memory usage trends

## Platform Considerations

- **Android/iOS**: Full memory monitoring with `system_info2`
- **Web**: FPS monitoring only (memory shows 0)
- **Desktop**: Complete feature support
- **Performance Impact**: Minimal overhead from monitoring

## Troubleshooting

### Common Issues

- **No Overlay Visible**: Check if `enabled: true`
- **Memory Shows 0**: Normal on web platform
- **Chart Not Updating**: Ensure chart toggle is enabled
- **Poor Performance**: Expected under stress testing

### Debug Tips

- Use device developer options for additional metrics
- Monitor console for performance tracker logs
- Check platform-specific memory limitations
- Compare performance across different devices

## Learn More

- **[Main Package README](../README.md)**: Complete API documentation
- **[Performance Constants](../lib/src/utils/constants.dart)**: Configuration options
- **[Performance Helpers](../lib/src/utils/helpers.dart)**: Utility functions
- **[Performance Metrics](../lib/src/models/performance_metrics.dart)**: Data models

---

**Happy Performance Monitoring! 🚀**

Watch your Flutter apps perform their best with real-time insights and comprehensive testing tools.
