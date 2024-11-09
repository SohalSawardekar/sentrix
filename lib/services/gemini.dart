import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class SentimentAnalysisScreen extends StatefulWidget {
  const SentimentAnalysisScreen({super.key});

  @override
  _SentimentAnalysisScreenState createState() =>
      _SentimentAnalysisScreenState();
}

class _SentimentAnalysisScreenState extends State<SentimentAnalysisScreen> {
  String _sentimentResult = '';
  String _sentimentLabel = ''; // Added for sentiment label (positive/negative)

  // Replace with your Gemini API URL (for NLP Sentiment Analysis).
  final String apiUrl =
      'https://gemini.googleapis.com/v1alpha/sentiment:analyze';

  // Your Google Cloud API key
  final String apiKey = 'AIzaSyAgZiH_c_5EIZbfai1gXg4rJ56USzotdYw';

  Future<void> fetchSentimentAnalysis(String text) async {
    try {
      final response = await http.post(
        Uri.parse('$apiUrl?key=$apiKey'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'document': {
            'type': 'PLAIN_TEXT',
            'content': text,
          },
        }),
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        final score = responseData['documentSentiment']['score'];

        // Set sentiment based on score
        String sentimentLabel;
        if (score > 0) {
          sentimentLabel = 'Positive';
        } else if (score < 0) {
          sentimentLabel = 'Negative';
        } else {
          sentimentLabel = 'Neutral';
        }

        setState(() {
          _sentimentResult = score
              .toStringAsFixed(2); // Display score rounded to 2 decimal places
          _sentimentLabel = sentimentLabel; // Display sentiment label
        });
      } else {
        throw Exception('Failed to load sentiment analysis');
      }
    } catch (e) {
      setState(() {
        _sentimentResult = 'Error: $e';
        _sentimentLabel = ''; // Clear sentiment label in case of error
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sentiment Analysis'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Enter Text for Sentiment Analysis:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            TextField(
              onChanged: (text) {
                setState(() {
                  _sentimentResult = '';
                  _sentimentLabel = ''; // Clear previous sentiment
                });
              },
              decoration: InputDecoration(
                hintText: 'Type here...',
                border: OutlineInputBorder(),
              ),
              maxLines: 5,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                final text =
                    'The market is doing well and sentiment is positive'; // Example text
                fetchSentimentAnalysis(text); // Call the API
              },
              child: const Text('Analyze Sentiment'),
            ),
            const SizedBox(height: 16),
            if (_sentimentResult.isNotEmpty)
              Text(
                'Sentiment Score: $_sentimentResult',
                style: TextStyle(fontSize: 16, color: Colors.black),
              ),
            if (_sentimentLabel.isNotEmpty)
              Text(
                'Sentiment: $_sentimentLabel', // Display sentiment type
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: _sentimentLabel == 'Positive'
                      ? Colors.green
                      : (_sentimentLabel == 'Negative'
                          ? Colors.red
                          : Colors.orange),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
