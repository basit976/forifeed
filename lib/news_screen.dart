// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'package:xml/xml.dart' as xml;
// import 'package:font_awesome_flutter/font_awesome_flutter.dart';
// import 'package:html/parser.dart' as html_parser;
// import 'package:flutter_tts/flutter_tts.dart'; // Import TTS package
// import 'package:cloud_firestore/cloud_firestore.dart'; // Firestore import
// import 'article_screen.dart'; // Ensure this file is correctly named and imported
// import 'firestore_service0.dart'; // Import FirestoreService

// class NewsScreen2Test extends StatefulWidget {
//   @override
//   _NewsScreenState createState() => _NewsScreenState();
// }

// class _NewsScreenState extends State<NewsScreen2Test> with SingleTickerProviderStateMixin {
//   int _selectedIndex = 0;
//   List<Map<String, String>> articles = [];
//   String errorMessage = '';
//   bool _showWhatsNewPanel = false;
//   bool _isLoading = false; // Track loading state
//   late AnimationController _controller;
//   late Animation<double> _panelAnimation;
//   late Animation<Offset> _textAnimation;
//   late Animation<double> _danceAnimation;
//   String _searchQuery = ""; // Store the search query

//   // Track sentiment state for each article
//   Map<String, String> sentimentVotes = {};

//   // FirestoreService instance
//   final FirestoreService _firestoreService = FirestoreService();

//   // Text-to-Speech instance
//   late FlutterTts flutterTts;
//   bool isSpeaking = false; // Track if TTS is speaking

//   @override
//   void initState() {
//     super.initState();
//     fetchNews();
//     _showWhatsNewPanelAfterDelay();

//     // Initialize TTS
//     flutterTts = FlutterTts();
//     flutterTts.setCompletionHandler(() {
//       setState(() {
//         isSpeaking = false;
//       });
//     });

//     _controller = AnimationController(
//       duration: const Duration(milliseconds: 1000),
//       vsync: this,
//     );

//     _panelAnimation = Tween<double>(begin: -100.0, end: 0.0).animate(
//       CurvedAnimation(
//         parent: _controller,
//         curve: Curves.easeInOut,
//       ),
//     );

//     _textAnimation =
//         Tween<Offset>(begin: Offset(-1.0, 0.0), end: Offset(0.0, 0.0)).animate(
//           CurvedAnimation(
//             parent: _controller,
//             curve: Interval(0.5, 1.0, curve: Curves.easeInOut),
//           ),
//         );

//     _danceAnimation = Tween<double>(begin: 0.9, end: 1.1).animate(
//         CurvedAnimation(
//           parent: _controller,
//           curve: Curves.elasticInOut,
//         ));
//   }

//   Future<void> fetchNews() async {
//     Map<String, String> rssSources = {
//       'https://www.thenews.com.pk/rss/1': 'The News International',
//       'https://tribune.com.pk/rss': 'Express Tribune',
//       'https://www.nation.com.pk/sitemap_news_google.xml': 'The Nation',
//       'https://www.dawn.com/feed': 'Dawn',
//       'https://www.pakistantoday.com.pk/feed/': 'Pakistan Today',
//     };

//     setState(() {
//       _isLoading = true;
//     });

//     for (String url in rssSources.keys) {
//       try {
//         final response = await http.get(Uri.parse(url));
//         if (response.statusCode == 200) {
//           final document = xml.XmlDocument.parse(response.body);
//           final items = document.findAllElements('item');

//           for (var item in items) {
//             final title = item.findElements('title').firstOrNull?.text ?? 'No Title';
//             final descriptionHtml = item.findElements('description').firstOrNull?.text ?? 'No Description';
//             final link = item.findElements('link').firstOrNull?.text ?? '';
//             final description = html_parser.parse(descriptionHtml).body?.text ?? 'No Description';

//             String? imageUrl;
//             final mediaContent = item.findElements('media:content').firstOrNull;
//             if (mediaContent != null) {
//               imageUrl = mediaContent.getAttribute('url');
//             }

//             articles.add({
//               'title': title,
//               'preview': description,
//               'fullContent': link,
//               'channel': rssSources[url] ?? 'Unknown Source',
//               'imageUrl': imageUrl ?? '',
//             });

//             // Fetch sentiment for the article from Firestore
//             _fetchSentimentForArticle(title);
//           }
//         }
//       } catch (e) {
//         setState(() {
//           errorMessage = 'Error fetching from $url: $e';
//         });
//       }
//     }

//     setState(() {
//       _isLoading = false;
//     });
//   }

//   void _showWhatsNewPanelAfterDelay() async {
//     await Future.delayed(Duration(seconds: 3));
//     setState(() {
//       _showWhatsNewPanel = true;
//       _controller.forward();
//     });
//   }

//   List<Map<String, String>> getFilteredArticles() {
//     if (_searchQuery.isEmpty) return articles;
//     return articles.where((article) {
//       return article['title']!.toLowerCase().contains(_searchQuery.toLowerCase()) ||
//           article['preview']!.toLowerCase().contains(_searchQuery.toLowerCase());
//     }).toList();
//   }

//   Future<void> _speak(String text) async {
//     if (isSpeaking) {
//       await flutterTts.stop(); // Stop TTS if already speaking
//       setState(() {
//         isSpeaking = false;
//       });
//     } else {
//       await flutterTts.speak(text); // Start speaking the given text
//       setState(() {
//         isSpeaking = true;
//       });
//     }
//   }

//   // Fetch sentiment from Firestore
//   Future<void> _fetchSentimentForArticle(String title) async {
//     try {
//       String? sentiment = await _firestoreService.getReview(title);
//       setState(() {
//         sentimentVotes[title] = sentiment ?? 'neutral'; // Default to 'neutral' if no sentiment is found
//       });
//     } catch (e) {
//       print("Error fetching sentiment for article: $e");
//     }
//   }

//   // Update sentiment in Firestore
//   Future<void> _updateSentiment(String title, String sentiment) async {
//     try {
//       await _firestoreService.addOrUpdateReview(title, sentiment);
//       setState(() {
//         sentimentVotes[title] = sentiment;
//       });
//     } catch (e) {
//       print("Error updating sentiment: $e");
//     }
//   }

//   List<Widget> _widgetOptions(BuildContext context) {
//     return <Widget>[
//       SingleChildScrollView(
//         child: Column(
//           children: [
//             Padding(
//               padding: const EdgeInsets.all(8.0),
//               child: TextField(
//                 onChanged: (query) {
//                   setState(() {
//                     _searchQuery = query;
//                   });
//                 },
//                 decoration: InputDecoration(
//                   hintText: 'Search articles...',
//                   prefixIcon: Icon(Icons.search),
//                   border: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(8.0),
//                   ),
//                 ),
//               ),
//             ),
//             if (_isLoading)
//               Center(child: CircularProgressIndicator())
//             else if (articles.isEmpty && errorMessage.isEmpty)
//               Center(child: CircularProgressIndicator())
//             else
//               ListView.builder(
//                 padding: const EdgeInsets.all(16.0),
//                 itemCount: getFilteredArticles().length,
//                 shrinkWrap: true,
//                 physics: NeverScrollableScrollPhysics(),
//                 itemBuilder: (context, index) {
//                   final article = getFilteredArticles()[index];
//                   return GestureDetector(
//                     onTap: () => _showArticle(context, article['fullContent']!),
//                     child: Container(
//                       decoration: BoxDecoration(
//                         color: Colors.white,
//                         borderRadius: BorderRadius.circular(15.0),
//                         boxShadow: [
//                           BoxShadow(
//                             color: Colors.black26,
//                             blurRadius: 4.0,
//                             offset: Offset(2, 2),
//                           ),
//                         ],
//                       ),
//                       margin: const EdgeInsets.only(bottom: 16.0),
//                       padding: const EdgeInsets.all(12.0),
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           if (article['imageUrl']!.isNotEmpty)
//                             ClipRRect(
//                               borderRadius: BorderRadius.circular(8.0),
//                               child: Image.network(
//                                 article['imageUrl']!,
//                                 height: 200,
//                                 width: double.infinity,
//                                 fit: BoxFit.cover,
//                               ),
//                             ),
//                           SizedBox(height: 8.0),
//                           Text(
//                             article['title']!,
//                             style: TextStyle(
//                               fontSize: 18.0,
//                               fontWeight: FontWeight.bold,
//                             ),
//                           ),
//                           SizedBox(height: 8.0),
//                           Text(
//                             article['preview']!,
//                             style: TextStyle(fontSize: 14.0),
//                           ),
//                           SizedBox(height: 8.0),
//                           Row(
//                             mainAxisAlignment: MainAxisAlignment.start,
//                             children: [
//                               IconButton(
//                                 icon: Icon(
//                                   sentimentVotes[article['title']] == 'positive'
//                                       ? FontAwesomeIcons.solidThumbsUp
//                                       : FontAwesomeIcons.thumbsUp,
//                                   color: Colors.green,
//                                 ),
//                                 onPressed: () {
//                                   _updateSentiment(article['title']!, 'positive');
//                                 },
//                               ),
//                               IconButton(
//                                 icon: Icon(
//                                   sentimentVotes[article['title']] == 'negative'
//                                       ? FontAwesomeIcons.solidThumbsDown
//                                       : FontAwesomeIcons.thumbsDown,
//                                   color: Colors.red,
//                                 ),
//                                 onPressed: () {
//                                   _updateSentiment(article['title']!, 'negative');
//                                 },
//                               ),
//                               IconButton(
//                                 icon: Icon(
//                                   sentimentVotes[article['title']] == 'neutral'
//                                       ? FontAwesomeIcons.solidMeh
//                                       : FontAwesomeIcons.meh,
//                                   color: Colors.grey,
//                                 ),
//                                 onPressed: () {
//                                   _updateSentiment(article['title']!, 'neutral');
//                                 },
//                               ),
//                               IconButton(
//                                 icon: Icon(
//                                   isSpeaking ? FontAwesomeIcons.pause : FontAwesomeIcons.volumeUp,
//                                   color: Colors.blue,
//                                 ),
//                                 onPressed: () => _speak(article['preview']!),
//                               ),
//                             ],
//                           ),
//                         ],
//                       ),
//                     ),
//                   );
//                 },
//               ),
//           ],
//         ),
//       ),
//     ];
//   }

//   void _showArticle(BuildContext context, String url) {
//     Navigator.push(
//       context,
//       MaterialPageRoute(
//         builder: (context) => ArticleScreen(articleUrl: url), // Pass the article URL here
//       ),
//     );
//   }


//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text("News Feed"),
//       ),
//       body: _widgetOptions(context)[_selectedIndex],
//       bottomNavigationBar: BottomNavigationBar(
//         currentIndex: _selectedIndex,
//         onTap: (index) {
//           setState(() {
//             _selectedIndex = index;
//           });
//         },
//         items: [
//           BottomNavigationBarItem(
//             icon: Icon(Icons.home),
//             label: 'Home',
//           ),
//           BottomNavigationBarItem(
//             icon: Icon(Icons.analytics),
//             label: 'Analytics',
//           ),
//           BottomNavigationBarItem(
//             icon: Icon(Icons.offline_bolt),
//             label: 'Offline',
//           ),
//           BottomNavigationBarItem(
//             icon: Icon(Icons.note),
//             label: 'Documents',
//           ),
//           BottomNavigationBarItem(
//             icon: Icon(Icons.person),
//             label: 'Profile',
//           ),
//         ],
//       ),
//     );
//   }
// }
