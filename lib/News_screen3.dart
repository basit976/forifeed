// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import './selection.dart';
// import 'package:http/http.dart' as http;
// import 'package:tflite_flutter/tflite_flutter.dart';
// import 'package:xml/xml.dart' as xml;
// import 'package:font_awesome_flutter/font_awesome_flutter.dart';
// import 'package:html/parser.dart' as html_parser;
// import 'package:flutter_tts/flutter_tts.dart'; // Import TTS package
// import 'ProfileScreen.dart';
// import 'article_screen.dart'; // Ensure this file exists
// import 'firebase_service.dart';
// import 'news_screen.dart';
// import 'offlineArticleScreen.dart'; // Import Firebase service class
// import 'nav_bar.dart';
// import 'package:flutter/material.dart';
// import 'dart:typed_data';
// import 'sentiment_service.dart';
// import 'dart:convert';
// import 'package:lottie/lottie.dart';


// class NewsScreen2 extends StatefulWidget {
//   @override
//   _NewsScreenState createState() => _NewsScreenState();
// }

// class _NewsScreenState extends State<NewsScreen2>
//     with SingleTickerProviderStateMixin {
//   final firebaseService = FirebaseService();
//   final FirebaseAuth _auth = FirebaseAuth.instance;
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;
//   final SentimentService sentimentService = SentimentService();

//   int _selectedIndex = 0;
//   List<Map<String, dynamic>> articles = [];
//   List<Map<String, dynamic>> unfilteredArticles = [];
//   String errorMessage = '';
//   bool _isLoading = false; // Track loading state
//   late FlutterTts flutterTts;
//   bool isSpeaking = false; // Track if TTS is speaking

//   String _searchQuery = ""; // Store the search query
//   Map<String, String> sentimentVotes = {}; // Sentiment state for each article
//   List<String> followedChannels = []; // List to store followed channels

//   @override
//   void initState() {
//     super.initState();
//     sentimentService.loadModel();
//     fetchFollowedChannels(); // Fetch followed channels from Firebase
//     flutterTts = FlutterTts();
//     flutterTts.setCompletionHandler(() {
//       setState(() {
//         isSpeaking = false;
//       });
//     });
//   }

//   @override
//   void dispose() {
//     sentimentService.closeModel(); // Free up resources
//     super.dispose();
//   }

//   late Interpreter _interpreter;
//   Future<void> loadModel() async {
//     try {
//       _interpreter =
//       await Interpreter.fromAsset('assets/sentiment_model.tflite');
//       print("Model loaded successfully!");
//     } catch (e) {
//       print("Error loading model: $e");
//     }
//   }

//   Future<void> saveArticleForOffline(String title, String url) async {
//     try {
//       // Fetch the full article's content
//       final response = await http.get(Uri.parse(url));

//       if (response.statusCode == 200) {
//         // Save the full content along with the title to Firestore
//         await FirebaseFirestore.instance
//             .collection('offline_articles')
//             .doc(title)
//             .set({
//           'title': title,
//           'content': response.body, // Full HTML or text content
//           'timestamp': DateTime.now(),
//         });
//         print('Article saved successfully for offline reading');
//       } else {
//         throw Exception('Failed to load article');
//       }
//     } catch (e) {
//       print('Error saving article: $e');
//     }
//   }

//   Future<void> classifySentiment(String inputText) async {
//     try {
//       // Preprocess input text (tokenize and pad as needed)
//       List<double> input = preprocessText(inputText, 256); // Adjust maxLength
//       var inputTensor = Float32List.fromList(input);

//       // Create output buffer (adjust shape to match model output)
//       var output = List.filled(3, 0.0).reshape([1, 3]);

//       // Run inference
//       _interpreter.run(inputTensor, output);

//       // Find the sentiment with the highest probability
//       int sentimentIndex =
//       output[0].indexOf(output[0].reduce((a, b) => a > b ? a : b));
//       String sentiment = ['negative', 'neutral', 'positive'][sentimentIndex];

//       print("Sentiment: $sentiment");
//     } catch (e) {
//       print("Error classifying sentiment: $e");
//     }
//   }

//   List<double> preprocessText(String text, int maxLength) {
//     // Convert text into a list of tokenized numeric values (simple hash for now)
//     List<double> tokens =
//     text.split(' ').map((word) => word.hashCode.toDouble()).toList();

//     // Truncate or pad to match the expected input length
//     tokens = tokens.take(maxLength).toList();
//     while (tokens.length < maxLength) {
//       tokens.add(0.0); // Pad with zeros
//     }

//     return tokens;
//   }

//   Future<void> saveComment(
//       String userId, String articleTitle, String commentText, String channel) async {
//     // final sentimentService = SentimentService();
//     // await sentimentService.loadModel(); // Ensure the model is loaded before use

//     try {
//       // Analyze sentiment

//       // String sentiment = await sentimentService.analyzeSentiment(commentText);
//       String sentiment = await analyzeSentiment(commentText);

//       // Save to Firestore
//       final commentDoc = FirebaseFirestore.instance.collection('comments').add({
//         'userId': userId,
//         'articleTitle': articleTitle,
//         'commentText': commentText,
//         'sentiment': sentiment,
//         'timestamp': FieldValue.serverTimestamp(),
//         'channel': channel
//       });

//       print("Comment saved with sentiment: $sentiment");
//     } catch (e) {
//       print("Error saving comment: $e");
//     }
//   }

//   Future<void> fetchFollowedChannels() async {
//     try {
//       followedChannels = await FirebaseService().fetchFollowedChannels();
//       fetchNews(); // After fetching followed channels, fetch the news
//     } catch (e) {
//       setState(() {
//         errorMessage = 'Error fetching followed channels: $e';
//       });
//     }
//   }

//   Future<void> fetchNews() async {
//     Map<String, String> rssSources = {
//       'https://www.thenews.com.pk/rss/1/10': 'The News International',
//       'https://www.thenews.com.pk/rss/1/1': 'The News International',
//       'https://www.thenews.com.pk/rss/1/2': 'The News International',
//       'https://www.thenews.com.pk/rss/1/7': 'The News International',
//       'https://tribune.com.pk/feed/latest': 'Express Tribune',
//       'https://tribune.com.pk/feed/home': 'Express Tribune',
//       'https://tribune.com.pk/feed/pakistan': 'Express Tribune',
//       'https://tribune.com.pk/feed/business': 'Express Tribune',
//       'https://tribune.com.pk/feed/politics': 'Express Tribune',
//       'https://tribune.com.pk/feed/sindh': 'Express Tribune',
//       'https://www.nation.com.pk/sitemap_news_google.xml': 'The Nation',
//       'https://www.dawn.com/feed': 'Dawn',
//       'https://www.pakistantoday.com.pk/category/national/feed/':
//       'Pakistan Today',
//       'https://www.pakistantoday.com.pk/feed/': 'Pakistan Today',
//       'https://www.brecorder.com/feeds/latest-news/': 'Business Recorder',
//       'https://www.sundayguardianlive.com/feed': 'Sunday Guardian',
//       'https://www.mashriqtv.pk/feed/': 'Mashriq TV',
//       'https://mashriqtv.pk/feed/?paged=1': 'Mashriq TV',
//       'https://mashriqtv.pk/feed/?paged=2': 'Mashriq TV',
//       'https://mashriqtv.pk/feed/?paged=3': 'Mashriq TV',
//       'https://mashriqtv.pk/feed/?paged=4': 'Mashriq TV',
//       'https://mashriqtv.pk/feed/?paged=5': 'Mashriq TV',
//       'https://www.24newshd.tv/feed': '24 News HD',
//       'https://abbtakk.tv/feed/': 'Ab Takk News',
//       'https://abbtakk.tv/feed/?paged=2': 'Ab Takk News',
//       'https://abbtakk.tv/feed/?paged=3': 'Ab Takk News',
//       'https://abbtakk.tv/feed/?paged=4': 'Ab Takk News',
//       'https://abbtakk.tv/feed/?paged=5': 'Ab Takk News',
//       'https://abbtakk.tv/feed/?paged=6': 'Ab Takk News',
//       'https://abbtakk.tv/feed/?paged=7': 'Ab Takk News',
//       'https://abbtakk.tv/feed/?paged=8': 'Ab Takk News',
//       'https://humnews.pk/latest/feed/': 'Hum News',
//       'https://humnews.pk/latest/feed/?paged=2': 'Hum News',
//       'https://humnews.pk/latest/feed/?paged=3': 'Hum News',
//       'https://humnews.pk/latest/feed/?paged=4': 'Hum News',
//       'https://humnews.pk/latest/feed/?paged=5': 'Hum News',
//       'https://humnews.pk/latest/feed/?paged=6': 'Hum News',
//       'https://humnews.pk/latest/feed/?paged=7': 'Hum News',
//       'https://www.express.pk/feed': 'Express News',
//       'https://www.express.pk/feed?paged=2': 'Express News',
//       'https://arynews.tv/feed/': 'ARY News',
//       'https://arynews.tv/feed/?paged=2': 'ARY News',
//       'https://arynews.tv/feed/?paged=3': 'ARY News',
//       'https://arynews.tv/feed/?paged=4': 'ARY News',
//       'https://arynews.tv/feed/?paged=5': 'ARY News',
//       'https://arynews.tv/feed/?paged=6': 'ARY News',
//       'https://arynews.tv/feed/?paged=7': 'ARY News',
//       'https://arynews.tv/feed/?paged=8': 'ARY News',
//       'https://www.geo.tv/rss/1/53': 'Geo News',
//       'https://www.bolnews.com/feed/': 'Bol News',
//       'https://www.bolnews.com/feed/?paged=2': 'Bol News',
//       'https://www.bolnews.com/feed/?paged=3': 'Bol News',
//       'https://www.bolnews.com/feed/?paged=4': 'Bol News',
//       'http://feeds.bbci.co.uk/news/rss.xml': 'BBC News',
//       'https://rss.nytimes.com/services/xml/rss/nyt/HomePage.xml':
//       'The New York Times',
//       //'https://rss.cnn.com/rss/edition.rss': 'CNN',
//       'https://feeds.skynews.com/feeds/rss/world.xml': 'Sky News',
//       'https://feeds.skynews.com/feeds/rss/home.xml': 'Sky News',
//       'https://feeds.skynews.com/feeds/rss/technology.xml': 'Sky News',
//       'https://feeds.skynews.com/feeds/rss/politics.xml': 'Sky News',
//       'https://feeds.skynews.com/feeds/rss/entertainment.xml': 'Sky News',
//       'https://feeds.skynews.com/feeds/rss/uk.xml': 'Sky News',
//       'https://feeds.skynews.com/feeds/rss/business.xml': 'Sky News',
//       'https://gnnhd.tv/rss/latest': 'GNN',
//       'https://feeds.foxnews.com/foxnews/latest': 'Fox News',
//       'https://moxie.foxnews.com/google-publisher/world.xml': 'Fox News',
//       'https://moxie.foxnews.com/google-publisher/politics.xml': 'Fox News',
//       'https://moxie.foxnews.com/google-publisher/media.xml': 'Fox News',
//       'https://news.google.com/rss?hl=en-US&gl=US&ceid=US:en': 'Google News',
//       'https://www.aljazeera.com/xml/rss/all.xml': 'Al Jazeera',
//       'https://www.reuters.com/rssFeed/news': 'Reuters',
//       'https://www.theguardian.com/world/rss': 'The Guardian',
//       'https://feeds.bbci.co.uk/news/rss.xml': 'BBC Top Stories',
//       'https://chaski.huffpost.com/us/auto/vertical/arts': 'HuffPost',
//       'https://a-sports.tv/feed/': 'ASports',
//       'https://a-sports.tv/feed/?paged=2': 'ASports',
//       'https://a-sports.tv/feed/?paged=3': 'ASports',
//       'https://www.aaj.tv/feeds/latest-news/': 'Aaj Tv',
//       'https://www.independent.co.uk/asia/rss': 'Independant - Asia',
//       'https://www.independent.co.uk/rss': 'Independant - UK',
//       'https://www.cbsnews.com/latest/rss/main': 'CBS',

//     };
//     setState(() {
//       _isLoading = true;
//     });

//     articles.clear();

//     // Step 1: Fetch all comments for the followed channels in a single query
//     final allCommentsQuery = await FirebaseFirestore.instance
//         .collection('comments')
//         .where('channel',
//         whereIn: followedChannels) // Ensure "channel" exists in comments
//         .get();

//     // Step 2: Group comments by articleTitle and calculate average sentiment
//     Map<String, Map<String, dynamic>> groupedComments = {};
//     for (var doc in allCommentsQuery.docs) {
//       final data = doc.data();
//       final articleTitle = data['articleTitle'] ?? '';
//       final sentiment = data['sentiment'] ?? 'neutral'; // Default to 'neutral' if missing

//       if (articleTitle.isNotEmpty) {
//         groupedComments.putIfAbsent(articleTitle, () => {
//           'comments': [],
//           'sentimentCount': {'positive': 0, 'negative': 0, 'neutral': 0}
//         });

//         // Add the comment
//         groupedComments[articleTitle]?['comments'].add({
//           'commentText': data['commentText'] ?? '',
//           'sentiment': sentiment,
//           'timestamp': data['timestamp'] != null
//               ? (data['timestamp'] as Timestamp).toDate().toString()
//               : '',
//         });

//         // Update sentiment count
//         groupedComments[articleTitle]?['sentimentCount'][sentiment] =
//             (groupedComments[articleTitle]?['sentimentCount'][sentiment] ?? 0) + 1;
//       }
//     }

//     // Step 3: Attach the most common sentiment to each article
//     groupedComments.forEach((articleTitle, commentData) {
//       final sentimentCount = commentData['sentimentCount'];
//       String dominantSentiment = 'neutral';
//       int maxCount = 0;

//       sentimentCount.forEach((sentiment, count) {
//         if (count > maxCount) {
//           maxCount = count;
//           dominantSentiment = sentiment;
//         }
//       });

//       // Attach dominant sentiment
//       commentData['dominantSentiment'] = dominantSentiment;
//     });

//     for (String channel in followedChannels) {
//       List<String> rssUrls = rssSources.entries
//           .where((entry) => entry.value == channel)
//           .map((entry) => entry.key)
//           .toList();

//       if (rssUrls.isEmpty) continue;

//       for (String rssUrl in rssUrls) {
//         try {
//           final response = await http.get(Uri.parse(rssUrl));
//           if (response.statusCode == 200) {
//             final document = xml.XmlDocument.parse(response.body);
//             final items = document.findAllElements('item');

//             for (var item in items) {
//               final title = item.findElements('title').first.text;
//               final descriptionHtml = item.findElements('description').first.text;
//               final link = item.findElements('link').first.text;
//               final description = html_parser.parse(descriptionHtml).body?.text ?? '';

//               // Fetch the article's HTML to extract the image
//               String imageUrl = '';
//               try {
//                 final articleResponse = await http.get(Uri.parse(link));
//                 if (articleResponse.statusCode == 200) {
//                   final articleDocument = html_parser.parse(articleResponse.body);
//                   final imageElement = articleDocument.querySelector('meta[property="og:image"]');
//                   imageUrl = imageElement?.attributes['content'] ?? '';
//                 }
//               } catch (e) {
//                 print('Error fetching image for article: $title, $e');
//               }

//               // Build article object
//               Map<String, dynamic> article = {
//                 'title': title,
//                 'preview': description,
//                 'fullContent': link,
//                 'imageUrl': imageUrl, // Include the fetched image URL
//                 'source': channel,
//                 'comments': groupedComments[title] ?? [], // Attach pre-fetched comments
//                 'dominantSentiment': groupedComments[title]?['dominantSentiment'] ?? 'neutral',
//               };

//               articles.add(article);
//             }
//           }
//           print("articles list: $articles");
//         } catch (e) {
//           setState(() {
//             errorMessage = 'Error fetching news from $channel: $e';
//           });
//         }
//       }

//     }

//     setState(() {
//       _isLoading = false;
//     });
//   }

//   List<Map<String, dynamic>> getFilteredArticles() {
//     print("articleS: $articles");
//     if (_searchQuery.isEmpty) return articles;
//     return articles.where((article) {
//       return article['title']!
//           .toLowerCase()
//           .contains(_searchQuery.toLowerCase());
//     }).toList();
//   }

//   Future<void> _speak(String text) async {
//     if (isSpeaking) {
//       await flutterTts.stop();
//       setState(() {
//         isSpeaking = false;
//       });
//     } else {
//       if (text.isNotEmpty) {
//         await flutterTts.speak(text);
//         setState(() {
//           isSpeaking = true;
//         });
//       }
//     }
//   }

//   void _onItemTapped(int index) {
//     if (index == 3) {
//       // Navigate to ProfileScreen
//       Navigator.push(
//         context,
//         MaterialPageRoute(builder: (context) => ProfileScreen()),
//       );
//     } else {
//       // Update selected index for other tabs
//       setState(() {
//         _selectedIndex = index;
//       });
//     }
//   }


//   void _showArticle(
//       BuildContext context, String articleUrl, String articleTitle, List<String> categories) async {
//     await FirebaseService().saveTappedArticle(
//         articleTitle, articleUrl); // Save article to Firestore
//     Navigator.push(
//       context,
//       MaterialPageRoute(
//         builder: (context) => ArticleScreen(articleUrl: articleUrl),
//       ),
//     );
//   }

//   void _handleSentiment(String articleTitle, String sentiment) {
//     setState(() {
//       sentimentVotes[articleTitle] = sentiment;
//     });
//   }

//   List<Widget> _widgetOptions(BuildContext context) {
//     return <Widget>[
//       RefreshIndicator(
//         onRefresh: () async {
//           // Fetch the latest articles
//           await fetchNews();
//         },
//         child: SingleChildScrollView(
//           child: Column(
//             children: [
//               Padding(
//                 padding: const EdgeInsets.all(8.0),
//                 child: TextField(
//                   onChanged: (query) {
//                     setState(() {
//                       _searchQuery = query;
//                     });
//                   },
//                   decoration: InputDecoration(
//                     hintText: 'Search articles...',
//                     prefixIcon: Icon(Icons.search),
//                     border: OutlineInputBorder(),
//                   ),
//                 ),
//               ),
//               // Add Blue Panel Here
//               AnimatedContainer(
//                 duration: Duration(seconds: 2), // Slower Animation Duration
//                 curve: Curves.easeInOut, // Smooth Slide-in Animation
//                 margin: EdgeInsets.only(left: 0), // Initial state for animation
//                 padding: EdgeInsets.all(16),
//                 width: MediaQuery.of(context).size.width * 0.8, // 80% of screen width
//                 height: 180, // Increased height
//                 decoration: BoxDecoration(
//                   gradient: LinearGradient(
//                     colors: [
//                       Colors.blue.shade900, // Dark Blue
//                       Colors.blue.shade700, // Medium Blue
//                       Colors.grey.shade600, // Grey
//                     ],
//                     begin: Alignment.topLeft,
//                     end: Alignment.bottomRight,
//                   ),
//                   borderRadius: BorderRadius.circular(20), // Curved Borders
//                   boxShadow: [
//                     BoxShadow(
//                       color: Colors.black26,
//                       blurRadius: 5,
//                       offset: Offset(0, 2),
//                     ),
//                   ],
//                 ),
//                 child: Column(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     Text(
//                       "What's New",
//                       style: TextStyle(
//                         fontFamily: 'DM Sans', // DM Sans Font
//                         color: Colors.white,
//                         fontSize: 24,
//                         fontWeight: FontWeight.bold,
//                       ),
//                       textAlign: TextAlign.center,
//                     ),
//                     SizedBox(height: 8),
//                     Text(
//                       "Fetching the latest updates... ⏳",
//                       style: TextStyle(
//                         fontFamily: 'DM Sans',
//                         color: Colors.white70,
//                         fontSize: 16,
//                       ),
//                       textAlign: TextAlign.center,
//                     ),
//                   ],
//                 ),
//               ),
//               SizedBox(height: 20),
//               // Space after the panel
// // Space between panel and next content

//               _isLoading

//                   ? Lottie.asset(
//                 'assets/animations/loading_home.json', // Path to your Lottie JSON file
//                 width: 100,  // Adjust width as needed
//                 height: 100, // Adjust height as needed
//                 fit: BoxFit.fill, // Adjust fit if needed
//               )
//                   : ListView.builder(
//                 shrinkWrap: true,
//                 physics: NeverScrollableScrollPhysics(),
//                 itemCount: getFilteredArticles().length,
//                 itemBuilder: (context, index) {
//                   final article = getFilteredArticles()[index];
//                   return Padding(
//                     padding: const EdgeInsets.all(8.0),
//                     child: Card(
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(15),
//                       ),
//                       elevation: 5,
//                       child: Column(
//                         children: [
//                           ListTile(
//                             contentPadding: EdgeInsets.all(10),
//                             title: Column(
//                               crossAxisAlignment:
//                               CrossAxisAlignment.start,
//                               children: [
//                                 Text(
//                                   article['source']!,
//                                   style: TextStyle(
//                                     color: Colors.blue,
//                                     fontWeight: FontWeight.bold,
//                                     fontSize: 14,
//                                   ),
//                                 ),
//                                 SizedBox(height: 5),
//                                 Text(
//                                   article['title']!,
//                                   style: TextStyle(
//                                       fontWeight: FontWeight.bold),
//                                 ),
//                               ],
//                             ),
//                             subtitle: Text(
//                               article['preview']!,
//                               maxLines: 5,
//                               overflow: TextOverflow.ellipsis,
//                             ),
//                             onTap: () => _showArticle(
//                               context,
//                               article['fullContent']!,
//                               article['title']!,
//                             ),
//                             trailing: IconButton(
//                               icon: Icon(
//                                 isSpeaking ? Icons.stop : Icons.volume_up,
//                               ),
//                               onPressed: () =>
//                                   _speak(article['preview']!),
//                             ),
//                           ),
//                           Row(
//                             mainAxisAlignment: MainAxisAlignment.spaceBetween,

//                             children: [
//                               Row(
//                                 mainAxisAlignment: MainAxisAlignment.start,
//                                 children: [
//                                   IconButton(
//                                     icon: Icon(
//                                       sentimentVotes[article['title']] ==
//                                           'positive'
//                                           ? FontAwesomeIcons.solidThumbsUp
//                                           : FontAwesomeIcons.thumbsUp,
//                                       color: Colors.green,
//                                     ),
//                                     onPressed: () async {
//                                       try {
//                                         if (article['title'] == null ||
//                                             article['title']!.isEmpty) {
//                                           throw Exception(
//                                               "Article title is missing");
//                                         }
//                                         final url = article['url'] ??
//                                             'No URL available';
//                                         _handleSentiment(
//                                             article['title']!, 'positive');
//                                         await firebaseService.saveSentiment(
//                                           'positive',
//                                           article['title']!,
//                                           url,
//                                         );
//                                         print(
//                                             "Sentiment processed successfully!");
//                                       } catch (e) {
//                                         print("Error saving sentiment: $e");
//                                       }
//                                     },
//                                   ),
//                                   IconButton(
//                                     icon: Icon(
//                                       sentimentVotes[article['title']] ==
//                                           'negative'
//                                           ? FontAwesomeIcons.solidThumbsDown
//                                           : FontAwesomeIcons.thumbsDown,
//                                       color: Colors.red,
//                                     ),
//                                     onPressed: () async {
//                                       try {
//                                         if (article['title'] == null ||
//                                             article['title']!.isEmpty) {
//                                           throw Exception(
//                                               "Article title is missing");
//                                         }
//                                         final url = article['url'] ??
//                                             'No URL available';
//                                         _handleSentiment(
//                                             article['title']!, 'negative');
//                                         await firebaseService.saveSentiment(
//                                           'negative',
//                                           article['title']!,
//                                           url,
//                                         );
//                                         print(
//                                             "Sentiment processed successfully!");
//                                       } catch (e) {
//                                         print("Error saving sentiment: $e");
//                                       }
//                                     },
//                                   ),
//                                   IconButton(
//                                     icon: Icon(
//                                       sentimentVotes[article['title']] ==
//                                           'neutral'
//                                           ? FontAwesomeIcons.solidMeh
//                                           : FontAwesomeIcons.meh,
//                                       color: Colors.grey,
//                                     ),
//                                     onPressed: () async {
//                                       try {
//                                         if (article['title'] == null ||
//                                             article['title']!.isEmpty) {
//                                           throw Exception(
//                                               "Article title is missing");
//                                         }
//                                         final url = article['url'] ??
//                                             'No URL available';
//                                         _handleSentiment(
//                                             article['title']!, 'neutral');
//                                         await firebaseService.saveSentiment(
//                                           'neutral',
//                                           article['title']!,
//                                           url,
//                                         );
//                                         print(
//                                             "Sentiment processed successfully!");
//                                       } catch (e) {
//                                         print("Error saving sentiment: $e");
//                                       }
//                                     },
//                                   ),
//                                   IconButton(
//                                     icon: Icon(
//                                       FontAwesomeIcons.download,
//                                       color: Colors.blueAccent,
//                                     ),
//                                     onPressed: () {
//                                       saveArticleForOffline(article['title']!,
//                                           article['fullContent']!)
//                                           .then((_) {
//                                         Navigator.push(
//                                           context,
//                                           MaterialPageRoute(
//                                             builder: (context) =>
//                                                 OfflineArticleScreen(
//                                                     articleId:
//                                                     article['title']!),
//                                           ),
//                                         );
//                                       });
//                                     },
//                                   ),
//                                 ],
//                               ),
//                               Text(article['dominantSentiment'])
//                             ],
//                           ),
//                           _buildCommentBox(
//                               article['title'] ?? "Untitled Article", article['source']),
//                         ],
//                       ),
//                     ),
//                   );
//                 },
//               ),
//             ],
//           ),
//         ),
//       ),
//       RefreshIndicator(
//         onRefresh: () async {
//           // Fetch the latest articles
//           await fetchNews();
//         },
//         child: SingleChildScrollView(
//           child: Column(
//             children: [
//               Padding(
//                 padding: const EdgeInsets.all(8.0),
//                 child: TextField(
//                   onChanged: (query) {
//                     setState(() {
//                       _searchQuery = query;
//                     });
//                   },
//                   decoration: InputDecoration(
//                     hintText: 'Search articles...',
//                     prefixIcon: Icon(Icons.search),
//                     border: OutlineInputBorder(),
//                   ),
//                 ),
//               ),
//               _isLoading
//                   ? CircularProgressIndicator()
//                   : ListView.builder(
//                       shrinkWrap: true,
//                       physics: NeverScrollableScrollPhysics(),
//                       itemCount: getFilteredArticles().length,
//                       itemBuilder: (context, index) {
//                         final article = getFilteredArticles()[index];
//                         return Padding(
//                           padding: const EdgeInsets.all(8.0),
//                           child: Card(
//                             shape: RoundedRectangleBorder(
//                               borderRadius: BorderRadius.circular(15),
//                             ),
//                             elevation: 5,
//                             child: Column(
//                               children: [
//                                 ListTile(
//                                   contentPadding: EdgeInsets.all(10),
//                                   title: Column(
//                                     crossAxisAlignment:
//                                         CrossAxisAlignment.start,
//                                     children: [
//                                       Text(
//                                         article['source']!,
//                                         style: TextStyle(
//                                           color: Colors.blue,
//                                           fontWeight: FontWeight.bold,
//                                           fontSize: 14,
//                                         ),
//                                       ),
//                                       SizedBox(height: 5),
//                                       Text(
//                                         article['title']!,
//                                         style: TextStyle(
//                                             fontWeight: FontWeight.bold),
//                                       ),
//                                     ],
//                                   ),
//                                   subtitle: Text(
//                                     article['preview']!,
//                                     maxLines: 5,
//                                     overflow: TextOverflow.ellipsis,
//                                   ),
//                                   onTap: () => _showArticle(
//                                       context,
//                                       article['fullContent']!,
//                                       article['title']!,
//                                       article['categories']!),
//                                   trailing: IconButton(
//                                     icon: Icon(
//                                       isSpeaking ? Icons.stop : Icons.volume_up,
//                                     ),
//                                     onPressed: () =>
//                                         _speak(article['preview']!),
//                                   ),
//                                 ),
//                                 Row(
//                                   mainAxisAlignment:
//                                       MainAxisAlignment.spaceBetween,
//                                   children: [
//                                     Row(
//                                       mainAxisAlignment:
//                                           MainAxisAlignment.start,
//                                       children: [
//                                         IconButton(
//                                           icon: Icon(
//                                             sentimentVotes[article['title']] ==
//                                                     'positive'
//                                                 ? FontAwesomeIcons.solidThumbsUp
//                                                 : FontAwesomeIcons.thumbsUp,
//                                             color: Colors.green,
//                                           ),
//                                           onPressed: () async {
//                                             try {
//                                               if (article['title'] == null ||
//                                                   article['title']!.isEmpty) {
//                                                 throw Exception(
//                                                     "Article title is missing");
//                                               }
//                                               final url = article['url'] ??
//                                                   'No URL available';
//                                               _handleSentiment(
//                                                   article['title']!,
//                                                   'positive');
//                                               await firebaseService
//                                                   .saveSentiment(
//                                                 'positive',
//                                                 article['title']!,
//                                                 url,
//                                               );
//                                               print(
//                                                   "Sentiment processed successfully!");
//                                             } catch (e) {
//                                               print(
//                                                   "Error saving sentiment: $e");
//                                             }
//                                           },
//                                         ),
//                                         IconButton(
//                                           icon: Icon(
//                                             sentimentVotes[article['title']] ==
//                                                     'negative'
//                                                 ? FontAwesomeIcons
//                                                     .solidThumbsDown
//                                                 : FontAwesomeIcons.thumbsDown,
//                                             color: Colors.red,
//                                           ),
//                                           onPressed: () async {
//                                             try {
//                                               if (article['title'] == null ||
//                                                   article['title']!.isEmpty) {
//                                                 throw Exception(
//                                                     "Article title is missing");
//                                               }
//                                               final url = article['url'] ??
//                                                   'No URL available';
//                                               _handleSentiment(
//                                                   article['title']!,
//                                                   'negative');
//                                               await firebaseService
//                                                   .saveSentiment(
//                                                 'negative',
//                                                 article['title']!,
//                                                 url,
//                                               );
//                                               print(
//                                                   "Sentiment processed successfully!");
//                                             } catch (e) {
//                                               print(
//                                                   "Error saving sentiment: $e");
//                                             }
//                                           },
//                                         ),
//                                         IconButton(
//                                           icon: Icon(
//                                             sentimentVotes[article['title']] ==
//                                                     'neutral'
//                                                 ? FontAwesomeIcons.solidMeh
//                                                 : FontAwesomeIcons.meh,
//                                             color: Colors.grey,
//                                           ),
//                                           onPressed: () async {
//                                             try {
//                                               if (article['title'] == null ||
//                                                   article['title']!.isEmpty) {
//                                                 throw Exception(
//                                                     "Article title is missing");
//                                               }
//                                               final url = article['url'] ??
//                                                   'No URL available';
//                                               _handleSentiment(
//                                                   article['title']!, 'neutral');
//                                               await firebaseService
//                                                   .saveSentiment(
//                                                 'neutral',
//                                                 article['title']!,
//                                                 url,
//                                               );
//                                               print(
//                                                   "Sentiment processed successfully!");
//                                             } catch (e) {
//                                               print(
//                                                   "Error saving sentiment: $e");
//                                             }
//                                           },
//                                         ),
//                                         IconButton(
//                                           icon: Icon(
//                                             FontAwesomeIcons.download,
//                                             color: Colors.blueAccent,
//                                           ),
//                                           onPressed: () {
//                                             saveArticleForOffline(
//                                                     article['title']!,
//                                                     article['fullContent']!)
//                                                 .then((_) {
//                                               Navigator.push(
//                                                 context,
//                                                 MaterialPageRoute(
//                                                   builder: (context) =>
//                                                       OfflineArticleScreen(
//                                                           articleId: article[
//                                                               'title']!),
//                                                 ),
//                                               );
//                                             });
//                                           },
//                                         ),
//                                       ],
//                                     ),
//                                     Text(article['dominantSentiment'])
//                                   ],
//                                 ),
//                                 _buildCommentBox(
//                                     article['title'] ?? "Untitled Article",
//                                     article['source']),
//                               ],
//                             ),
//                           ),
//                         );
//                       },
//                     ),
//             ],
//           ),
//         ),
//       ),
//       Center(child: Text('Non-Wifi News')),
//       Center(child: Text('Settings and Profile')),
//     ];
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text(
//           'Fori Feed',
//           style: TextStyle(
//             color: Colors.white, // Set the text color to white for contrast
//           ),
//         ),
//         // Set the AppBar background to a gradient with different shades of blue
//         flexibleSpace: Container(
//           decoration: BoxDecoration(
//             gradient: LinearGradient(
//               colors: [
//                 Color(0xFF1E3A8A), // Dark Blue
//                 Color(0xFF3B82F6), // Medium Blue
//                 Color(0xFF60A5FA), // Lighter Blue
//               ],
//               begin: Alignment.topLeft,
//               end: Alignment.bottomRight,
//             ),
//           ),
//         ),
//         actions: [
//           // Heart outline icon on the right side of the AppBar
//           IconButton(
//             icon: Icon(Icons.favorite_border), // Heart outline icon
//             onPressed: () {
//               // Navigate to the selection screen when clicked
//               Navigator.push(
//                 context,
//                 MaterialPageRoute(builder: (context) => SelectionScreen()),
//               );
//             },
//           ),
//         ],
//       ),
//       drawer: NavBar(), // Replace Drawer with your NavBar component
//       body: _widgetOptions(context)[_selectedIndex],
//       bottomNavigationBar: BottomNavigationBar(
//         items: [
//           BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
//           BottomNavigationBarItem(
//               icon: Icon(Icons.analytics), label: 'User Analytics'),
//           BottomNavigationBarItem(
//               icon: Icon(Icons.wifi_off), label: 'Non-Wifi News'),
//           BottomNavigationBarItem(
//               icon: Icon(Icons.account_circle_sharp), label: 'Account'),
//         ],
//         currentIndex: _selectedIndex,
//         onTap: _onItemTapped,
//         selectedItemColor: Colors.blue,
//         unselectedItemColor: Colors.blue.shade400,
//       ),
//     );
//   }



//   Future<String> analyzeSentiment(String commentText) async {
//     const String openAiApiUrl = 'https://api.openai.com/v1/chat/completions';
//     const String apiKey =
//         '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';

//     final response = await http.post(
//       Uri.parse(openAiApiUrl),
//       headers: {
//         'Content-Type': 'application/json',
//         'Authorization': 'Bearer $apiKey',
//       },
//       body: json.encode({
//         'model': 'gpt-4o',
//         'messages': [
//           {
//             'role': 'system',
//             'content':
//             'You are an assistant that performs sentiment analysis on text.'
//           },
//           {
//             'role': 'user',
//             'content':
//             'Analyze the sentiment of this comment and return only "positive" or "negative" or "neutral": "$commentText"'
//           }
//         ],
//         'max_tokens': 50,
//       }),
//     );

//     if (response.statusCode == 200) {
//       final responseData = json.decode(response.body);
//       print(responseData);
//       return responseData['choices'][0]['message']['content'].trim();
//     } else {
//       throw Exception('Failed to analyze sentiment: ${response.statusCode}');
//     }
//   }

//   Widget _buildCommentBox(String articleTitle, String channel) {
//     final TextEditingController _commentController = TextEditingController();

//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Padding(
//           padding: const EdgeInsets.all(8.0),
//           child: Text(
//             'Comments',
//             style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
//           ),
//         ),
//         Container(
//           margin: EdgeInsets.symmetric(horizontal: 10),
//           child: TextField(
//             controller: _commentController,
//             maxLines: 2,
//             decoration: InputDecoration(
//               hintText: 'Write your comment here...',
//               border: OutlineInputBorder(
//                 borderRadius: BorderRadius.circular(10.0),
//               ),
//               suffixIcon: IconButton(
//                 icon: Icon(Icons.send),
//                 onPressed: () async {
//                   if (_commentController.text.isNotEmpty) {
//                     final String userId =
//                         FirebaseAuth.instance.currentUser?.uid ?? '';
//                     final String commentText = _commentController.text;

//                     await saveComment(userId, articleTitle, commentText, channel);

//                     _commentController.clear();
//                     ScaffoldMessenger.of(context).showSnackBar(
//                       SnackBar(
//                           content: Text(
//                               'Comment added successfully with sentiment analysis')),
//                     );
//                   }
//                 },
//               ),
//             ),
//           ),
//         ),
//         SizedBox(height: 10),
//         StreamBuilder<QuerySnapshot>(
//           stream: FirebaseFirestore.instance
//               .collection('comments')
//               .where('articleTitle', isEqualTo: articleTitle)
//               .where('channel', whereIn: followedChannels)
//               .orderBy('timestamp', descending: true)
//               .snapshots(),
//           builder: (context, snapshot) {
//             if (snapshot.connectionState == ConnectionState.waiting) {
//               return Center(child: CircularProgressIndicator());
//             }
//             if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
//               return Padding(
//                 padding: const EdgeInsets.all(8.0),
//                 child: Text('No comments yet.'),
//               );
//             }
//             final comments = snapshot.data!.docs;
//             return ListView.builder(
//               shrinkWrap: true,
//               physics: NeverScrollableScrollPhysics(),
//               itemCount: comments.length,
//               itemBuilder: (context, index) {
//                 final comment = comments[index];
//                 return ListTile(
//                   title: Text(comment['commentText'] ?? 'No comment text'),
//                   subtitle: Text(
//                     comment['timestamp'] != null
//                         ? (comment['timestamp'] as Timestamp)
//                         .toDate()
//                         .toString()
//                         : '',
//                     style: TextStyle(fontSize: 12),
//                   ),
//                 );
//               },
//             );
//           },
//         ),
//       ],
//     );
//   }
// }
