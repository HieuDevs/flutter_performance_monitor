# Flutter Performance Monitor 📊

[![pub package](https://img.shields.io/pub/v/flutter_pef_monit.svg)](https://pub.dev/packages/flutter_pef_monit)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

A comprehensive performance monitoring library for Flutter applications. Track FPS, frame time, memory usage, and CPU in real-time with beautiful overlays and charts.

![Performance Monitor Demo](screenshots/demo.gif)

## ✨ Features

- 📊 **Real-time FPS monitoring** with color-coded indicators
- ⏱️ **Frame time tracking** in milliseconds
- 💾 **Memory usage monitoring**
- 🔥 **CPU usage estimation**
- 📈 **Performance history chart** with customizable data points
- 🎨 **Customizable overlay** with multiple positions
- 👆 **Interactive UI** - Tap to expand/collapse, long press for details
- 🎯 **Zero dependencies** (Flutter SDK only)
- 🚀 **Production-ready** with comprehensive testing
- 📱 **Cross-platform** support (iOS, Android, Web, Desktop)

## 📸 Screenshots

| Compact View | Expanded View | Chart View |
|--------------|---------------|------------|
| ![Compact](screenshots/compact.png) | ![Expanded](screenshots/expanded.png) | ![Chart](screenshots/chart.png) |

## 🚀 Getting Started

### Installation

Add this to your package's `pubspec.yaml` file:
```yaml
dependencies:
  flutter_pef_monit: ^1.0.0
```

Then run:
```bash
flutter pub get
```

### Basic Usage

Wrap your app with `PerformanceOverlay`:
```dart
import 'package:flutter_pef_monit/flutter_pef_monit.dart';

void main() {
  runApp(
    PerformanceOverlay(
      enabled: true,
      child: MyApp(),
    ),
  );
}
```

### Advanced Usage

#### Customize Position and Appearance
```dart
PerformanceOverlay(
  enabled: true,
  position: PerformanceOverlayPosition.topRight,
  showDetailed: false,
  opacity: 0.9,
  backgroundColor: Colors.black87,
  updateInterval: Duration(milliseconds: 500),
  child: MyApp(),
)
```

#### Add Performance Chart
```dart
Column(
  children: [
    PerformanceChart(
      height: 200,
      maxDataPoints: 60,
      showGrid: true,
      showReferences: true,
    ),
    Expanded(
      child: MyContent(),
    ),
  ],
)
```

#### Programmatic Access
```dart
final tracker = PerformanceTracker();

// Start tracking
tracker.startTracking();

// Listen to metrics
tracker.metricsStream.listen((metrics) {
  print('Current FPS: ${metrics.fps}');
  print('Frame Time: ${metrics.frameTime}ms');
  print('Memory: ${metrics.memoryUsage}MB');
});

// Get FPS history
final history = tracker.getFPSHistory();

// Reset statistics
tracker.resetStatistics();

// Stop tracking
tracker.stopTracking();
```

## 📋 API Reference

### PerformanceOverlay

| Property | Type | Default | Description |
|----------|------|---------|-------------|
| `enabled` | `bool` | `true` | Enable/disable monitoring |
| `position` | `PerformanceOverlayPosition` | `topRight` | Overlay position |
| `showDetailed` | `bool` | `false` | Show detailed metrics by default |
| `opacity` | `double` | `0.9` | Overlay opacity (0.0-1.0) |
| `backgroundColor` | `Color` | `Colors.black87` | Background color |
| `textStyle` | `TextStyle?` | `null` | Custom text style |
| `padding` | `EdgeInsets` | `EdgeInsets.all(8)` | Content padding |
| `updateInterval` | `Duration` | `500ms` | Metrics update interval |

### PerformanceOverlayPosition
```dart
enum PerformanceOverlayPosition {
  topLeft,
  topRight,
  bottomLeft,
  bottomRight,
}
```

### PerformanceChart

| Property | Type | Default | Description |
|----------|------|---------|-------------|
| `height` | `double` | `200` | Chart height |
| `maxDataPoints` | `int` | `60` | Maximum data points to display |
| `updateInterval` | `Duration` | `500ms` | Update interval |
| `showGrid` | `bool` | `true` | Show grid lines |
| `showReferences` | `bool` | `true` | Show FPS reference lines |

### PerformanceMetrics
```dart
class PerformanceMetrics {
  final double fps;           // Frames per second
  final double frameTime;     // Frame time in ms
  final int frameCount;       // Total frames rendered
  final double cpuUsage;      // Estimated CPU usage %
  final double memoryUsage;   // Memory usage in MB
  final DateTime timestamp;   // When metrics were collected
  final double? minFps;       // Minimum FPS recorded
  final double? maxFps;       // Maximum FPS recorded
  final double? avgFps;       // Average FPS
}
```

### PerformanceTracker
```dart
class PerformanceTracker {
  void startTracking({Duration updateInterval});
  void stopTracking();
  void resetStatistics();
  void dispose();

  Stream<PerformanceMetrics> get metricsStream;
  bool get isTracking;
  List<double> getFPSHistory();
  Duration? getTrackingDuration();
}
```

## 🎯 Performance Thresholds

### FPS (Frames Per Second)

- **🟢 Excellent** (55+ FPS): Smooth, buttery performance
- **🟡 Good** (40-55 FPS): Acceptable performance
- **🟠 Fair** (25-40 FPS): Noticeable lag
- **🔴 Poor** (<25 FPS): Significant performance issues

### Frame Time

- **🟢 Excellent** (≤16.67ms): 60 FPS target
- **🟡 Acceptable** (≤33.33ms): 30 FPS
- **🔴 Poor** (>33.33ms): Below 30 FPS

### CPU Usage

- **🟢 Low** (0-40%): Efficient
- **🟡 Medium** (40-70%): Moderate
- **🔴 High** (70-100%): Heavy load

## 🎨 Customization Examples

### Dark Theme
```dart
PerformanceOverlay(
  backgroundColor: Color(0xFF1E1E1E),
  textStyle: TextStyle(color: Colors.white70),
  child: MyApp(),
)
```

### Minimal Style
```dart
PerformanceOverlay(
  showDetailed: false,
  opacity: 0.7,
  padding: EdgeInsets.all(6),
  child: MyApp(),
)
```

### Custom Update Interval
```dart
PerformanceOverlay(
  updateInterval: Duration(milliseconds: 250), // Faster updates
  child: MyApp(),
)
```

## 🧪 Testing

The package includes comprehensive tests:
```bash
# Run all tests
flutter test

# Run with coverage
flutter test --coverage

# Run specific test file
flutter test test/performance_tracker_test.dart
```

## 📱 Platform Support

| Platform | Supported | Notes |
|----------|-----------|-------|
| Android | ✅ | Full support |
| iOS | ✅ | Full support |
| Web | ✅ | Limited memory tracking |
| macOS | ✅ | Full support |
| Windows | ✅ | Full support |
| Linux | ✅ | Full support |

## 💡 Best Practices

1. **Development Only**: Disable in production builds
```dart
   PerformanceOverlay(
     enabled: kDebugMode,
     child: MyApp(),
   )
```

2. **Optimize Update Interval**: Balance between accuracy and overhead
```dart
   // For high-precision monitoring
   updateInterval: Duration(milliseconds: 250)

   // For lower overhead
   updateInterval: Duration(seconds: 1)
```

3. **Use Long Press**: Access detailed statistics without cluttering UI
```dart
   // Long press overlay to show performance dialog
```

4. **Monitor Specific Screens**: Wrap only screens you want to monitor
```dart
   PerformanceOverlay(
     enabled: true,
     child: GameScreen(), // Only monitor game performance
   )
```

## 🐛 Troubleshooting

### Overlay Not Showing

- Ensure `enabled: true` is set
- Check that overlay is not obscured by other widgets
- Verify SafeArea is not hiding the overlay

### Inaccurate FPS

- FPS is estimated based on frame timing
- Results may vary on different devices
- Use as a relative indicator, not absolute measurement

### Memory Tracking Not Working

- Memory tracking has limited support on Web
- Ensure app has necessary permissions on mobile

## 🤝 Contributing

Contributions are welcome! Please read our [Contributing Guide](CONTRIBUTING.md) first.

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- Inspired by Flutter's built-in performance overlay
- Thanks to the Flutter community for feedback and suggestions

## 📞 Support

- 🐛 [Report bugs](https://github.com/yourusername/flutter_pef_monit/issues)
- 💬 [Ask questions](https://github.com/yourusername/flutter_pef_monit/discussions)
- 📧 Email: your.email@example.com

## 🌟 Show Your Support

Give a ⭐️ if this project helped you!

---

Made with ❤️ by Your Name
