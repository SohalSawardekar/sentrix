import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sentrix/screens/newspredict.dart';
import 'package:sentrix/screens/sentimentOverview.dart';
import 'package:sentrix/screens/setting_screen.dart';
import 'dart:io';
import 'dart:convert';
import 'package:share_plus/share_plus.dart';

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  String _selectedSymbol = 'AAPL';
  bool _showAdvancedMetrics = false;

  final List<String> _symbols = [
    'AAPL',
    'GOOGL',
    'AMZN',
    'MSFT',
    'TSLA',
    'META',
    'NFLX',
    'NVDA',
    'INTC',
    'AMD',
    'BABA',
    'ORCL',
    'SAP',
    'IBM',
    'ADBE',
    'CRM',
    'CSCO',
    'QCOM',
    'AVGO',
    'TXN'
  ];

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
            onPressed: () => {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => const SettingsScreen()))
            },
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

  Future<void> _exportAnalytics() async {
    try {
      // Show loading indicator
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(),
        ),
      );

      // Fetch data from Firestore
      final QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('sentimentData')
          .where('symbol', isEqualTo: _selectedSymbol)
          .get();

      // Convert the data to a List of Maps
      final List<Map<String, dynamic>> analyticsData = querySnapshot.docs
          .map((doc) => {
                ...doc.data() as Map<String, dynamic>,
                'id': doc.id,
              })
          .toList();

      // Convert data to text format
      String textData = 'Analytics Data for $_selectedSymbol\n\n';
      for (var doc in analyticsData) {
        textData += 'ID: ${doc['id']}\n';
        doc.forEach((key, value) {
          if (key != 'id') {
            textData += '$key: $value\n';
          }
        });
        textData += '\n'; // Add space between each record
      }

      // Get temporary directory
      final directory = await getApplicationDocumentsDirectory();
      final String fileName =
          '${_selectedSymbol}_analytics_${DateTime.now().millisecondsSinceEpoch}.txt';
      final File file = File('${directory.path}/$fileName');

      // Write text data to file
      await file.writeAsString(textData);

      // Close loading indicator
      Navigator.pop(context);

      // Share the file
      await Share.shareXFiles(
        [XFile(file.path)],
        subject: 'Analytics Export - $_selectedSymbol',
      );
    } catch (e) {
      // Close loading indicator if it's showing
      if (context.mounted) {
        Navigator.pop(context);
      }

      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Export failed: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showAnalyticsSettings() {
    // Placeholder for settings logic
    print('Showing analytics settings');
  }

  Widget _buildSentimentOverview() {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        padding: EdgeInsets.all(16.0),
      ),
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => Sentimentoverview(symbol: _selectedSymbol)),
        );
        print('Sentiment Overview clicked!');
      },
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Sentiment Overview',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          SizedBox(height: 8),
          Text(
              'Overview of the overall sentiment trends for the selected symbol and timeframe.'),
        ],
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
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.all(16.0),
        ),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => Newspredict(symbol: _selectedSymbol)),
          );
          print('News Sentiment Breakdown button pressed');
        },
        child: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'News Sentiment Breakdown',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              'Breakdown of sentiment from news sources related to the selected symbol.',
            ),
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
            Text(
                'Analyzing the impact of social media sentiment on stock prices.'),
          ],
        ),
      ),
    );
  }
}
