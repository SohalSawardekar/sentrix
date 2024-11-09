import 'package:flutter/material.dart';

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  String _selectedTimeframe = '1D';
  String _selectedSymbol = 'AAPL';
  bool _showAdvancedMetrics = false;

  final List<String> _timeframes = ['1D', '1W', '1M', '3M', '6M', '1Y', 'ALL'];
  final List<String> _symbols = ['AAPL', 'GOOGL', 'MSFT', 'TSLA', 'AMZN'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Analytics'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save_alt),
            onPressed: _exportAnalytics,
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: _showAnalyticsSettings,
          ),
        ],
      ),
      body: Column(
        children: [
          _buildControlPanel(),
          Expanded(
            child: RefreshIndicator(
              onRefresh: _refreshData,
              child: ListView(
                padding: const EdgeInsets.all(16.0),
                children: [
                  _buildSentimentOverview(),
                  const SizedBox(height: 16),
                  _buildPriceSentimentCorrelation(),
                  const SizedBox(height: 16),
                  if (_showAdvancedMetrics) ...[
                    _buildVolatilityAnalysis(),
                    const SizedBox(height: 16),
                    _buildSentimentDistribution(),
                    const SizedBox(height: 16),
                  ],
                  _buildNewsSentimentBreakdown(),
                  const SizedBox(height: 16),
                  _buildSocialMediaImpact(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildControlPanel() {
    return Card(
      margin: const EdgeInsets.all(8.0),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _selectedSymbol,
                    decoration: const InputDecoration(
                      labelText: 'Symbol',
                      border: OutlineInputBorder(),
                    ),
                    items: _symbols
                        .map((symbol) => DropdownMenuItem(
                              value: symbol,
                              child: Text(symbol),
                            ))
                        .toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() => _selectedSymbol = value);
                        _refreshData();
                      }
                    },
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _selectedTimeframe,
                    decoration: const InputDecoration(
                      labelText: 'Timeframe',
                      border: OutlineInputBorder(),
                    ),
                    items: _timeframes
                        .map((timeframe) => DropdownMenuItem(
                              value: timeframe,
                              child: Text(timeframe),
                            ))
                        .toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() => _selectedTimeframe = value);
                        _refreshData();
                      }
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            SwitchListTile(
              title: const Text('Advanced Metrics'),
              subtitle: const Text('Show additional analysis metrics'),
              value: _showAdvancedMetrics,
              onChanged: (value) =>
                  setState(() => _showAdvancedMetrics = value),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _refreshData() async {
    // Placeholder for data refresh logic
    await Future.delayed(const Duration(seconds: 1));
    print('Data refreshed');
  }

  void _exportAnalytics() {
    // Placeholder for export analytics logic
    print('Exporting analytics data');
  }

  void _showAnalyticsSettings() {
    // Placeholder for settings logic
    print('Showing analytics settings');
  }

  Widget _buildSentimentOverview() {
    return const Card(
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Sentiment Overview',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            Text(
                'Overview of the overall sentiment trends for the selected symbol and timeframe.'),
          ],
        ),
      ),
    );
  }

  Widget _buildPriceSentimentCorrelation() {
    return const Card(
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Price-Sentiment Correlation',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            Text(
                'Displays correlation between price movement and sentiment score over time.'),
          ],
        ),
      ),
    );
  }

  Widget _buildVolatilityAnalysis() {
    return const Card(
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Volatility Analysis',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            Text(
                'Detailed analysis of the price volatility for the selected symbol.'),
          ],
        ),
      ),
    );
  }

  Widget _buildSentimentDistribution() {
    return const Card(
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Sentiment Distribution',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            Text(
                'Distribution of sentiment scores across different sources and categories.'),
          ],
        ),
      ),
    );
  }

  Widget _buildNewsSentimentBreakdown() {
    return const Card(
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('News Sentiment Breakdown',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            Text(
                'Breakdown of sentiment from news sources related to the selected symbol.'),
          ],
        ),
      ),
    );
  }

  Widget _buildSocialMediaImpact() {
    return const Card(
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Social Media Impact',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            Text('Impact of social media sentiment on the selected symbol.'),
          ],
        ),
      ),
    );
  }
}
