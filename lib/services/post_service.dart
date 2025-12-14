import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../models/post_data.dart';

class PostService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Helper method to convert gs:// URLs to HTTPS download URLs
  Future<String> _convertGsUrlToHttps(String gsUrl) async {
    if (!gsUrl.startsWith('gs://')) {
      // If it's already an HTTP/HTTPS URL, return as is
      return gsUrl;
    }

    try {
      // Remove 'gs://' prefix
      final path = gsUrl.replaceFirst('gs://', '');
      // Split bucket and file path
      final parts = path.split('/');
      final filePath = parts.sublist(1).join('/');

      // Get download URL from Firebase Storage
      final ref = FirebaseStorage.instance.ref(filePath);
      return await ref.getDownloadURL();
    } catch (e) {
      print('Error converting gs:// URL: $e');
      // Return empty string to indicate failure, UI will handle with placeholder
      return '';
    }
  }

  Future<Post> getPost(String postId) async {
    DocumentSnapshot doc = await _firestore
        .collection('posts')
        .doc(postId)
        .get();

    final data = doc.data() as Map<String, dynamic>;

    // Convert gs:// URL to HTTPS
    if (data['photo_URL'] != null && data['photo_URL'].startsWith('gs://')) {
      data['photo_URL'] = await _convertGsUrlToHttps(data['photo_URL']);
    }

    return Post.fromFirestore(data);
  }

  Future<Club> getClub(String clubId) async {
    DocumentSnapshot doc = await _firestore
        .collection('clubs')
        .doc(clubId)
        .get();

    final data = doc.data() as Map<String, dynamic>;

    // Convert gs:// URL to HTTPS
    if (data['club_photo_URL'] != null &&
        data['club_photo_URL'].startsWith('gs://')) {
      data['club_photo_URL'] = await _convertGsUrlToHttps(
        data['club_photo_URL'],
      );
    }

    return Club.fromFirestore(data);
  }

  Future<Map<String, dynamic>> getPostAndClub(String postId) async {
    Post post = await getPost(postId);
    Club club = await getClub(post.clubId);
    return {'post': post, 'club': club};
  }

  Future<List<Map<String, dynamic>>> getAllPosts({
    List<String>? excludeClubIds,
    String? state,
  }) async {
    try {
      // Get all posts from Firestore
      Query postsQuery = _firestore.collection('posts');
      if (state != null) {
        postsQuery = postsQuery.where('state', isEqualTo: state);
      }
      postsQuery = postsQuery.orderBy('event_date', descending: false);

      QuerySnapshot postsSnapshot = await postsQuery.get();

      List<Map<String, dynamic>> allPostsData = [];

      for (var postDoc in postsSnapshot.docs) {
        final postData = postDoc.data() as Map<String, dynamic>;

        // Optionally exclude posts from specific clubs (e.g., the user's own club)
        final postClubId = postData['club_id'] as String?;
        if (excludeClubIds != null &&
            postClubId != null &&
            excludeClubIds.contains(postClubId)) {
          continue;
        }

        // Convert gs:// URL to HTTPS for photo
        if (postData['photo_URL'] != null &&
            postData['photo_URL'].startsWith('gs://')) {
          postData['photo_URL'] = await _convertGsUrlToHttps(
            postData['photo_URL'],
          );
        }

        final Post post = Post.fromFirestore(postData);
        final Club club = await getClub(post.clubId);

        allPostsData.add({
          'post': post,
          'club': club,
          'postId': postDoc.id, // Include the document ID
        });
      }

      return allPostsData;
    } catch (e) {
      print('Error fetching all posts: $e');
      rethrow;
    }
  }

  // Get user's liked posts
  Future<List<String>> getUserLikedPosts(String userId) async {
    try {
      DocumentSnapshot userDoc = await _firestore
          .collection('users')
          .doc(userId)
          .get();

      if (!userDoc.exists) {
        return [];
      }

      final data = userDoc.data() as Map<String, dynamic>?;
      if (data == null || !data.containsKey('liked_posts')) {
        return [];
      }

      final likedPosts = data['liked_posts'] as List<dynamic>?;
      final posts = likedPosts?.cast<String>() ?? [];
      // Filter out empty strings
      return posts.where((postId) => postId.isNotEmpty).toList();
    } catch (e) {
      print('Error fetching liked posts: $e');
      return [];
    }
  }

  // Toggle like status for a post
  Future<void> toggleLikePost(
    String userId,
    String postId,
    bool isLiked,
  ) async {
    try {
      final userRef = _firestore.collection('users').doc(userId);

      // First, ensure the document and field exist
      final userDoc = await userRef.get();

      if (!userDoc.exists) {
        throw Exception('User document does not exist');
      }

      final userData = userDoc.data();

      // If liked_posts field doesn't exist, initialize it
      if (userData == null || !userData.containsKey('liked_posts')) {
        // Only add the post if we're liking it (isLiked = false means we're adding)
        if (!isLiked) {
          await userRef.set({
            'liked_posts': [postId],
          }, SetOptions(merge: true));
        }
        // If isLiked = true and field doesn't exist, nothing to remove
        return;
      }

      if (isLiked) {
        // Remove from liked posts
        await userRef.update({
          'liked_posts': FieldValue.arrayRemove([postId]),
        });
      } else {
        // Add to liked posts
        await userRef.update({
          'liked_posts': FieldValue.arrayUnion([postId]),
        });
      }
    } catch (e) {
      print('Error toggling like: $e');
      rethrow;
    }
  }

  // Get user's followed clubs
  Future<List<String>> getUserFollowedClubs(String userId) async {
    try {
      DocumentSnapshot userDoc = await _firestore
          .collection('users')
          .doc(userId)
          .get();

      if (!userDoc.exists) {
        return [];
      }

      final data = userDoc.data() as Map<String, dynamic>?;
      if (data == null || !data.containsKey('following_clubs')) {
        return [];
      }

      final followingClubs = data['following_clubs'] as List<dynamic>?;
      final clubs = followingClubs?.cast<String>() ?? [];
      // Filter out empty strings
      return clubs.where((clubId) => clubId.isNotEmpty).toList();
    } catch (e) {
      print('Error fetching followed clubs: $e');
      return [];
    }
  }

  // Toggle follow status for a club
  Future<void> toggleFollowClub(
    String userId,
    String clubId,
    bool isFollowing,
  ) async {
    try {
      final userRef = _firestore.collection('users').doc(userId);

      // First, ensure the document exists
      final userDoc = await userRef.get();

      if (!userDoc.exists) {
        throw Exception('User document does not exist');
      }

      final userData = userDoc.data();

      // If following_clubs field doesn't exist, initialize it
      if (userData == null || !userData.containsKey('following_clubs')) {
        // Only add the club if we're following it (isFollowing = false means we're adding)
        if (!isFollowing) {
          await userRef.set({
            'following_clubs': [clubId],
          }, SetOptions(merge: true));
        }
        // If isFollowing = true and field doesn't exist, nothing to remove
        return;
      }

      if (isFollowing) {
        // Unfollow - remove from following clubs
        await userRef.update({
          'following_clubs': FieldValue.arrayRemove([clubId]),
        });
      } else {
        // Follow - add to following clubs
        await userRef.update({
          'following_clubs': FieldValue.arrayUnion([clubId]),
        });
      }
    } catch (e) {
      print('Error toggling follow: $e');
      rethrow;
    }
  }
}
