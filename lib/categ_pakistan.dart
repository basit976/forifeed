import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'Article_Categ.dart';
import 'package:http/http.dart' as http;
import 'package:xml/xml.dart' as xml;
import 'package:url_launcher/url_launcher.dart';
import 'package:html/parser.dart' as html_parser;
import 'package:lottie/lottie.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_tts/flutter_tts.dart';

import 'firebase_service.dart';

class CategPakistan extends StatefulWidget {
  const CategPakistan({Key? key}) : super(key: key);

  @override
  _CategPakistanState createState() => _CategPakistanState();
}

class _CategPakistanState extends State<CategPakistan> {
  List<Map<String, dynamic>> _geoNewsItems = [];
  List<Map<String, dynamic>> _aSportsNewsItems = [];
  List<Map<String, dynamic>> _dawnNewsItems = [];
  List<Map<String, dynamic>> _AlmashriqnewsItems = [];
  List<Map<String, dynamic>> _AajTvNewsItems = [];
  List<Map<String, dynamic>> _AbtakkNewsItems = [];
  List<Map<String, dynamic>> _PakistanTodayNewsItems = [];
  List<Map<String, dynamic>> _ExpressTribuneNewsItems = [];
  List<Map<String, dynamic>> _BolNewsItems = [];
  List<Map<String, dynamic>> _HumNewsItems = [];
  List<Map<String, dynamic>> _GnnNewsItems = [];
  List<Map<String, dynamic>> _bbcNewsItems = [];
  List<Map<String, dynamic>> _nyNewsItems = [];
  List<Map<String, dynamic>> _googleNewsItems = [];

  TextEditingController _commentController = TextEditingController();

  bool _isLoadingGeo = true;
  bool _isLoadingASports = true;
  bool _isLoadingDawnNews = true;
  bool _isLoadingAlmashriqNews = true;
  bool _isLoadingAajtvNews = true;
  bool _isLoadingAbtakkNews = true;
  bool _isLoadingPakistanTodayNews = true;
  bool _isLoadingExpressTribune = true;
  bool _isLoadingBol = true;
  bool _isLoadingHum = true;
  bool _isLoadinggnn = true;
  bool _isLoadingbbc = true;
  bool _isLoadingny = true;
  bool _isLoadinggoogle = true;

  @override
  void initState() {
    super.initState();
    _fetchGeoNews();
    _fetchASportsNews();
    _fetchDawnNews();
    _fetchAlmashriqNews();
    _fetchAajTvNews();
    _fetchAbtakkNews();
    _fetchPakistanTodayNews();
    _fetchExpressTribuneNews();
    _fetchBolNews();
    _fetchHumNews();
    _fetchbbcNews();
    _fetchGoogleNews();
    _fetchnyNews();
    _fetchGnnNews();
  }

  Future<void> _fetchGeoNews() async {
    try {
      List<Map<String, dynamic>> combinedNews = [];

      // First Link
      await _fetchNews('Geo News',
      
        'https://www.geo.tv/rss/1/1',
        (news) {
          combinedNews.addAll(news);
        },
      );

      setState(() {
        _geoNewsItems = combinedNews; // ✅ Correct list updated
        _isLoadingGeo = false;
      });
    } catch (e) {
      print('Error fetching Express Geo news: $e');
      setState(() {
        _isLoadingGeo = false;
      });
    }
  }

  Future<void> _fetchASportsNews() async {
    try {
      List<Map<String, dynamic>> combinedNews = [];

      // First Link
      await _fetchNews('Ary News',
      
        'https://arynews.tv/category/pakistan/feed/',
        (news) {
          combinedNews.addAll(news);
        },
      );

      // Second Link
      await _fetchNews('Ary News',
      
        'https://arynews.tv/category/pakistan/feed/?paged=2',
        (news) {
          combinedNews.addAll(news);
        },
      );

      setState(() {
        _aSportsNewsItems = combinedNews; // ✅ Correct list updated
        _isLoadingASports = false;
      });
    } catch (e) {
      print('Error fetching ARY news: $e');
      setState(() {
        _isLoadingASports = false;
      });
    }
  }

  Future<void> _fetchDawnNews() async {
    await _fetchNews('Dawn',
      
      'https://www.dawn.com/feeds/pakistan/',
      (news) => setState(() {
        _dawnNewsItems = news;
        _isLoadingDawnNews = false;
      }),
    );
  }

  Future<void> _fetchAlmashriqNews() async {
    await _fetchNews('Mashriq TV',
      
      'https://mashriqtv.pk/category/pakistan-news/feed/',
      (news) => setState(() {
        _AlmashriqnewsItems = news;
        _isLoadingAlmashriqNews = false;
      }),
    );
  }

  Future<void> _fetchGnnNews() async {
    await _fetchNews('GNN',
      
      'https://gnnhd.tv/rss/pakistan',
      (news) => setState(() {
        _GnnNewsItems = news;
        _isLoadinggnn = false;
      }),
    );
  }

  Future<void> _fetchbbcNews() async {
    await _fetchNews('GNN',
      
      'https://gnnhd.tv/rss/pakistan',
      (news) => setState(() {
        _bbcNewsItems = news;
        _isLoadingbbc = false;
      }),
    );
  }

  Future<void> _fetchnyNews() async {
    await _fetchNews('The New York Times',
      
      'https://www.nytimes.com/svc/collections/v1/publish/https://www.nytimes.com/spotlight/lifestyle/rss.xml',
      (news) => setState(() {
        _nyNewsItems = news;
        _isLoadingny = false;
      }),
    );
  }

  Future<void> _fetchAajTvNews() async {
    await _fetchNews('Aaj tv',
      
      'https://www.aaj.tv/feeds/latest-news/',
      (news) => setState(() {
        _AajTvNewsItems = news;
        _isLoadingAajtvNews = false;
      }),
    );
  }

  Future<void> _fetchAbtakkNews() async {
    await _fetchNews('Ab Takk News',
      
      'https://abbtakk.tv/category/breaking/feed/',
      (news) => setState(() {
        _AbtakkNewsItems = news;
        _isLoadingAbtakkNews = false;
      }),
    );
  }

  Future<void> _fetchPakistanTodayNews() async {
    await _fetchNews('Pakistan Today',
      
      'https://www.pakistantoday.com.pk/category/city/feed/',
      (news) => setState(() {
        _PakistanTodayNewsItems = news;
        _isLoadingPakistanTodayNews = false;
      }),
    );
  }

  Future<void> _fetchGoogleNews() async {
    await _fetchNews('Google News',
      
      'https://news.google.com/rss/topics/CAAqKggKIiRDQkFTRlFvSUwyMHZNREpxYW5RU0JXVnVMVWRDR2dKUVN5Z0FQAQ?hl=en-PK&gl=PK&ceid=PK%3Aen&oc=11',
      (news) => setState(() {
        _googleNewsItems = news;
        _isLoadinggoogle = false;
      }),
    );
  }

  Future<void> _fetchExpressTribuneNews() async {
    try {
      List<Map<String, dynamic>> combinedNews = [];

      // First Link
      await _fetchNews('Express Tribune',
        
        'https://tribune.com.pk/feed/pakistan',
        (news) {
          combinedNews.addAll(news);
        },
      );

      // Second Link
      await _fetchNews('Express Tribune',
        
        'https://tribune.com.pk/feed/sindh',
        (news) {
          combinedNews.addAll(news);
        },
      );
      await _fetchNews('Express Tribune',
        
        'https://tribune.com.pk/feed/punjab',
        (news) {
          combinedNews.addAll(news);
        },
      );

      setState(() {
        _ExpressTribuneNewsItems = combinedNews; // ✅ Correct list updated
        _isLoadingExpressTribune = false;
      });
    } catch (e) {
      print('Error fetching Express Tribune news: $e');
      setState(() {
        _isLoadingExpressTribune = false;
      });
    }
  }

  Future<void> _fetchBolNews() async {
    try {
      List<Map<String, dynamic>> combinedNews = [];

      // First Link
      await _fetchNews("Bol News",
        
        'https://www.bolnews.com/politics/feed/',
        (news) {
          combinedNews.addAll(news);
        },
      );

      // Second Link
      await _fetchNews("Bol News",
        
        'https://www.bolnews.com/politics/feed/?paged=2',
        (news) {
          combinedNews.addAll(news);
        },
      );
      await _fetchNews("Bol News",
        
        'https://www.bolnews.com/politics/feed/?paged=3',
        (news) {
          combinedNews.addAll(news);
        },
      );
      await _fetchNews("Bol News",
        
        'https://www.bolnews.com/politics/feed/?paged=4',
        (news) {
          combinedNews.addAll(news);
        },
      );

      setState(() {
        _BolNewsItems = combinedNews; // ✅ Correct list updated
        _isLoadingBol = false;
      });
    } catch (e) {
      print('Error fetching Bol news: $e');
      setState(() {
        _isLoadingBol = false;
      });
    }
  }

  Future<void> _fetchHumNews() async {
    try {
      List<Map<String, dynamic>> combinedNews = [];

      // First Link
      await _fetchNews("Hum News",
        
        'https://humnews.pk/pakistan/feed/',
        (news) {
          combinedNews.addAll(news);
        },
      );

      // Second Link
      await _fetchNews("Hum News",
        
        'https://humnews.pk/pakistan/feed/?paged=2',
        (news) {
          combinedNews.addAll(news);
        },
      );
      await _fetchNews("Hum News",
        
        'https://humnews.pk/pakistan/feed/?paged=3',
        (news) {
          combinedNews.addAll(news);
        },
      );
      await _fetchNews("Hum News",
        
        'https://humnews.pk/pakistan/feed/?paged=4',
        (news) {
          combinedNews.addAll(news);
        },
      );
      await _fetchNews("Hum News",
        
        'https://humnews.pk/pakistan/feed/?paged=5',
        (news) {
          combinedNews.addAll(news);
        },
      );

      setState(() {
        _HumNewsItems = combinedNews; // ✅ Correct list updated
        _isLoadingHum = false;
      });
    } catch (e) {
      print('Error fetching Hum news: $e');
      setState(() {
        _isLoadingHum = false;
      });
    }
  }

  String stripHtmlTags(String htmlString) {
    final document = html_parser.parse(htmlString);
    final String parsedString = document.body?.text ?? '';
    return parsedString;
  }

  Future<void> _fetchNews(String channel, 
      String url, Function(List<Map<String, dynamic>>) onComplete) async {
    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final document = xml.XmlDocument.parse(response.body);
        final items = document.findAllElements('item');

        final allCommentsQuery = await FirebaseFirestore.instance
            .collection('comments')
            .where('channel',
                isEqualTo: channel) // Ensure "channel" exists in comments
            .get();

        // Step 2: Group comments by articleTitle and calculate average sentiment
        Map<String, Map<String, dynamic>> groupedComments = {};
        for (var doc in allCommentsQuery.docs) {
          final data = doc.data();
          final articleTitle = data['articleTitle'] ?? '';
          final sentiment =
              data['sentiment'] ?? 'neutral'; // Default to 'neutral' if missing

          if (articleTitle.isNotEmpty) {
            groupedComments.putIfAbsent(
                articleTitle,
                () => {
                      'comments': [],
                      'sentimentCount': {
                        'positive': 0,
                        'negative': 0,
                        'neutral': 0
                      }
                    });

            // Add the comment
            groupedComments[articleTitle]?['comments'].add({
              'commentText': data['commentText'] ?? '',
              'sentiment': sentiment,
              'timestamp': data['timestamp'] != null
                  ? (data['timestamp'] as Timestamp).toDate().toString()
                  : '',
            });

            // Update sentiment count
            groupedComments[articleTitle]?['sentimentCount'][sentiment] =
                (groupedComments[articleTitle]?['sentimentCount'][sentiment] ??
                        0) +
                    1;
          }
        }

        // Step 3: Attach the most common sentiment to each article
        groupedComments.forEach((articleTitle, commentData) {
          final sentimentCount = commentData['sentimentCount'];
          String dominantSentiment = 'neutral';
          int maxCount = 0;

          sentimentCount.forEach((sentiment, count) {
            if (count > maxCount) {
              maxCount = count;
              dominantSentiment = sentiment;
            }
          });

          // Attach dominant sentiment
          commentData['dominantSentiment'] = dominantSentiment;
        });


        List<Map<String, dynamic>> news = items.map((item) {
          final title = item.findElements('title').isNotEmpty
              ? item.findElements('title').first.text
              : 'No title';
          final link = item.findElements('link').isNotEmpty
              ? item.findElements('link').first.text
              : '';
          final description = item.findElements('description').isNotEmpty
              ? item.findElements('description').first.text
              : 'No description';

          // Check for media:content or enclosure tags
          String imageUrl = '';
          final mediaContent = item
              .findElements('media:content')
              .firstOrNull
              ?.getAttribute('url');
          final enclosure =
              item.findElements('enclosure').firstOrNull?.getAttribute('url');
    final categoryElements = item.findAllElements('category');
              final categories = categoryElements.map((e) => e.text).toList();

          if (mediaContent != null && mediaContent.isNotEmpty) {
            imageUrl = mediaContent;
          } else if (enclosure != null && enclosure.isNotEmpty) {
            imageUrl = enclosure;
          } else {
            imageUrl = parseHtmlString(description);
          }

          return {
            'title': title,
            'link': link,
            'description':
                stripHtmlTags(description).split('\n').take(2).join(' '),
            'imageUrl': imageUrl,
            'source': channel,
            'categories': categories,
            'comments': groupedComments[title] ?? [],
            'dominantSentiment': groupedComments[title]?['dominantSentiment']
          };
        }).toList();

        onComplete(news);
      } else {
        throw Exception('Failed to load news');
      }
    } catch (e) {
      print('Error fetching news: $e');
    }
  }

  String parseHtmlString(String htmlString) {
    final document = html_parser.parse(htmlString);
    final imageElement = document.querySelector('img');
    String? imageUrl;

    if (imageElement != null) {
      imageUrl = imageElement.attributes['src'];
    } else {
      final ogImageMeta = document.querySelector('meta[property="og:image"]');
      if (ogImageMeta != null) {
        imageUrl = ogImageMeta.attributes['content'];
      }
    }

    return imageUrl ?? '';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Pakistan '),
        backgroundColor: Colors.blue,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildCollapsibleSection('Geo News', _geoNewsItems, _isLoadingGeo),
            SizedBox(height: 20),
            _buildCollapsibleSection(
                'ARY News', _aSportsNewsItems, _isLoadingASports),
            SizedBox(height: 20),
            _buildCollapsibleSection(
                'Dawn', _dawnNewsItems, _isLoadingDawnNews),
            SizedBox(height: 20),
            _buildCollapsibleSection(
                'Aaj Tv', _AajTvNewsItems, _isLoadingAajtvNews),
            SizedBox(height: 20),
            _buildCollapsibleSection('Express Tribune ',
                _ExpressTribuneNewsItems, _isLoadingExpressTribune),
            SizedBox(height: 20),
            _buildCollapsibleSection(
                'Abb takk', _AbtakkNewsItems, _isLoadingAbtakkNews),
            SizedBox(height: 20),
            _buildCollapsibleSection('Pakistan Today', _PakistanTodayNewsItems,
                _isLoadingPakistanTodayNews),
            SizedBox(height: 20),
            _buildCollapsibleSection('Al Mashriq News', _AlmashriqnewsItems,
                _isLoadingAlmashriqNews),
            SizedBox(height: 20),
            _buildCollapsibleSection('Express Tribune ',
                _ExpressTribuneNewsItems, _isLoadingExpressTribune),
            SizedBox(height: 20),
            _buildCollapsibleSection('Bol News ', _BolNewsItems, _isLoadingBol),
            SizedBox(height: 20),
            _buildCollapsibleSection('Hum News ', _HumNewsItems, _isLoadingHum),
            SizedBox(height: 20),
            _buildCollapsibleSection('GNN ', _GnnNewsItems, _isLoadinggnn),
          ],
        ),
      ),
    );
  }

  Future<String> analyzeSentiment(String commentText) async {
    const String openAiApiUrl = 'https://api.openai.com/v1/chat/completions';
    const String apiKey =
        'your-key';

    final response = await http.post(
      Uri.parse(openAiApiUrl),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $apiKey',
      },
      body: json.encode({
        'model': 'gpt-4o',
        'messages': [
          {
            'role': 'system',
            'content':
                'You are an assistant that performs sentiment analysis on text.'
          },
          {
            'role': 'user',
            'content':
                'Analyze the sentiment of this comment and return only "positive" or "negative" or "neutral": "$commentText"'
          }
        ],
        'max_tokens': 50,
      }),
    );

    if (response.statusCode == 200) {
      final responseData = json.decode(response.body);
      print(responseData);
      return responseData['choices'][0]['message']['content'].trim();
    } else {
      throw Exception('Failed to analyze sentiment: ${response.statusCode}');
    }
  }

  Future<void> saveComment(String userId, String articleTitle,
      String commentText, String channel) async {
    // final sentimentService = SentimentService();
    // await sentimentService.loadModel(); // Ensure the model is loaded before use

    try {
      // Analyze sentiment

      // String sentiment = await sentimentService.analyzeSentiment(commentText);
      String sentiment = await analyzeSentiment(commentText);

      // Save to Firestore
      final commentDoc = FirebaseFirestore.instance.collection('comments').add({
        'userId': userId,
        'articleTitle': articleTitle,
        'commentText': commentText,
        'sentiment': sentiment,
        'timestamp': FieldValue.serverTimestamp(),
        'channel': channel
      });

      print("Comment saved with sentiment: $sentiment");
    } catch (e) {
      print("Error saving comment: $e");
    }
  }

  void updateDominantSentiment(List<Map<String, dynamic>> newsItems,
      String articleTitle, String dominantSentiment) {
    final articleIndex =
        newsItems.indexWhere((article) => article['title'] == articleTitle);
    if (articleIndex != -1) {
      newsItems[articleIndex]['dominantSentiment'] = dominantSentiment;
    }
  }

  Widget _buildCollapsibleSection(
      String title, List<Map<String, dynamic>> newsItems, bool isLoading) {
    // A list to store the comments and reactions for each news item
    List<String> comments = List.generate(newsItems.length, (index) => '');
    List<int> reactions = List.generate(
        newsItems.length, (index) => 0); // 0 = Neutral, 1 = Like, -1 = Dislike

    // Initialize Flutter TTS
    FlutterTts flutterTts = FlutterTts();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Card(
        elevation: 2,
        child: ExpansionTile(
          title: Text(
            title,
            style: TextStyle(
                fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black),
          ),
          children: [
            isLoading
                ? Center(
                    child: Lottie.asset('assets/animations/loading.json',
                        width: 100, height: 100),
                  )
                : ListView.builder(
                    shrinkWrap: true,
                    physics:
                        const NeverScrollableScrollPhysics(), // Prevent internal scrolling
                    itemCount: newsItems.length,
                    itemBuilder: (context, index) {
                      final news = newsItems[index];

                      return Column(
                        children: [
                          _buildNewsCard(news),

                          // Reaction Buttons: Like, Dislike, Neutral
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  IconButton(
                                    icon: Icon(
                                      Icons.thumb_up,
                                      color: reactions[index] == 1
                                          ? Colors.blue
                                          : Colors.grey,
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        reactions[index] = 1; // Like
                                      });
                                    },
                                  ),
                                  IconButton(
                                    icon: Icon(
                                      Icons.thumb_down,
                                      color: reactions[index] == -1
                                          ? Colors.red
                                          : Colors.grey,
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        reactions[index] = -1; // Dislike
                                      });
                                    },
                                  ),
                                  IconButton(
                                    icon: Icon(
                                      Icons.thumb_up_off_alt,
                                      color: reactions[index] == 0
                                          ? Colors.grey
                                          : Colors.grey,
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        reactions[index] = 0; // Neutral
                                      });
                                    },
                                  ),
                                  IconButton(
                                    icon:
                                        Icon(Icons.volume_up, color: Colors.orange),
                                    onPressed: () async {
                                      // Ensure the article text exists, and read it aloud
                                      String articleText = news['articleText'] ??
                                          'Article content is unavailable.';
                                      await flutterTts.speak(articleText);
                                    },
                                  ),
                                ],
                              ),
                              Text(news['dominantSentiment'])
                            ],
                          ),

                          // Comment Box Section
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: TextField(
                              controller: _commentController,
                              onChanged: (text) {
                                // Update the comment for the respective news item
                                comments[index] = text;
                              },
                              decoration: InputDecoration(
                                labelText: 'Add a comment...',
                                border: OutlineInputBorder(),
                              ),
                            ),
                          ),
                          ElevatedButton(
                            onPressed: () async {
                              // When the user clicks submit, display the comment below
                              if (_commentController.text.length > 0) {
                                await saveComment(
                                    FirebaseAuth.instance.currentUser!.uid,
                                    news['title'],
                                    _commentController.text,
                                    news['source']);
                                _commentController.clear();
                              }

                            },
                            child: Text('Submit'),
                          ),
                          SizedBox(height: 10),
                          StreamBuilder<QuerySnapshot>(
                            stream: FirebaseFirestore.instance
                                .collection('comments')
                                .where('articleTitle', isEqualTo: news['title'])
                                .where('channel', isEqualTo: news['source'])
                                .orderBy('timestamp', descending: true)
                                .snapshots(),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return Center(
                                    child: CircularProgressIndicator());
                              }
                              if (!snapshot.hasData ||
                                  snapshot.data!.docs.isEmpty) {
                                Future.microtask(() {
                                  updateDominantSentiment(
                                      newsItems, news['title'], 'neutral');
                                });
                                return Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text('No comments yet.'),
                                );
                              }
                              final comments = snapshot.data!.docs;
                              // Count sentiment values
                              int positiveCount = 0;
                              int negativeCount = 0;
                              int neutralCount = 0;

                              for (var comment in comments) {
                                final sentiment =
                                    comment['sentiment'] ?? 'neutral';
                                if (sentiment == 'positive') {
                                  positiveCount++;
                                } else if (sentiment == 'negative') {
                                  negativeCount++;
                                } else {
                                  neutralCount++;
                                }
                              }

                              // Determine dominant sentiment
                              print("positive: $positiveCount");
                              print("negative: $negativeCount");
                              print("neutral: $neutralCount");
                              String dominantSentiment = 'neutral';
                              if (positiveCount >= negativeCount &&
                                  positiveCount >= neutralCount) {
                                dominantSentiment = 'positive';
                              } else if (negativeCount >= positiveCount &&
                                  negativeCount >= neutralCount) {
                                dominantSentiment = 'negative';
                              } else {
                                dominantSentiment = 'neutral';
                              }

                              // Update the `dominantSentiment` for the article and reflect it in real-time
                              Future.microtask(() {
                                updateDominantSentiment(newsItems,
                                    news['title'], dominantSentiment);
                              });
                              return ListView.builder(
                                shrinkWrap: true,
                                physics: NeverScrollableScrollPhysics(),
                                itemCount: comments.length,
                                itemBuilder: (context, index) {
                                  final comment = comments[index];
                                  return ListTile(
                                    title: Text(comment['commentText'] ??
                                        'No comment text'),
                                    subtitle: Text(
                                      comment['timestamp'] != null
                                          ? (comment['timestamp'] as Timestamp)
                                              .toDate()
                                              .toString()
                                          : '',
                                      style: TextStyle(fontSize: 12),
                                    ),
                                  );
                                },
                              );
                            },
                          ),
                          SizedBox(height: 10),
                        ],
                      );
                    },
                  ),
          ],
        ),
      ),
    );
  }

  Widget _buildNewsCard(Map<String, dynamic> news) {
    return Card(
      child: ListTile(
        leading: news['imageUrl']!.isNotEmpty
            ? Image.network(news['imageUrl']!)
            : null,
        title: Text(news['title']!),
        subtitle: Text(news['description']!,
            maxLines: 2, overflow: TextOverflow.ellipsis),
        onTap: () async => await _launchURL(news['categories'],news['link']!, news['title']!),
      ),
    );
  }

  Future<void> _launchURL(List<String> categories, String url, String title) async {
    await FirebaseService().updateUserPreferences(categories);
  
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) =>
              ArticleCategScreen(articleUrl: url, title: title)),
    );
  }
}
