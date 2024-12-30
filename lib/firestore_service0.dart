import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Adds or updates a review sentiment for a specific article.
  Future<void> addOrUpdateReview(String title, String sentiment) async {
    try {
      await _firestore.collection('reviews').doc(title).set({
        'review': sentiment,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      throw Exception('Error adding/updating review: $e');
    }
  }

  /// Fetches the review sentiment for a specific article.
  Future<String?> getReview(String title) async {
    try {
      DocumentSnapshot doc =
      await _firestore.collection('reviews').doc(title).get();

      if (doc.exists && doc.data() != null) {
        return doc['review'];
      }
      return null;
    } catch (e) {
      throw Exception('Error fetching review: $e');
    }
  }

  /// Fetches all reviews for all articles (if needed).
  Future<Map<String, dynamic>> getAllReviews() async {
    try {
      QuerySnapshot snapshot = await _firestore.collection('reviews').get();

      return snapshot.docs.asMap().map((index, doc) {
        return MapEntry(doc.id, doc.data());
      });
    } catch (e) {
      throw Exception('Error fetching all reviews: $e');
    }
  }
}
