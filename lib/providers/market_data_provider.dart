// TODO Implement this library.
import 'package:flutter/material.dart';

class MarketDataProvider with ChangeNotifier {
  // Sample market data variables
  Map<String, dynamic> _marketData = {
    'marketCap': '1',
    'volume': '2',
    'gainers': '3',
    'losers': '4',
  };

  List<Map<String, dynamic>> _trendingStocks = [];

  // Getters for market data and trending stocks
  Map<String, dynamic> get marketData => _marketData;
  List<Map<String, dynamic>> get trendingStocks => _trendingStocks;

  // Method to fetch market data
  Future<void> fetchMarketData() async {
    try {
      // Simulate network delay
      // await Future.delayed(const Duration(seconds: 2));

      // In a real application, replace this with API fetching logic
      _marketData = {
        'marketCap': '2.1 Trillion',
        'volume': '1.2B',
        'gainers': '35',
        'losers': '10',
      };

      // Sample trending stocks
      _trendingStocks = [
        {'symbol': 'AAPL', 'change': 1.2, 'sentiment': 0.8},
        {'symbol': 'TSLA', 'change': -0.5, 'sentiment': 0.6},
        {'symbol': 'GOOG', 'change': 2.4, 'sentiment': 0.9},
      ];

      notifyListeners(); // Notify listeners when data changes
    } catch (e) {
      throw Exception('Failed to load market data: $e');
    }
  }
}
