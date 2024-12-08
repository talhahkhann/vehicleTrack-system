import 'dart:convert';

class Article {
  final String title;
  final String description;
  final String imageUrl;
  final String publishedAt;
  final String url;

  Article({
    required this.title,
    required this.description,
    required this.imageUrl,
    required this.publishedAt,
    required this.url,
  });

  factory Article.fromJson(Map<String, dynamic> json) {
    return Article(
      title: _decodeJson(json['title']),
      description: _decodeJson(json['description']),
      imageUrl: json['image_url'] ?? '',
      publishedAt: json['published_at'] ?? 'Unknown',
      url: json['url'] ?? '',
    );
  }

  static String _decodeJson(String? value) {
    if (value == null) return 'No Data';
    return utf8.decode(value.runes.toList());
  }
}
