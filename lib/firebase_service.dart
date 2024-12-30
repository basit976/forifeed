import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:html/parser.dart' as html_parser;
import 'package:http/http.dart' as http;

class FirebaseService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Saves a list of followed channels for the current user.
  Future<void> saveFollowedChannels(List<String> channels) async {
    User? user = _auth.currentUser;
    if (user != null) {
      await _firestore.collection('users').doc(user.uid).set(
        {
          'followedChannels': channels,
        },
        SetOptions(merge: true), // Merges with existing data
      );
    } else {
      throw Exception("No user is logged in");
    }
  }

  /// Fetches the followed channels for the current user.
  Future<List<String>> fetchFollowedChannels() async {
    User? user = _auth.currentUser;
    if (user != null) {
      DocumentSnapshot snapshot = await _firestore.collection('users').doc(user.uid).get();
      if (snapshot.exists && snapshot.data() != null) {
        Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;
        return List<String>.from(data['followedChannels'] ?? []);
      }
    }
    return [];
  }

  /// Fetches the names of all available news channels.
  Future<List<String>> fetchAvailableNewsChannels() async {
    // This should be replaced with your actual collection and field for channel names
    QuerySnapshot snapshot = await _firestore.collection('news_channels').get();
    List<String> channelNames = [];
    for (var doc in snapshot.docs) {
      // Assuming 'name' field holds the name of the news channel
      channelNames.add(doc['name']);
    }
    return channelNames;
  }

  /// Logs the user in with email and password.
  Future<User?> signInWithEmail(String email, String password) async {
    UserCredential credential = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    return credential.user;
  }

  /// Logs the user out.
  Future<void> signOut() async {
    await _auth.signOut();
  }

  /// Saves a tapped article's title and URL for the current user.
  Future<void> saveTappedArticle(String articleTitle, String articleUrl) async {
    User? user = _auth.currentUser;
    if (user != null) {
      String articleContent = await _fetchArticleContent(articleUrl);
      // Save the tapped article under the user's 'tappedArticles' sub-collection
      await _firestore.collection('users').doc(user.uid).collection('tappedArticles').add(
        {
          'title': articleTitle,
          'url': articleUrl,
          'content': articleContent,
          'timestamp': FieldValue.serverTimestamp(),
        },
      );
    } else {
      throw Exception("No user is logged in");
    }
  }

  /// Updates the user's 'preferences' list with the provided categories.
/// If a category already exists, it won't be duplicated.
Future<void> updateUserPreferences(List<String> categories) async {
  User? user = _auth.currentUser;
  if (user != null) {
    DocumentReference userDoc = _firestore.collection('users').doc(user.uid);
    try {
      // Fetch the existing preferences
      DocumentSnapshot snapshot = await userDoc.get();
      List<String> existingPreferences = [];

      if (snapshot.exists && snapshot.data() != null) {
        existingPreferences = List<String>.from(snapshot.get('preferences') ?? []);
      }

      // Combine existing preferences with new categories, avoiding duplicates
      List<String> updatedPreferences = [
        ...existingPreferences,
        ...categories.where((category) => !existingPreferences.contains(category)),
      ];

      // Update the preferences field in Firestore
      await userDoc.set({'preferences': updatedPreferences}, SetOptions(merge: true));
   
    } catch (e) {
      throw Exception("Failed to update preferences: $e");
    }
  } else {
    throw Exception("No user is logged in");
  }
}


// Function to save sentiment to Firestore
  Future<void> saveSentiment(String sentiment, String articleTitle, String articleUrl) async {
    User? user = _auth.currentUser;

    if (user != null) {
      try {
        // Reference to the sentiment collection
        final sentimentCollection = _firestore
            .collection('users')
            .doc(user.uid)
            .collection('sentiment');

        // Check if there's already a record for the article
        final querySnapshot = await sentimentCollection
            .where('articleTitle', isEqualTo: articleTitle)
            .get();

        if (querySnapshot.docs.isNotEmpty) {
          // If an entry exists, update it
          final docId = querySnapshot.docs.first.id;
          await sentimentCollection.doc(docId).set({
            'articleTitle': articleTitle,
            'articleUrl': articleUrl,
            'sentiment': sentiment,
            'timestamp': FieldValue.serverTimestamp(),
          });
          print("Sentiment updated for article: $articleTitle");
        } else {
          // If no entry exists, create a new one
          await sentimentCollection.add({
            'articleTitle': articleTitle,
            'articleUrl': articleUrl,
            'sentiment': sentiment,
            'timestamp': FieldValue.serverTimestamp(),
          });
          print("New sentiment saved for article: $articleTitle");
        }
      } catch (e) {
        print("Error saving sentiment: $e");
      }
    } else {
      print("Error: No user is logged in");
    }
  }

  Future<void> saveComment(String userId, String articleTitle, String commentText) async {
    User? user = _auth.currentUser;

    if (user != null) {
      try {
        final userCommentsCollection = _firestore
            .collection('users')
            .doc(user.uid)
            .collection('Comments');

        final querySnapshot = await userCommentsCollection
            .where('articleTitle', isEqualTo: articleTitle)
            .get();

        if (querySnapshot.docs.isNotEmpty) {
          // Update the existing entry
          final docId = querySnapshot.docs.first.id;
          await userCommentsCollection.doc(docId).set({
            'articleTitle': articleTitle,
            'commentText': commentText,
            'timestamp': FieldValue.serverTimestamp(),
          });
          print("Comment updated for article: $articleTitle");
        } else {
          // Create a new entry
          await userCommentsCollection.add({
            'articleTitle': articleTitle,
            'commentText': commentText,
            'timestamp': FieldValue.serverTimestamp(),
          });
          print("New comment saved for article: $articleTitle");
        }
      } catch (e) {
        print("Error saving comment: $e");
      }
    } else {
      print("Error: No user is logged in");
    }
  }


// Dummy sentiment model function
  Future<String> runSentimentModel(String text) async {
    // Replace with actual model call
    return 'positive'; // For example
  }
  Future<List<Map<String, dynamic>>> saveSentimentDynamic() async {
    User? user = _auth.currentUser;
    List<Map<String, dynamic>> sentiment = [];
    if (user != null) {
      QuerySnapshot snapshot = await _firestore.collection('users').doc(user.uid).collection('sentiment').get();
      for (var doc in snapshot.docs) {
        sentiment.add(doc.data() as Map<String, dynamic>);
      }
    }
    return sentiment;
  }

  /// Fetches the tapped articles for the current user.
  Future<List<Map<String, dynamic>>> fetchTappedArticles() async {
    User? user = _auth.currentUser;
    List<Map<String, dynamic>> tappedArticles = [];
    if (user != null) {
      QuerySnapshot snapshot = await _firestore.collection('users').doc(user.uid).collection('tappedArticles').get();
      for (var doc in snapshot.docs) {
        tappedArticles.add(doc.data() as Map<String, dynamic>);
      }
    }
    return tappedArticles;
  }

  Future<String> _fetchArticleContent(String url) async {
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        // Parse the HTML content of the article page
        final document = html_parser.parse(response.body);

        // Extract the article content using selectors (adjust based on website structure)
        final articleElement = document.querySelector('article') ?? document.body;

        if (articleElement != null) {
          // Remove any unwanted tags like <script>, <style>, etc.
          articleElement.querySelectorAll('script, style, noscript').forEach((element) => element.remove());

          // Get the cleaned text content
          String articleContent = articleElement.text;

          // Replace multiple spaces or newlines with a single space
          articleContent = articleContent.replaceAll(RegExp(r'\s+'), ' ').trim();

          return articleContent;
        } else {
          return 'No article content found';
        }
      } else {
        throw Exception("Failed to load article content (Status Code: ${response.statusCode})");
      }
    } catch (e) {
      print('Error fetching article content: $e');
      return 'Error fetching article content';
    }
    }

}
