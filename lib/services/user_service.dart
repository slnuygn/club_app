import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Creates or updates a user document in Firestore when they sign in
  /// Document ID will be the user's UID
  /// Initializes fields: club_key, club_rank, following_clubs, liked_posts
  Future<void> createUserDocument(User user) async {
    try {
      final userDocRef = _firestore.collection('users').doc(user.uid);

      // Check if the document already exists
      final docSnapshot = await userDocRef.get();

      if (!docSnapshot.exists) {
        // Create the document with initialized fields
        await userDocRef.set({
          'club_key': null,
          'club_rank': null,
          'following_clubs': null,
          'liked_posts': null,
        });
        print('User document created for UID: ${user.uid}');
      } else {
        print('User document already exists for UID: ${user.uid}');
      }
    } catch (e) {
      print('Error creating user document: $e');
      rethrow;
    }
  }
}
