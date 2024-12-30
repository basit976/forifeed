import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SentimentPage extends StatelessWidget {
  final String articleId; // Unique ID for the article

  SentimentPage({required this.articleId});

  // Firestore instance
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  // Function to save sentiment to Firestore
  Future<void> saveSentiment(String sentiment) async {
    try {
      await firestore.collection('sentiments').add({
        'articleId': articleId,
        'sentiment': sentiment,
        'timestamp': FieldValue.serverTimestamp(), // To track when the sentiment was recorded
      });
      print("Sentiment saved: $sentiment");
    } catch (e) {
      print("Error saving sentiment: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Sentiment Page'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'How do you feel about this article?',
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 20),
            // Thumbs Up Button
            ElevatedButton.icon(
              onPressed: () {
                saveSentiment('thumbs_up');
              },
              icon: Icon(Icons.thumb_up, color: Colors.green),
              label: Text('Thumbs Up'),
            ),
            SizedBox(height: 10),
            // Thumbs Down Button
            ElevatedButton.icon(
              onPressed: () {
                saveSentiment('thumbs_down');
              },
              icon: Icon(Icons.thumb_down, color: Colors.red),
              label: Text('Thumbs Down'),
            ),
            SizedBox(height: 10),
            // Neutral Button
            ElevatedButton.icon(
              onPressed: () {
                saveSentiment('neutral');
              },
              icon: Icon(Icons.thumbs_up_down, color: Colors.grey),
              label: Text('Neutral'),
            ),
          ],
        ),
      ),
    );
  }
}
