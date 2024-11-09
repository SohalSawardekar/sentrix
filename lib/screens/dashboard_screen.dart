import 'package:fl_chart/fl_chart.dart';
import 'package:sentrix/constants/imports.dart';
import 'package:sentrix/providers/MarketDataProvider.dart';
import 'package:sentrix/providers/sentiment_provider.dart';
import 'package:sentrix/constants/material_theme_ui.dart';
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
  bool _isSidebarExpanded = false;

  Future<void> _loadDashboardData() async {
    final marketProvider =
        Provider.of<MarketDataProvider>(context, listen: false);
    final sentimentProvider =
        Provider.of<SentimentDataProvider>(context, listen: false);

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
    final themeNotifier = Provider.of<ThemeNotifier>(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final crossAxisCount = screenWidth > 1200 ? 4 : (screenWidth > 800 ? 3 : 2);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 0, 51, 255),
        leading: IconButton(
          icon: const Icon(Icons.menu),
          onPressed: () {
            setState(() {
              _isSidebarExpanded = !_isSidebarExpanded;
            });
          },
        ),
        title: const Text(
          "Stock Insights Dashboard",
          style: TextStyle(
              color: Color.fromARGB(255, 255, 227, 225), fontSize: 18),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            iconSize: 24,
            icon: Icon(
              themeNotifier.isDarkMode ? Icons.wb_sunny : Icons.nights_stay,
              color: Color.fromARGB(255, 255, 227, 225),
            ),
            onPressed: () {
              themeNotifier.toggleTheme();
            },
          ),
          IconButton(
            icon: const Icon(Icons.settings,
                color: Color.fromARGB(255, 255, 227, 225)),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const SettingsScreen()),
            ),
          ),
        ],
      ),
      body: Row(
        children: [
          // Sidebar
          AnimatedContainer(
            width: _isSidebarExpanded ? 250 : 0,
            color: Colors.grey[900],
            duration: const Duration(milliseconds: 350),
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
                        ),
                      ),
                      _buildSidebarItem(
                        icon: Icons.analytics,
                        label: 'Analytics',
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const AnalyticsScreen()),
                        ),
                      ),
                      _buildSidebarItem(
                        icon: Icons.notifications,
                        label: 'Alerts',
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const AlertsScreen()),
                        ),
                      ),
                      const SizedBox(height: 50),
                      ElevatedButton(
                        onPressed: () async {
                          try {
                            await FirebaseAuth.instance.signOut();
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const LoginPage()),
                            );
                          } catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                  content: Text(
                                      'Error logging out: ${e.toString()}')),
                            );
                          }
                        },
                        child: const Text("Log Out"),
                      )
                    ],
                  )
                : null,
          ),
          // Main dashboard content
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Dashboard Overview',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 20),
                          GridView.count(
                            crossAxisCount: crossAxisCount,
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            mainAxisSpacing: 16.0,
                            crossAxisSpacing: 16.0,
                            children: [
                              _buildDataTile(
                                title: 'Market Sentiment',
                                content: _buildSentimentTrendChart(context),
                                color: Colors.blue[100]!,
                                height: 300,
                              ),
                              _buildDataTile(
                                title: 'Tech Sector',
                                content: const Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.trending_up,
                                        size: 48, color: Colors.green),
                                    Text(
                                      '+1.2%',
                                      style: TextStyle(
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.green,
                                      ),
                                    ),
                                    Text('Daily Change'),
                                  ],
                                ),
                                color: Colors.green[100]!,
                              ),
                              _buildDataTile(
                                title: 'Health Sector',
                                content: const Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.trending_down,
                                        size: 48, color: Colors.red),
                                    Text(
                                      '-0.8%',
                                      style: TextStyle(
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.red,
                                      ),
                                    ),
                                    Text('Daily Change'),
                                  ],
                                ),
                                color: Colors.red[100]!,
                              ),
                              _buildDataTile(
                                title: 'Finance Sector',
                                content: const Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.trending_flat,
                                        size: 48, color: Colors.orange),
                                    Text(
                                      '0.0%',
                                      style: TextStyle(
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.orange,
                                      ),
                                    ),
                                    Text('Daily Change'),
                                  ],
                                ),
                                color: Colors.orange[100]!,
                              ),
                              _buildDataTile(
                                title: 'Active Alerts',
                                content: const Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.notifications_active, size: 48),
                                    Text(
                                      '3',
                                      style: TextStyle(
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text('New Alerts'),
                                  ],
                                ),
                                color: Colors.purple[100]!,
                              ),
                              _buildDataTile(
                                title: 'Trading Volume',
                                content: const Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.bar_chart, size: 48),
                                    Text(
                                      '1.2M',
                                      style: TextStyle(
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text('Shares Traded'),
                                  ],
                                ),
                                color: Colors.teal[100]!,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildDataTile({
    required String title,
    required Widget content,
    required Color color,
    double? height,
  }) {
    return Card(
      elevation: 4,
      color: color,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Expanded(child: content),
          ],
        ),
      ),
    );
  }

  Widget _buildSidebarItem({
    required IconData icon,
    required String label,
    required Function onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: const Color.fromARGB(255, 224, 224, 224)),
      title: Text(
        label,
        style: const TextStyle(color: Colors.white),
      ),
      onTap: () => onTap(),
    );
  }

  Widget _buildSentimentTrendChart(BuildContext context) {
    final sentimentProvider = Provider.of<SentimentDataProvider>(context);
    return LineChart(
      LineChartData(
        gridData: const FlGridData(show: true),
        titlesData: const FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              interval: 1,
            ),
          ),
        ),
        borderData: FlBorderData(show: true),
        lineBarsData: [
          LineChartBarData(
            spots: sentimentProvider.sentimentTrend
                .asMap()
                .entries
                .map((entry) => FlSpot(entry.key.toDouble(), entry.value))
                .toList(),
            isCurved: true,
            color: const Color.fromARGB(255, 0, 4, 255),
            barWidth: 2,
            belowBarData: BarAreaData(
              show: true,
              color: const Color.fromARGB(255, 255, 255, 0).withOpacity(0.3),
            ),
            dotData: const FlDotData(show: false),
          ),
        ],
      ),
    );
  }
}
