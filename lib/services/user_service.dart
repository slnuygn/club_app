import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Creates or updates a user document in Firestore when they sign in
  /// Document ID will be the user's UID
  /// Initializes fields: club_key, club_rank, following_clubs, liked_posts, name, profile_photo_URL
  Future<void> createUserDocument(User user) async {
    try {
      final userDocRef = _firestore.collection('users').doc(user.uid);

      // Check if the document already exists
      final docSnapshot = await userDocRef.get();

      if (!docSnapshot.exists) {
        // Create the document with initialized fields
        // Name and profile photo are automatically set from Google sign-in
        await userDocRef.set({
          'club_key': null,
          'club_rank': null,
          'following_clubs': null,
          'liked_posts': null,
          'name': user.displayName ?? 'Unknown User',
          'profile_photo_URL': user.photoURL ?? '',
        });
        print(
          'User document created for UID: ${user.uid} with name: ${user.displayName}',
        );
      } else {
        // Update existing document if name or profile photo is missing or different from Google
        final data = docSnapshot.data();
        final googleName = user.displayName ?? 'Unknown User';
        final googlePhotoURL = user.photoURL ?? '';
        final updateData = <String, dynamic>{};
        if (data?['name'] == null ||
            data?['name'] == '' ||
            data?['name'] != googleName) {
          updateData['name'] = googleName;
        }
        if (data?['profile_photo_URL'] == null ||
            data?['profile_photo_URL'] == '' ||
            data?['profile_photo_URL'] != googlePhotoURL) {
          updateData['profile_photo_URL'] = googlePhotoURL;
        }
        if (updateData.isNotEmpty) {
          await userDocRef.update(updateData);
          print(
            'User document updated for UID: ${user.uid} with name: $googleName',
          );
        } else {
          print(
            'User document already exists and is up to date for UID: ${user.uid}',
          );
        }
      }
    } catch (e) {
      print('Error creating/updating user document: $e');
      rethrow;
    }
  }
}
