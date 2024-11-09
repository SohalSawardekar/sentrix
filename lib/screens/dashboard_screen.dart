import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:sentrix/main.dart';
import 'package:sentrix/providers/market_data_provider.dart';
import 'package:sentrix/providers/sentiment_provider.dart';
import 'alerts_screen.dart';
import 'analytics_screen.dart';
import 'setting_screen.dart';
import 'trends_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  bool _isLoading = true;
  bool _isAlertsPanelExpanded = false;
  bool _isSidebarExpanded = false; // State for sidebar expansion

  Future<void> _loadDashboardData() async {
    final marketProvider =
        Provider.of<MarketDataProvider>(context, listen: false);
    final sentimentProvider =
        Provider.of<SentimentProvider>(context, listen: false);

    setState(() => _isLoading = true);
    try {
      await Future.wait([
        marketProvider.fetchMarketData(),
        sentimentProvider.fetchSentimentData(),
      ]);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading data: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.menu),
          onPressed: () {
            setState(() {
              _isSidebarExpanded = !_isSidebarExpanded;
            });
          },
        ),
        title: const Text("Stock Market Dashboard"),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => SettingsScreen()),
            ),
          ),
        ],
      ),
      body: Row(
        children: [
          // Sidebar with navigation and toggle button
          AnimatedContainer(
            width:
                _isSidebarExpanded ? 250 : 0, // Adjust width based on expansion
            color: Colors.grey[900],
            duration: const Duration(milliseconds: 300),
            child: _isSidebarExpanded
                ? Column(
                    children: [
                      const SizedBox(height: 50),
                      _buildSidebarItem(
                          icon: Icons.trending_up,
                          label: 'Trends',
                          onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => const TrendsScreen()),
                              )),
                      _buildSidebarItem(
                          icon: Icons.analytics,
                          label: 'Analytics',
                          onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        const AnalyticsScreen()),
                              )),
                      _buildSidebarItem(
                          icon: Icons.notifications,
                          label: 'Alerts',
                          onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => const AlertsScreen()),
                              )),
                    ],
                  )
                : null,
          ),

          // Main dashboard content
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : Column(
                    children: [
                      // Sentiment Gauge
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: GestureDetector(
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const TrendsScreen()),
                          ),
                        ),
                      ),

                      // Alerts Panel
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        height: _isAlertsPanelExpanded ? 200 : 0,
                        child: Column(
                          children: [
                            GestureDetector(
                              onTap: () {
                                setState(() {
                                  _isAlertsPanelExpanded =
                                      !_isAlertsPanelExpanded;
                                });
                              },
                              child: Container(
                                color: Colors.blueAccent,
                                padding: const EdgeInsets.all(16.0),
                                child: const Text(
                                  'Real-time Alerts',
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 18),
                                ),
                              ),
                            ),
                            const Expanded(
                              child: SingleChildScrollView(
                                child: Column(
                                  children: [
                                    ListTile(
                                      title: Text(
                                          'Alert 1: Market Sentiment Down!'),
                                    ),
                                    ListTile(
                                      title: Text(
                                          'Alert 2: High Volume in Tech Sector'),
                                    ),
                                    ListTile(
                                      title: Text(
                                          'Alert 3: Stock Surge Predicted'),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  // Widget for sidebar items
  Widget _buildSidebarItem(
      {required IconData icon,
      required String label,
      required Function onTap}) {
    return ListTile(
      leading: Icon(icon, color: Colors.white),
      title: Text(label, style: const TextStyle(color: Colors.white)),
      onTap: () => onTap(),
    );
  }

  Widget _buildSummaryItem(String label, String value, IconData icon,
      {Color? color}) {
    return Column(
      children: [
        Icon(icon, color: color ?? Theme.of(context).primaryColor, size: 32),
        const SizedBox(height: 8),
        Text(label, style: Theme.of(context).textTheme.bodySmall),
        const SizedBox(height: 4),
        Text(value,
            style: Theme.of(context)
                .textTheme
                .titleMedium
                ?.copyWith(fontWeight: FontWeight.bold, color: color)),
      ],
    );
  }

  Widget _buildSentimentTrendChart(BuildContext context) {
    final sentimentProvider = Provider.of<SentimentProvider>(context);
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Sentiment Trend',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(show: true),
                  titlesData: FlTitlesData(
                    leftTitles: const AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        interval: 1,
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, _) {
                          final index = value.toInt();
                          final sentimentProvider =
                              Provider.of<SentimentDataProvider>(context,
                                  listen: false);
                          final dates = sentimentProvider.trendDates;
                          if (index >= 0 && index < dates.length) {
                            return Text(dates[index]);
                          }
                          return const Text('');
                        },
                      ),
                    ),
                  ),
                  borderData: FlBorderData(show: true),
                  lineBarsData: [
                    LineChartBarData(
                      spots: sentimentProvider.sentimentTrend
                          .asMap()
                          .entries
                          .map((entry) => FlSpot(entry.key.toDouble(),
                              entry.value)) // Map data points
                          .toList(),
                      isCurved: true,
                      color: Colors.blueAccent,
                      barWidth: 2,
                      belowBarData: BarAreaData(
                        show: true,
                        color: Colors.blueAccent.withOpacity(0.3),
                      ),
                      dotData: FlDotData(show: false),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
