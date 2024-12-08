import 'dart:convert';
import 'package:http/http.dart' as http;
import 'ModeClass.dart';

class NewsService {
  static const String baseUrl = "https://api.thenewsapi.com/v1/news/all";
  static const String apiKey = "LHtigl0i8UqyqfmbLca920KBCEz13L6ZdYuxBtBn";

  Future<List<Article>> fetchArticles() async {
    final url = Uri.parse(
        "$baseUrl?api_token=$apiKey&locale=us&language=en&categories=politics,tech,science");
    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        // Debug: Print the raw response
        print("Response Data: $data");

        // Check if the response contains 'data' and 'general' keys
        if (data['data'] != null && data['data'].isNotEmpty) {
          final articles = (data['data'] as List)
              .map((articleJson) => Article.fromJson(articleJson))
              .toList();
          return articles;
        } else {
          throw Exception("No articles found in the response.");
        }
      } else {
        throw Exception("Failed to load articles: ${response.statusCode}");
      }
    } catch (error) {
      throw Exception("Error fetching articles: $error");
    }
  }
}
