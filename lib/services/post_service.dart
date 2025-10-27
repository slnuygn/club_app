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
      // Return a placeholder or rethrow
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

  Future<List<Map<String, dynamic>>> getAllPosts() async {
    try {
      // Get all posts from Firestore
      QuerySnapshot postsSnapshot = await _firestore
          .collection('posts')
          .orderBy('event_date', descending: false)
          .get();

      List<Map<String, dynamic>> allPostsData = [];

      for (var postDoc in postsSnapshot.docs) {
        final postData = postDoc.data() as Map<String, dynamic>;

        // Convert gs:// URL to HTTPS for photo
        if (postData['photo_URL'] != null &&
            postData['photo_URL'].startsWith('gs://')) {
          postData['photo_URL'] = await _convertGsUrlToHttps(
            postData['photo_URL'],
          );
        }

        final Post post = Post.fromFirestore(postData);
        final Club club = await getClub(post.clubId);

        allPostsData.add({'post': post, 'club': club});
      }

      return allPostsData;
    } catch (e) {
      print('Error fetching all posts: $e');
      rethrow;
    }
  }
}
