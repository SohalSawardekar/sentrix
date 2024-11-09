import 'dart:convert';
import 'package:http/http.dart' as http;

class SentimentAnalysisService {
  final String _apiKey =
      '68b32d2d512809ee0e88960dca402b7708e9705acfdfd59fb0853d8a';

  Future<double> analyzeSentiment(String text) async {
    final response = await http.post(
      Uri.parse('https://api.textrazor.com/'),
      headers: {
        'x-textrazor-key': _apiKey,
        'Content-Type': 'application/json',
      },
      body: jsonEncode({'text': text}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['response']['sentimentScore'];
    } else {
      throw Exception('Failed to analyze sentiment');
    }
  }
}
