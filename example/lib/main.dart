import 'package:flutter/material.dart';
import 'package:flutter_performance_monitor/flutter_performance_monitor.dart' as perf;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Performance Monitor Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
        brightness: Brightness.light,
      ),
      darkTheme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
        brightness: Brightness.dark,
      ),
      themeMode: ThemeMode.system,
      home: const perf.PerformanceOverlay(
        enabled: true,
        position: perf.PerformanceOverlayPosition.topRight,
        showDetailed: false,
        child: ExampleHomePage(),
      ),
    );
  }
}

class ExampleHomePage extends StatelessWidget {
  const ExampleHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Performance Monitor Demo'),
        elevation: 2,
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () => _showInfoDialog(context),
            tooltip: 'About',
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.speed,
              size: 80,
              color: Theme.of(context).primaryColor.withValues(alpha: 0.7),
            ),
            const SizedBox(height: 24),
            Text(
              'Performance Monitor',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            Text(
              'Tap the overlay to expand/collapse\nDouble tap to view performance chart\nLong press for detailed metrics',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Colors.grey[600],
                  ),
            ),
          ],
        ),
      ),
    );
  }

  void _showInfoDialog(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('About Performance Monitor'),
        content: const SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'This demo app showcases the Flutter Performance Monitor package.',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 16),
              Text('Features:'),
              SizedBox(height: 8),
              Text('• 📊 Real-time FPS monitoring'),
              Text('• ⏱️ Frame time tracking'),
              Text('• 💾 Memory usage display'),
              Text('• 🔥 CPU usage estimation'),
              Text('• 📈 Performance history chart'),
              Text('• 🎨 Customizable overlay'),
              SizedBox(height: 16),
              Text('Instructions:'),
              SizedBox(height: 8),
              Text('• Tap overlay to expand/collapse'),
              Text('• Double tap overlay to view chart'),
              Text('• Long press overlay for details'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Got it'),
          ),
        ],
      ),
    );
  }
}
