import 'package:club_app/models/post_data.dart';
import 'package:club_app/services/post_service.dart';
import 'package:club_app/services/user_service.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

// Fake implementations to avoid Firebase initialization
class FakeFirebaseStorage extends Fake implements FirebaseStorage {
  @override
  Reference ref([String? path]) {
    return FakeReference();
  }
}

class FakeReference extends Fake implements Reference {
  @override
  Future<String> getDownloadURL() async {
    return 'https://fake-storage.com/file.jpg';
  }
}

void main() {
  group('API Service Tests', () {
    late FakeFirebaseFirestore fakeFirestore;
    late FakeFirebaseStorage fakeStorage;
    late PostService postService;
    late UserService userService;

    setUp(() {
      fakeFirestore = FakeFirebaseFirestore();
      fakeStorage = FakeFirebaseStorage();
      postService = PostService(firestore: fakeFirestore, storage: fakeStorage);
      userService = UserService(firestore: fakeFirestore);
    });

    group('PostService', () {
      test('getPost returns correct Post object', () async {
        // Arrange
        const postId = 'post_123';
        await fakeFirestore.collection('posts').doc(postId).set({
          'club_id': 'club_abc',
          'event_date': Timestamp.fromDate(DateTime(2023, 1, 1)),
          'event_location_URL': 'https://maps.google.com',
          'event_placeholder': 'Placeholder',
          'photo_URL':
              'https://example.com/photo.jpg', // HTTP URL to skip storage logic
          'post_caption': 'Test Caption',
        });

        // Act
        final post = await postService.getPost(postId);

        // Assert
        expect(post.clubId, 'club_abc');
        expect(post.postCaption, 'Test Caption');
        expect(post.photoURL, 'https://example.com/photo.jpg');
        expect(post.eventDate, DateTime(2023, 1, 1));
      });

      test('getClub returns correct Club object', () async {
        // Arrange
        const clubId = 'club_abc';
        await fakeFirestore.collection('clubs').doc(clubId).set({
          'club_name': 'Test Club',
          'club_photo_URL': 'https://example.com/club.jpg',
        });

        // Act
        final club = await postService.getClub(clubId);

        // Assert
        expect(club.name, 'Test Club');
        expect(club.photoUrl, 'https://example.com/club.jpg');
      });

      test('getAllPosts returns list of posts and clubs', () async {
        // Arrange
        await fakeFirestore.collection('clubs').doc('club_1').set({
          'club_name': 'Club 1',
          'club_photo_URL': 'http://url',
        });

        await fakeFirestore.collection('posts').add({
          'club_id': 'club_1',
          'event_date': Timestamp.now(),
          'event_location_URL': 'loc',
          'event_placeholder': 'place',
          'photo_URL': 'http://photo',
          'post_caption': 'Caption 1',
          'state': 'approved',
        });

        // Act
        final results = await postService.getAllPosts(state: 'approved');

        // Assert
        expect(results.length, 1);
        expect(results.first['post'], isA<Post>());
        expect(results.first['club'], isA<Club>());
        expect((results.first['post'] as Post).postCaption, 'Caption 1');
        expect((results.first['club'] as Club).name, 'Club 1');
      });

      test('toggleLikePost adds and removes likes', () async {
        // Arrange
        const userId = 'user_1';
        const postId = 'post_1';
        await fakeFirestore.collection('users').doc(userId).set({
          'liked_posts': [],
        });

        // Act: Like
        await postService.toggleLikePost(userId, postId, false);
        var userDoc = await fakeFirestore.collection('users').doc(userId).get();
        expect(userDoc.data()?['liked_posts'], contains(postId));

        // Act: Unlike
        await postService.toggleLikePost(userId, postId, true);
        userDoc = await fakeFirestore.collection('users').doc(userId).get();
        expect(userDoc.data()?['liked_posts'], isNot(contains(postId)));
      });
    });

    group('UserService', () {
      test('createUserDocument creates new user if not exists', () async {
        // Arrange
        final user = MockUser(
          uid: 'new_user',
          displayName: 'New User',
          photoURL: 'http://photo.url',
        );

        // Act
        await userService.createUserDocument(user);

        // Assert
        final doc = await fakeFirestore
            .collection('users')
            .doc('new_user')
            .get();
        expect(doc.exists, true);
        expect(doc.data()?['name'], 'New User');
        expect(doc.data()?['profile_photo_URL'], 'http://photo.url');
        expect(doc.data()?['club_rank'], null);
      });

      test('createUserDocument updates existing user info', () async {
        // Arrange
        const uid = 'existing_user';
        await fakeFirestore.collection('users').doc(uid).set({
          'name': 'Old Name',
          'profile_photo_URL': 'http://old.url',
          'club_rank': 'member', // Should be preserved
        });

        final user = MockUser(
          uid: uid,
          displayName: 'New Name',
          photoURL: 'http://new.url',
        );

        // Act
        await userService.createUserDocument(user);

        // Assert
        final doc = await fakeFirestore.collection('users').doc(uid).get();
        expect(doc.data()?['name'], 'New Name'); // Updated
        expect(doc.data()?['profile_photo_URL'], 'http://new.url'); // Updated
        expect(doc.data()?['club_rank'], 'member'); // Preserved
      });
    });
  });
}
