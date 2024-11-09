import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class GeminiService {
  final String apiUrl =
      'https://api.gemini.com/v1/'; // Update with actual Gemini API endpoint
  final String apiKey = 'AIzaSyCvGjtP2bFeagbdbA5b1ptNSWxgGyfIHPI';

  Future<dynamic> fetchWebData(String query) async {
    try {
      final response = await http.get(
        Uri.parse('$apiUrl/data?query=$query'),
        headers: {'Authorization': 'Bearer $apiKey'},
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to load data');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }
}

class WebDataPage extends StatefulWidget {
  const WebDataPage({super.key});

  @override
  _WebDataPageState createState() => _WebDataPageState();
}

class _WebDataPageState extends State<WebDataPage> {
  late Future<dynamic> _webData;

  @override
  void initState() {
    super.initState();
    _webData = GeminiService().fetchWebData('latest trends');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Web Data')),
      body: FutureBuilder<dynamic>(
        future: _webData,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            // Display the fetched data
            return ListView.builder(
              itemCount: snapshot.data.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(snapshot.data[index]['title']),
                );
              },
            );
          }
        },
      ),
    );
  }
}
