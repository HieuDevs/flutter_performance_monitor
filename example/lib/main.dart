import 'package:flutter/material.dart';
import 'package:flutter_performance_monitor/flutter_performance_monitor.dart'
    as perf;

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

class ExampleHomePage extends StatefulWidget {
  const ExampleHomePage({super.key});

  @override
  State<ExampleHomePage> createState() => _ExampleHomePageState();
}

class _ExampleHomePageState extends State<ExampleHomePage>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  bool _showChart = true;
  bool _enableHeavyAnimation = false;
  bool _enableList = true;
  int _listItemCount = 1000;
  double _animationSpeed = 1.0;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: (2000 / _animationSpeed).round()),
    )..repeat();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _updateAnimationSpeed(double speed) {
    setState(() {
      _animationSpeed = speed;
      _animationController.duration =
          Duration(milliseconds: (2000 / speed).round());
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Performance Monitor Demo'),
        elevation: 2,
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: _showInfoDialog,
            tooltip: 'About',
          ),
        ],
      ),
      body: Column(
        children: [
          // Performance Chart
          if (_showChart)
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: perf.PerformanceChart(
                height: 200,
                maxDataPoints: 60,
                showGrid: true,
                showReferences: true,
              ),
            ),

          // Control Panel
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.tune,
                          color: Theme.of(context).primaryColor,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Performance Testing Controls',
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                        ),
                      ],
                    ),
                    const Divider(height: 24),

                    // Show Chart Toggle
                    SwitchListTile(
                      title: const Text('Show Performance Chart'),
                      subtitle: const Text('Display real-time FPS graph'),
                      value: _showChart,
                      onChanged: (value) {
                        setState(() {
                          _showChart = value;
                        });
                      },
                      secondary: const Icon(Icons.show_chart),
                    ),

                    // Heavy Animation Toggle
                    SwitchListTile(
                      title: const Text('Enable Heavy Animation'),
                      subtitle: const Text('Test performance under load'),
                      value: _enableHeavyAnimation,
                      onChanged: (value) {
                        setState(() {
                          _enableHeavyAnimation = value;
                        });
                      },
                      secondary: const Icon(Icons.animation),
                    ),

                    // Animation Speed Slider
                    if (_enableHeavyAnimation)
                      Padding(
                        padding: const EdgeInsets.only(
                            left: 16.0, right: 16.0, top: 8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Animation Speed: ${_animationSpeed.toStringAsFixed(1)}x',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                            Slider(
                              value: _animationSpeed,
                              min: 0.5,
                              max: 5.0,
                              divisions: 9,
                              label: '${_animationSpeed.toStringAsFixed(1)}x',
                              onChanged: _updateAnimationSpeed,
                            ),
                          ],
                        ),
                      ),

                    // Enable List Toggle
                    SwitchListTile(
                      title: const Text('Enable Scrollable List'),
                      subtitle: const Text('Test rendering performance'),
                      value: _enableList,
                      onChanged: (value) {
                        setState(() {
                          _enableList = value;
                        });
                      },
                      secondary: const Icon(Icons.list),
                    ),

                    // List Item Count Slider
                    if (_enableList)
                      Padding(
                        padding: const EdgeInsets.only(
                            left: 16.0, right: 16.0, top: 8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'List Items: $_listItemCount',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                            Slider(
                              value: _listItemCount.toDouble(),
                              min: 100,
                              max: 5000,
                              divisions: 49,
                              label: '$_listItemCount items',
                              onChanged: (value) {
                                setState(() {
                                  _listItemCount = value.round();
                                });
                              },
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Content Area
          Expanded(
            child: _buildContent(),
          ),
        ],
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            heroTag: 'rebuild',
            onPressed: () {
              setState(() {});
            },
            tooltip: 'Force Rebuild',
            child: const Icon(Icons.refresh),
          ),
          const SizedBox(height: 12),
          FloatingActionButton(
            heroTag: 'stress',
            onPressed: _runStressTest,
            tooltip: 'Stress Test',
            backgroundColor: Colors.orange,
            child: const Icon(Icons.warning),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    if (_enableHeavyAnimation) {
      return _buildHeavyAnimation();
    } else if (_enableList) {
      return _buildScrollableList();
    } else {
      return _buildEmptyState();
    }
  }

  Widget _buildHeavyAnimation() {
    return Center(
      child: AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          return Transform.rotate(
            angle: _animationController.value * 2 * 3.14159,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [
                    Colors.blue,
                    Colors.purple,
                    Colors.pink,
                    Colors.orange,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.blue.withOpacity(0.5),
                    blurRadius: 30,
                    spreadRadius: 10,
                  ),
                  BoxShadow(
                    color: Colors.purple.withOpacity(0.3),
                    blurRadius: 20,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: Center(
                child: Transform.rotate(
                  angle: -_animationController.value * 2 * 3.14159,
                  child: const Icon(
                    Icons.ac_unit,
                    color: Colors.white,
                    size: 80,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildScrollableList() {
    return ListView.builder(
      itemCount: _listItemCount,
      itemBuilder: (context, index) {
        return Card(
          margin: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 4,
          ),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor:
                  Colors.primaries[index % Colors.primaries.length],
              child: Text(
                '${index + 1}',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            title: Text('Item ${index + 1}'),
            subtitle: Text(
              'Scroll to test rendering performance',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.favorite_border),
                  onPressed: () {
                    _showSnackBar('Liked item ${index + 1}');
                  },
                ),
                const Icon(Icons.chevron_right),
              ],
            ),
            onTap: () {
              _showSnackBar('Tapped item ${index + 1}');
            },
          ),
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.settings,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'Enable a test mode above',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: Colors.grey[600],
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Choose heavy animation or scrollable list\nto test performance',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[500],
                ),
          ),
        ],
      ),
    );
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(milliseconds: 500),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _runStressTest() {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.warning, color: Colors.orange),
            SizedBox(width: 8),
            Text('Stress Test'),
          ],
        ),
        content: const Text(
          'This will enable heavy animations and a large list simultaneously to stress test the performance monitor. Continue?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                _enableHeavyAnimation = true;
                _enableList = true;
                _listItemCount = 5000;
                _animationSpeed = 5.0;
                _animationController.duration =
                    Duration(milliseconds: (2000 / _animationSpeed).round());
              });
              _showSnackBar('Stress test started!');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
            ),
            child: const Text('Start Test'),
          ),
        ],
      ),
    );
  }

  void _showInfoDialog() {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('About Performance Monitor'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'This demo app showcases the Flutter Performance Monitor package.',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              const Text('Features:'),
              const SizedBox(height: 8),
              _buildFeatureItem('📊 Real-time FPS monitoring'),
              _buildFeatureItem('⏱️ Frame time tracking'),
              _buildFeatureItem('💾 Memory usage display'),
              _buildFeatureItem('🔥 CPU usage estimation'),
              _buildFeatureItem('📈 Performance history chart'),
              _buildFeatureItem('🎨 Customizable overlay'),
              const SizedBox(height: 16),
              const Text('Instructions:'),
              const SizedBox(height: 8),
              _buildInstructionItem('• Tap overlay to expand/collapse'),
              _buildInstructionItem('• Long press overlay for details'),
              _buildInstructionItem('• Use controls to test performance'),
              _buildInstructionItem('• Watch FPS changes in real-time'),
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

  Widget _buildFeatureItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(left: 8.0, bottom: 4.0),
      child: Text(text),
    );
  }

  Widget _buildInstructionItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(left: 8.0, bottom: 4.0),
      child: Text(text),
    );
  }
}
