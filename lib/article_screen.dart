import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'dart:convert';

class ArticleScreen extends StatefulWidget {
  final String articleUrl;

  const ArticleScreen({required this.articleUrl});

  @override
  _ArticleScreenState createState() => _ArticleScreenState();
}

class _ArticleScreenState extends State<ArticleScreen> {
  final FlutterTts flutterTts = FlutterTts();
  late WebViewController _webViewController;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _setupTts();
    // Initialize WebView
    _initializeWebView();
  }

  void _initializeWebView() {
    // Initialize WebView
    _webViewController = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0x00000000))
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (url) {
            setState(() {
              isLoading = true;
            });
          },
          onPageFinished: (url) {
            setState(() {
              isLoading = false;
            });
            _speak();
          },
        ),
      )
    // Use loadRequest() instead of loadUrl() in version 4.x
      ..loadRequest(Uri.parse(widget.articleUrl));
  }

  Future<void> _setupTts() async {
    await flutterTts.setLanguage("en-US");
    await flutterTts.setSpeechRate(0.5);
    await flutterTts.setPitch(1.0);
    await flutterTts.awaitSpeakCompletion(true);
  }

  Future<void> _speak() async {
    String articleContent = await _getArticleContent();
    if (articleContent.isNotEmpty) {
      print("Speaking content: $articleContent");
      await flutterTts.speak(articleContent);
    } else {
      print("No article content found!");
    }
  }

  Future<String> _getArticleContent() async {
    try {
      // Run JavaScript to get article content
      final result = await _webViewController.runJavaScriptReturningResult("""
      (function() {
        var articleContent = '';
        var titleElement = document.querySelector('h1');
        if (titleElement) {
          var nextElement = titleElement.nextElementSibling;
          while (nextElement) {
            if (nextElement.tagName === 'P' || nextElement.tagName === 'DIV' || nextElement.tagName === 'SECTION') {
              articleContent += nextElement.innerText + ' ';
            }
            nextElement = nextElement.nextElementSibling;
          }
        }
        return JSON.stringify(articleContent.trim());
      })();
    """);

      // Decode the result and cast to String
      String content = jsonDecode(result.toString());

      print("Extracted Article Content: $content");

      return content.trim();
    } catch (e) {
      print("Error extracting content: $e");
      return '';
    }
  }

  @override
  void dispose() {
    flutterTts.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Article'),
        backgroundColor: Colors.blue,
        actions: [
          IconButton(
            icon: const Icon(Icons.volume_up),
            onPressed: _speak,
          ),
        ],
      ),
      body: WebViewWidget(
        controller: _webViewController,
      ),
    );
  }
}
