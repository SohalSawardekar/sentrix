import 'package:flutter/material.dart';

class SentimentDataProvider with ChangeNotifier {
  double _overallSentiment = 0.0;
  String _sentimentDescription = "Loading...";
  List<double> _sentimentTrend = [];
  List<String> trendDates = []; // For charting dates
  List<Map<String, String>> _recentInsights = [];
  Map<String, dynamic> _sentimentDetails = {}; // Extra data, e.g., by sector

  double get overallSentiment => _overallSentiment;
  String get sentimentDescription => _sentimentDescription;
  List<double> get sentimentTrend => _sentimentTrend;
  List<Map<String, String>> get recentInsights => _recentInsights;
  Map<String, dynamic> get sentimentDetails => _sentimentDetails;

  Future<void> fetchSentimentData() async {
    try {
      // Simulate a network request with delay
      await Future.delayed(const Duration(seconds: 2));

      // Example sentiment data
      _overallSentiment = 0.75; // 75% positive sentiment
      _sentimentDescription = 'Bullish Sentiment';

      // Simulated Sentiment Trend over the past 10 days with corresponding dates
      _sentimentTrend = [0.6, 0.65, 0.7, 0.75, 0.78, 0.8, 0.85, 0.9, 0.88, 0.9];
      trendDates = [
        '2024-11-01',
        '2024-11-02',
        '2024-11-03',
        '2024-11-04',
        '2024-11-05',
        '2024-11-06',
        '2024-11-07',
        '2024-11-08',
        '2024-11-09',
        '2024-11-10'
      ];

      // Example recent insights
      _recentInsights = [
        {
          'title': 'Tech Sector Optimism',
          'summary':
              'Increased investments in AI and Cloud have boosted tech sentiment.'
        },
        {
          'title': 'Energy Sector Caution',
          'summary':
              'Rising oil prices create concerns over energy sector stability.'
        },
        {
          'title': 'Market Rebound Anticipated',
          'summary':
              'Analysts expect a market rebound following recent declines in global stocks.'
        },
      ];

      // Example sentiment details for specific sectors or sentiments
      _sentimentDetails = {
        'Technology': 0.85, // 85% positive sentiment
        'Healthcare': 0.65,
        'Finance': 0.7,
        'Energy': 0.5,
      };

      notifyListeners(); // Notify listeners when data is updated
    } catch (e) {
      rethrow; // Rethrow the error for error handling in the UI
    }
  }
}
