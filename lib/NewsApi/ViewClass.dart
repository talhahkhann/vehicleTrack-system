import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'ModeClass.dart';
import 'ServiceClass.dart';

class NewsScreen extends StatefulWidget {
  @override
  _NewsScreenState createState() => _NewsScreenState();
}

class _NewsScreenState extends State<NewsScreen> {
  late Future<List<Article>> _articlesFuture;

  @override
  void initState() {
    super.initState();
    _articlesFuture = NewsService().fetchArticles();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.brown.shade300,
        title: Text(
          "News Article",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: FutureBuilder<List<Article>>(
        future: _articlesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text("No articles found."));
          }

          final articles = snapshot.data!;
          return ListView.builder(
            itemCount: articles.length,
            itemBuilder: (context, index) {
              final article = articles[index];
              return Card(
                margin: EdgeInsets.all(8),
                child: ListTile(
                  leading: article.imageUrl.isNotEmpty
                      ? Image.network(
                          article.imageUrl,
                          width: 50,
                          fit: BoxFit.cover,
                        )
                      : null,
                  title: Text(article.title),
                  subtitle: Text(article.description),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ArticleDetails(article: article),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class ArticleDetails extends StatelessWidget {
  final Article article;

  ArticleDetails({required this.article});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(article.title),
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            article.imageUrl.isNotEmpty
                ? Image.network(article.imageUrl)
                : SizedBox.shrink(),
            SizedBox(height: 16),
            Text(
              article.title,
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              "Published At: ${article.publishedAt}",
              style: TextStyle(color: Colors.grey),
            ),
            SizedBox(height: 16),
            Text(article.description),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                // Open URL in browser
                launchUrl(Uri.parse(article.url));
              },
              child: Text("Read Full Article"),
            ),
          ],
        ),
      ),
    );
  }
}
