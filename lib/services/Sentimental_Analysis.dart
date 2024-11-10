import 'package:cloud_functions/cloud_functions.dart';

Future<Map<String, dynamic>> analyzeSentiment(String text) async {
  final HttpsCallable callable =
      FirebaseFunctions.instance.httpsCallable('analyzeSentiment');
  try {
    final response = await callable.call(<String, dynamic>{
      'text': text,
    });

    // Ensure the response contains score and magnitude
    final sentimentScore = response.data['score'];
    final sentimentMagnitude = response.data['magnitude'];

    return {
      'score': sentimentScore,
      'magnitude': sentimentMagnitude,
      'error': null, // Add error as null if no error
    };
  } catch (e) {
    // Handle any error and return it
    return {
      'score': null,
      'magnitude': null,
      'error': e.toString(),
    };
  }
}
