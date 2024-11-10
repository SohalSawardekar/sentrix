import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';

class Sentimentoverview extends StatefulWidget {
  final String symbol;
  const Sentimentoverview({super.key, required this.symbol});
  @override
  State<Sentimentoverview> createState() => _SentimentoverviewState();
}

class _SentimentoverviewState extends State<Sentimentoverview> {
  String _selectedTimeframe = '1W';
  bool _isLoading = true;
  List<FlSpot> _sentimentData = [];
  Map<String, dynamic>? _currentSentiment;
  List<Map<String, dynamic>> _newsHighlights = [];

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    setState(() => _isLoading = true);
    try {
      // Fetch sentiment data
      final QuerySnapshot sentimentSnapshot = await FirebaseFirestore.instance
          .collection('sentimentData')
          .where('symbol', isEqualTo: widget.symbol)
          .orderBy('timestamp', descending: false)
          .limit(7) // Adjust based on timeframe
          .get();

      // Convert to FlSpot for graph
      _sentimentData = sentimentSnapshot.docs.asMap().entries.map((entry) {
        final data = entry.value.data() as Map<String, dynamic>;
        return FlSpot(
            entry.key.toDouble(), (data['sentimentTrendValues'] ?? 0));
      }).toList();

      // Fetch current sentiment
      final DocumentSnapshot currentSnapshot = await FirebaseFirestore.instance
          .collection('sentimentData')
          .doc('${widget.symbol}')
          .get();

      if (currentSnapshot.exists) {
        _currentSentiment = currentSnapshot.data() as Map<String, dynamic>;
        print(_currentSentiment);
      }

      // Fetch news highlights
      final QuerySnapshot newsSnapshot = await FirebaseFirestore.instance
          .collection('stockNews')
          .where('symbol', isEqualTo: widget.symbol)
          .orderBy('timestamp', descending: true)
          .limit(3)
          .get();

      _newsHighlights = newsSnapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return {
          'news': data['news'],
          'timestamp': data['timestamp'] ?? Timestamp.now(),
        };
      }).toList();

      setState(() => _isLoading = false);
    } catch (e) {
      print('Error fetching data: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading data: $e')),
      );
      setState(() => _isLoading = false);
    }
  }

  String _getTimeAgo(Timestamp timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp.toDate());

    if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else {
      return '${difference.inDays}d ago';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildTimeframeSelector(),
                  const SizedBox(height: 24),
                  _buildSentimentSummaryCards(),
                  const SizedBox(height: 24),
                  _buildSentimentTrendGraph(),
                  const SizedBox(height: 24),
                  _buildTrendAnalysis(),
                  const SizedBox(height: 24),
                  _buildNewsHighlights(),
                ],
              ),
            ),
    );
  }

  Widget _buildTimeframeSelector() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children:
              ['1D', '1W', '1M', '3M', '6M', '1Y'].map((String timeframe) {
            return ChoiceChip(
              label: Text(timeframe),
              selected: _selectedTimeframe == timeframe,
              onSelected: (bool selected) {
                if (selected) {
                  setState(() {
                    _selectedTimeframe = timeframe;
                  });
                }
              },
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildSentimentSummaryCards() {
    return Row(
      children: [
        Expanded(
          child: _buildSummaryCard(
            'Current Sentiment',
            '0.75',
            'Positive',
            Icons.trending_up,
            Colors.green,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildSummaryCard(
            'News Volume',
            '127',
            '+12% from last week',
            Icons.bar_chart,
            Colors.blue,
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryCard(
      String title, String value, String subtitle, IconData icon, Color color) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color),
                const SizedBox(width: 8),
                Text(title, style: Theme.of(context).textTheme.titleSmall),
              ],
            ),
            const SizedBox(height: 8),
            Text(value,
                style: Theme.of(context)
                    .textTheme
                    .headlineMedium
                    ?.copyWith(color: color, fontWeight: FontWeight.bold)),
            Text(subtitle,
                style: Theme.of(context)
                    .textTheme
                    .bodySmall
                    ?.copyWith(color: Colors.grey)),
          ],
        ),
      ),
    );
  }

  Widget _buildSentimentTrendGraph() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Sentiment Trend',
                style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 24),
            SizedBox(
              height: 200,
              child: LineChart(
                LineChartData(
                  gridData: const FlGridData(show: true),
                  titlesData: const FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: true),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: true),
                    ),
                    topTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    rightTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                  ),
                  borderData: FlBorderData(show: true),
                  lineBarsData: [
                    LineChartBarData(
                      spots: _sentimentData,
                      isCurved: true,
                      color: Colors.blue,
                      barWidth: 3,
                      belowBarData: BarAreaData(
                        show: true,
                        color: Colors.blue.withOpacity(0.1),
                      ),
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

  Widget _buildTrendAnalysis() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Trend Analysis',
                style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),
            _buildTrendItem(
              'Overall Trend',
              'Upward',
              Icons.trending_up,
              Colors.green,
            ),
            _buildTrendItem(
              'Volatility',
              'Medium',
              Icons.show_chart,
              Colors.orange,
            ),
            _buildTrendItem(
              'News Sentiment',
              'Mostly Positive',
              Icons.thumb_up_outlined,
              Colors.blue,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTrendItem(
      String title, String value, IconData icon, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, color: color),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: Theme.of(context).textTheme.bodyLarge),
              Text(value,
                  style: TextStyle(color: color, fontWeight: FontWeight.bold)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNewsHighlights() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Recent News Highlights',
                style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),
            _buildNewsItem(
              'Positive',
              'Company announces strong Q4 earnings',
              '2h ago',
            ),
            _buildNewsItem(
              'Neutral',
              'Industry analysis report released',
              '5h ago',
            ),
            _buildNewsItem(
              'Negative',
              'Market volatility affects sector',
              '8h ago',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNewsItem(String sentiment, String headline, String time) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: sentiment == 'Positive'
                  ? Colors.green
                  : sentiment == 'Negative'
                      ? Colors.red
                      : Colors.grey,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(headline, style: Theme.of(context).textTheme.bodyMedium),
                Text(time,
                    style: Theme.of(context)
                        .textTheme
                        .bodySmall
                        ?.copyWith(color: Colors.grey)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
