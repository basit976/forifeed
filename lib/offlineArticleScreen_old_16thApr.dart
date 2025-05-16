import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:html/parser.dart' as html_parser;

class OfflineArticleScreen extends StatefulWidget {
  final String articleId;

  OfflineArticleScreen({required this.articleId});

  @override
  _OfflineArticleScreenState createState() => _OfflineArticleScreenState();
}

class _OfflineArticleScreenState extends State<OfflineArticleScreen> {
  String articleContent = '';
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchArticle();
  }

  Future<void> saveArticleForOffline({
    required String fullHtmlContent,
    required String title,
  }) async {
    try {
      final document = html_parser.parse(fullHtmlContent);
      final cleanContent = document.body?.text ?? 'No readable content';

      // Log the raw fullHtmlContent
      print("Raw HTML content: $fullHtmlContent");

      // Log cleaned content
      print('Cleaned and parsed content: $cleanContent');

      // Ensure only cleaned content is stored into Firestore
      await FirebaseFirestore.instance.collection('offline_articles').add({
        'content': cleanContent,
        'title': title,
        'timestamp': DateTime.now().toUtc(),
      });

      print("Article successfully saved for offline reading!");
    } catch (e) {
      print("Error saving article: $e");
    }
  }

  Future<void> fetchArticle() async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('offline_articles')
          .doc(widget.articleId)
          .get();

      // Log raw fetched snapshot for visibility
      print("Raw snapshot data: ${snapshot.data()}");

      if (snapshot.exists) {
        final fetchedContent = snapshot['content'];

        // Log what content is being rendered
        print('Fetched content from Firestore: $fetchedContent');

        setState(() {
          articleContent = fetchedContent ?? 'No valid data found';
          isLoading = false;
        });
      } else {
        setState(() {
          articleContent = 'No offline article found';
          isLoading = false;
        });
      }
    } catch (e) {
      print("Error fetching content: $e");
      setState(() {
        articleContent = 'Error loading offline content';
        isLoading = false;
      });
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Offline Article'),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : Padding(
        padding: const EdgeInsets.all(8.0),
        child: SingleChildScrollView(
          child: Text(
            articleContent.isNotEmpty
                ? articleContent
                : 'Error loading article...',
            style: TextStyle(fontSize: 16),
          ),
        ),
      ),
    );
  }
}
