import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import './News_Screen2.dart';
import 'package:webview_flutter/webview_flutter.dart';

class OfflineArticleScreen extends StatefulWidget {
  final String articleId;

  const OfflineArticleScreen({Key? key, required this.articleId}) : super(key: key);

  @override
  _OfflineArticleScreenState createState() => _OfflineArticleScreenState();
}

class _OfflineArticleScreenState extends State<OfflineArticleScreen> {
  List<Map<String, String>> offlineArticles = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchOfflineArticles();
  }

  Future<void> fetchOfflineArticles() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        setState(() {
          offlineArticles = [];
          isLoading = false;
        });
        return;
      }

      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('offline_articles')
          .get();

      List<Map<String, String>> articles = snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>?; // Ensure data is a map or null
        return {
          'title': doc.id, // Document ID as title
          'link': (data != null && data["title"] is String) ? data["title"] as String : "", // Ensuring a String value for 'link'
        };
      }).toList();

      setState(() {
        offlineArticles = articles;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        offlineArticles = [];
        isLoading = false;
      });
    }
  }

  void openArticle(String url) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => WebViewScreen(url: url)), // ✅ Fixed WebViewScreen
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Offline Articles", style: TextStyle(fontWeight: FontWeight.bold)),
        elevation: 0,
        backgroundColor: Colors.transparent,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF1A237E), Color(0xFF0D47A1)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF1A237E), Color(0xFF0D47A1), Color(0xFF64B5F6)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: isLoading
              ? Center(child: CircularProgressIndicator(color: Colors.white))
              : offlineArticles.isEmpty
              ? Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, size: 50, color: Colors.white),
                SizedBox(height: 10),
                Text(
                  "No offline articles found.",
                  style: TextStyle(fontSize: 18, color: Colors.white),
                ),
              ],
            ),
          )
              : Padding(
            padding: EdgeInsets.only(top: 10),
            child: ListView.builder(
              padding: EdgeInsets.all(12),
              itemCount: offlineArticles.length,
              itemBuilder: (context, index) {
                return Card(
                  color: Colors.white.withOpacity(0.9),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  elevation: 4,
                  child: ListTile(
                    title: Text(
                      offlineArticles[index]['title']!,
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black),
                    ),
                    leading: Icon(Icons.article, color: Colors.blueAccent),
                    trailing: Icon(Icons.arrow_forward_ios, color: Colors.blueAccent),
                    onTap: () {
                      openArticle(offlineArticles[index]['link']!);
                    },
                  ),
                );
              },
            ),
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.blue.shade900.withOpacity(0.8),
        selectedItemColor: Colors.blueAccent,
        unselectedItemColor: Colors.blueAccent,
        currentIndex: 2,
        onTap: (index) {
          if (index == 0) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => NewsScreen2()),
            );
          }
        },
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.analytics), label: "Analytics"),
          BottomNavigationBarItem(icon: Icon(Icons.wifi_off), label: "Non-Wifi News"),
          BottomNavigationBarItem(icon: Icon(Icons.account_circle), label: "Account"),
        ],
      ),
    );
  }
}

class WebViewScreen extends StatefulWidget {
  final String url;

  const WebViewScreen({Key? key, required this.url}) : super(key: key);

  @override
  _WebViewScreenState createState() => _WebViewScreenState();
}

class _WebViewScreenState extends State<WebViewScreen> {
  late final WebViewController controller;

  @override
  void initState() {
    super.initState();
    controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted) // ✅ Fixed JavaScriptMode
      ..loadRequest(Uri.parse(widget.url)); // ✅ Fixed URL parsing
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Article")),
      body: WebViewWidget(controller: controller), // ✅ Fixed WebView usage
    );
  }
}
