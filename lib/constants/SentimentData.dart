import 'package:googleapis/networkconnectivity/v1.dart';

class SentimentData {
  final String stock;
  final String symbol;
  final double sentimentScore;
  final String sentimentTrend;
  final List<int> sentimentTrendValues;
  final List<String> trendDates;

  SentimentData({
    required this.stock,
    required this.symbol,
    required this.sentimentScore,
    required this.sentimentTrend,
    required this.sentimentTrendValues,
    required this.trendDates,
  });

  // Factory method to convert Firestore data to the model
  factory SentimentData.fromFirestore(Map<String, dynamic> data) {
    return SentimentData(
      stock: data['stock'] ?? '',
      symbol: data['symbol'] ?? '',
      sentimentScore: data['sentimentScore']?.toDouble() ?? 0.0,
      sentimentTrend: data['sentimentTrend'] ?? '',
      sentimentTrendValues: List<int>.from(data['sentimentTrendValues'] ?? []),
      trendDates: List<String>.from(data['trendDates'] ?? []),
    );
  }

  // Method to convert the model to a map for uploading to Firestore
  Map<String, dynamic> toMap() {
    return {
      'stock': stock,
      'symbol': symbol,
      'sentimentScore': sentimentScore,
      'sentimentTrend': sentimentTrend,
      'sentimentTrendValues': sentimentTrendValues,
      'trendDates': trendDates,
    };
  }
}
