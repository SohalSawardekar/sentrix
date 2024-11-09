import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:sentrix/constants/SentimentData.dart'; // Import your SentimentData model

class MarketDataProvider with ChangeNotifier {
  List<SentimentData> _stocks = [];

  List<SentimentData> get stocks => _stocks;

  Future<void> fetchMarketData() async {
    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('sentimentData')
          .get(); // Fetch from 'sentimentData' collection

      // Debugging: Log the document data
      querySnapshot.docs.forEach((doc) {
        print(doc.data()); // Logs the fetched document data
      });

      print(querySnapshot.docs);

      _stocks = querySnapshot.docs.map((doc) {
        // Debugging: Log before conversion
        print('Converting doc: ${doc.id}');
        return SentimentData.fromFirestore(
            doc.data()); // Use SentimentData model
      }).toList();

      print("Done successfully");
      notifyListeners(); // Notify listeners when data changes
    } catch (error) {
      print('Error fetching market data: $error');
      throw Exception('Error fetching market data: $error');
    }
  }
}
