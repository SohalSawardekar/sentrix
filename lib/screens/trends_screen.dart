import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:sentrix/Services/Sentimental_Analysis.dart';

class TrendsScreen extends StatefulWidget {
  const TrendsScreen({super.key});

  @override
  _TrendsScreenState createState() => _TrendsScreenState();
}

class _TrendsScreenState extends State<TrendsScreen> {
  final SentimentAnalysisService _sentimentService = SentimentAnalysisService();
  bool _isLoading = true;
  double? _sentimentScore;
  String _sentimentDescription = '';

  // Method to load sentiment data
  Future<void> _loadSentiment() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final score =
          await _sentimentService.analyzeSentiment('Market sentiment analysis');
      setState(() {
        _sentimentScore = score;
        _sentimentDescription =
            score > 0.5 ? 'Positive Sentiment' : 'Negative Sentiment';
      });
    } catch (e) {
      setState(() {
        _sentimentDescription = 'Error loading sentiment';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _loadSentiment();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Market Trends'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadSentiment,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Top Trending Stocks',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            ListView.builder(
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              itemCount: 5,
              itemBuilder: (context, index) {
                return Card(
                  elevation: 2,
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor:
                          index % 2 == 0 ? Colors.green : Colors.red,
                      child: Icon(
                        index % 2 == 0
                            ? Icons.trending_up
                            : Icons.trending_down,
                        color: Colors.white,
                      ),
                    ),
                    title: Text('Stock ${[
                      'AAPL',
                      'GOOGL',
                      'MSFT',
                      'TSLA',
                      'AMZN'
                    ][index]}'),
                    subtitle: Text(index % 2 == 0
                        ? 'Price up by ${index + 1}%'
                        : 'Price down by ${index + 1}%'),
                    trailing: Text(
                      '\$${(index + 1) * 100 + 0.50}',
                      style: TextStyle(
                        color: index % 2 == 0 ? Colors.green : Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    onTap: () {
                      // Navigate to detailed stock view
                    },
                  ),
                );
              },
            ),
            const Divider(),

            // Sentiment Analysis Section
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8.0),
              child: Text(
                'Sentiment Analysis',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
            _isLoading
                ? const Center(child: CircularProgressIndicator())
                : Column(
                    children: [
                      Card(
                        elevation: 2,
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        child: ListTile(
                          leading: Icon(
                            _sentimentScore != null && _sentimentScore! > 0.5
                                ? Icons.thumb_up
                                : Icons.thumb_down,
                            color: _sentimentScore != null &&
                                    _sentimentScore! > 0.5
                                ? Colors.green
                                : Colors.red,
                            size: 30,
                          ),
                          title: const Text(
                            'Overall Market Sentiment',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(
                            'Sentiment Score: ${_sentimentScore?.toStringAsFixed(2)} ($_sentimentDescription)',
                            style: TextStyle(
                              color: _sentimentScore != null &&
                                      _sentimentScore! > 0.5
                                  ? Colors.green
                                  : Colors.red,
                            ),
                          ),
                        ),
                      ),
                      _buildSentimentCard(
                        title: 'Positive Sentiment on Tech Stocks',
                        description:
                            'Increased investment and positive outlook.',
                        icon: Icons.mood,
                        color: Colors.blue,
                      ),
                      _buildSentimentCard(
                        title: 'Market Volatility Alert',
                        description:
                            'High volatility detected in energy sector.',
                        icon: Icons.warning,
                        color: Colors.orange,
                      ),
                    ],
                  ),

            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8.0),
              child: Text(
                'Sentiment Trend Over Time',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
            _buildSentimentTrendChart(),
          ],
        ),
      ),
    );
  }

  // Helper method to build sentiment card
  Widget _buildSentimentCard({
    required String title,
    required String description,
    required IconData icon,
    required Color color,
  }) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        leading: Icon(icon, color: color, size: 30),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(description),
      ),
    );
  }

  // Helper method to build sentiment trend chart
  Widget _buildSentimentTrendChart() {
    return SizedBox(
      height: 200,
      child: LineChart(
        LineChartData(
          borderData: FlBorderData(show: true),
          gridData: const FlGridData(show: true),
          titlesData: FlTitlesData(
            leftTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: true),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                interval: 1,
                getTitlesWidget: (value, meta) {
                  return Text(
                    'Day ${value.toInt() + 1}',
                    style: const TextStyle(fontSize: 10),
                  );
                },
              ),
            ),
          ),
          lineBarsData: [
            LineChartBarData(
              spots: const [
                FlSpot(0, 0.7),
                FlSpot(1, 0.8),
                FlSpot(2, 0.9),
                FlSpot(3, 0.85),
                FlSpot(4, 0.87),
                FlSpot(5, 0.92),
                FlSpot(6, 0.95),
              ],
              isCurved: true,
              barWidth: 3,
              color: Colors.blueAccent,
              belowBarData: BarAreaData(
                show: true,
                color: Colors.blueAccent.withOpacity(0.2),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
