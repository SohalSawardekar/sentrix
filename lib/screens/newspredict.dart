import 'package:flutter/material.dart';
import 'package:sentrix/services/Sentimental_Analysis.dart';

class Newspredict extends StatefulWidget {
  const Newspredict({super.key, required String symbol});

  @override
  State<Newspredict> createState() => _NewspredictState();
}

class _NewspredictState extends State<Newspredict> {
  final TextEditingController _textController = TextEditingController();
  String? _sentimentScore;
  String? _sentimentMagnitude;
  bool _isLoading = false;

  // Modify this function to use local emulator if needed
  Future<void> _analyzeSentiment() async {
    if (_textController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter some text to analyze')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final result = await analyzeSentiment(_textController.text);

      setState(() {
        // Safely handle result and check for 'error' in the response
        if (result['error'] != null) {
          _sentimentScore = 'N/A';
          _sentimentMagnitude = 'N/A';
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: ${result['error']}')),
          );
        } else {
          _sentimentScore = result['score']?.toString() ?? 'N/A';
          _sentimentMagnitude = result['magnitude']?.toString() ?? 'N/A';
        }
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
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
                onPressed: _isLoading ? null : _analyzeSentiment,
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
            if (_isLoading)
              const Center(child: CircularProgressIndicator())
            else if (_sentimentScore != null && _sentimentMagnitude != null)
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
              )
            else
              const Text(
                  "No analysis yet. Enter text and press 'Analyze Sentiment'."), // No data message
          ],
        ),
      ),
    );
  }

  Widget _buildSentimentInterpretation() {
    if (_sentimentScore == null) return const SizedBox.shrink();

    double? score = double.tryParse(_sentimentScore!);
    if (score == null) return const SizedBox.shrink();

    String interpretation;
    Color color;

    if (score > 0.5) {
      interpretation = "Very Positive";
      color = Colors.green;
    } else if (score > 0) {
      interpretation = "Positive";
      color = Colors.lightGreen;
    } else if (score == 0) {
      interpretation = "Neutral";
      color = Colors.grey;
    } else if (score > -0.5) {
      interpretation = "Negative";
      color = Colors.orange;
    } else {
      interpretation = "Very Negative";
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
