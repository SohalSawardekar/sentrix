import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:sentrix/Services/Sentimental_Analysis.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class TrendsScreen extends StatefulWidget {
  const TrendsScreen({super.key});

  @override
  _TrendsScreenState createState() => _TrendsScreenState();
}

class _TrendsScreenState extends State<TrendsScreen> {
  // final SentimentAnalysisService _sentimentService = SentimentAnalysisService();
  bool _isLoading = true;
  double? _sentimentScore;
  String _sentimentDescription = '';
  bool _isTrendingLoading = true;
  List<String> _trendingStocks = [];

  // Method to load trending stock data using Gemini AI
  Future<void> _loadTrendingStocks() async {
    setState(() {
      _isTrendingLoading = true;
    });
    try {
      final response = await http
          .get(Uri.parse('https://api.gemini.com/v1/trending_stocks'));
      if (response.statusCode == 200) {
        List<dynamic> data = jsonDecode(response.body);
        setState(() {
          _trendingStocks =
              List<String>.from(data.map((stock) => stock['symbol']));
        });
      } else {
        throw Exception('Failed to load trending stocks');
      }
    } catch (e) {
      setState(() {
        _trendingStocks = ['APPLE'];
      });
    } finally {
      setState(() {
        _isTrendingLoading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    // _loadSentiment();
    _loadTrendingStocks(); // Load trending stocks
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Market Trends'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              // _loadSentiment(); // Refresh sentiment data on click
              _loadTrendingStocks(); // Refresh trending stocks data on click
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Section for top trending stocks
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Top Trending Stocks',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 12),
              _isTrendingLoading
                  ? const Center(
                      child:
                          CircularProgressIndicator()) // Show loading spinner
                  : SizedBox(
                      height: 200, // Set a fixed height to avoid overflow
                      child: ListView.builder(
                        shrinkWrap: true,
                        physics:
                            const NeverScrollableScrollPhysics(), // Prevent inner scrolling
                        itemCount: _trendingStocks.length,
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
                              title: Text(_trendingStocks[index]),
                              subtitle: Text(index % 2 == 0
                                  ? 'Price up by ${index + 1}%'
                                  : 'Price down by ${index + 1}%'),
                              trailing: Text(
                                '\$${(index + 1) * 100 + 0.50}',
                                style: TextStyle(
                                  color: index % 2 == 0
                                      ? Colors.green
                                      : Colors.red,
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
                    ),
              const Divider(),

              // Sentiment Analysis Section
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 8.0),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Sentiment Analysis',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
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

              // Section for sentiment trend chart
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 8.0),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Sentiment Trend Over Time',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              _buildSentimentTrendChart(),
            ],
          ),
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
                FlSpot(6, 0.67),
                FlSpot(7, 0.82),
                FlSpot(8, 0.77),
                FlSpot(9, 0.82),
                FlSpot(10, 0.65),
                FlSpot(11, 0.9),
                FlSpot(12, 0.87),
              ],
              isCurved: true,
              barWidth: 3,
              color: Colors.blueAccent,
              belowBarData: BarAreaData(
                  show: true, color: Colors.blueAccent.withOpacity(0.2)),
            ),
          ],
        ),
      ),
    );
  }
}
