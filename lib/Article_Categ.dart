import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:webview_flutter/webview_flutter.dart';

class ArticleCategScreen extends StatefulWidget {
  final String articleUrl;
  final String title;

  const ArticleCategScreen({
    Key? key,
    required this.articleUrl,
    required this.title,
  }) : super(key: key);

  @override
  _ArticleCategScreenState createState() => _ArticleCategScreenState();
}

class _ArticleCategScreenState extends State<ArticleCategScreen> {
  final FlutterTts flutterTts = FlutterTts();
  late WebViewController _webViewController;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _setupTts();
    _initializeWebViewController();
  }

  Future<void> _setupTts() async {
    await flutterTts.setLanguage("en-US");
    await flutterTts.setSpeechRate(0.5);
    await flutterTts.setPitch(1.0);
    await flutterTts.awaitSpeakCompletion(true);
  }

  void _initializeWebViewController() {
    _webViewController = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0x00000000))
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (String url) {
            setState(() {
              isLoading = true;
            });
          },
          onPageFinished: (String url) {
            setState(() {
              isLoading = false;
            });
          },
          onWebResourceError: (error) {
            print("WebView Error: ${error.description}");
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.articleUrl));
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
      String content = await _webViewController.runJavaScriptReturningResult("""
        (function() {
          let articleContent = '';
          const titleElement = document.querySelector('h1');
          if (titleElement) {
            let nextElement = titleElement.nextElementSibling;
            while (nextElement) {
              if (['P', 'DIV', 'SECTION'].includes(nextElement.tagName)) {
                articleContent += nextElement.innerText + ' ';
              }
              nextElement = nextElement.nextElementSibling;
            }
          }
          return articleContent.trim();
        })();
      """) as String;

      print("Extracted Article Content: $content");
      return content.trim();
    } catch (e) {
      print("JavaScript Error: $e");
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
        title: Text(widget.title),
        backgroundColor: Colors.blue,
        actions: [
          IconButton(
            icon: Icon(Icons.volume_up),
            onPressed: _speak,
          ),
        ],
      ),
      body: Stack(
        children: [
          WebViewWidget(controller: _webViewController),
          if (isLoading)
            Center(child: CircularProgressIndicator()),
        ],
      ),
    );
  }
}
