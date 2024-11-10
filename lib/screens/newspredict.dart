import 'package:flutter/material.dart';
import 'dart:math';

class Newspredict extends StatefulWidget {
  const Newspredict({super.key, required String symbol});

  @override
  State<Newspredict> createState() => _NewspredictState();
}

class _NewspredictState extends State<Newspredict> {
  final TextEditingController _textController = TextEditingController();
  String _sentimentScore = '0.0'; // Initial sentiment score
  String _sentimentMagnitude = ''; // Initial sentiment magnitude
  bool _isLoading = false;

  // Function to set random sentiment values
  void _analyzeSentiment() {
    if (_textController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter some text to analyze')),
      );
      return;
    }

    setState(() {
      // Generate random sentiment score between 0.3 and 0.7
      final random = Random();
      _sentimentScore =
          (0.3 + random.nextDouble() * (0.7 - 0.3)).toStringAsFixed(2);

      // Randomly select sentiment magnitude
      const magnitudes = ['Positive', 'Negative', 'Neutral'];
      _sentimentMagnitude = magnitudes[random.nextInt(magnitudes.length)];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("News Sentiment Predictor"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Enter News Text:",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _textController,
              maxLines: 4,
              decoration: const InputDecoration(
                hintText: "Type or paste news text here...",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _analyzeSentiment,
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text("Analyze Sentiment"),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              "Sentiment Analysis Result:",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Sentiment Score: $_sentimentScore",
                      style: const TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Sentiment Magnitude: $_sentimentMagnitude",
                      style: const TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 16),
                    _buildSentimentInterpretation(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSentimentInterpretation() {
    double? score = double.tryParse(_sentimentScore);
    if (score == null) return const SizedBox.shrink();

    String interpretation;
    Color color;

    if (score >= 0.55) {
      interpretation = "Positive";
      color = Colors.green;
    } else if (score >= 0.45) {
      interpretation = "Neutral";
      color = Colors.grey;
    } else {
      interpretation = "Negative";
      color = Colors.red;
    }

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        "Interpretation: $interpretation",
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }
}
