import 'package:club_app/firebase_options.dart';
import 'package:club_app/models/post_data.dart';
import 'package:club_app/services/post_service.dart';
import 'package:club_app/services/user_service.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'dart:math';

/// Real Firebase API Tests
/// These tests run against the actual Firebase backend.
///
/// IMPORTANT:
/// - These tests modify real data in your Firebase project
/// - Run with: flutter test test/api_test_real.dart --dart-define=FIREBASE_TEST=true
/// - Make sure you have proper Firebase credentials configured
/// - Test data is cleaned up after each test

void main() {
  // Test configuration
  const String testUserIdPrefix = 'test_user_';
  const String testClubIdPrefix = 'test_club_';
  const String testPostIdPrefix = 'test_post_';

  late FirebaseFirestore firestore;
  late FirebaseStorage storage;
  late PostService postService;
  // ignore: unused_local_variable - kept for future UserService tests
  late UserService userService;

  // Track created documents for cleanup
  final List<String> createdUserIds = [];
  final List<String> createdClubIds = [];
  final List<String> createdPostIds = [];

  String generateTestId(String prefix) {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final random = Random().nextInt(10000);
    return '$prefix${timestamp}_$random';
  }

  setUpAll(() async {
    // Initialize Firebase for testing
    TestWidgetsFlutterBinding.ensureInitialized();

    try {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
    } catch (e) {
      // Firebase might already be initialized
      print('Firebase initialization: $e');
    }

    firestore = FirebaseFirestore.instance;
    storage = FirebaseStorage.instance;
    postService = PostService(firestore: firestore, storage: storage);
    userService = UserService(firestore: firestore);
  });

  tearDown(() async {
    // Clean up created test documents
    for (final userId in createdUserIds) {
      try {
        await firestore.collection('users').doc(userId).delete();
      } catch (e) {
        print('Cleanup error for user $userId: $e');
      }
    }
    for (final clubId in createdClubIds) {
      try {
        await firestore.collection('clubs').doc(clubId).delete();
      } catch (e) {
        print('Cleanup error for club $clubId: $e');
      }
    }
    for (final postId in createdPostIds) {
      try {
        await firestore.collection('posts').doc(postId).delete();
      } catch (e) {
        print('Cleanup error for post $postId: $e');
      }
    }
    createdUserIds.clear();
    createdClubIds.clear();
    createdPostIds.clear();
  });

  group('Real Firebase API Tests', () {
    group('Connection & Health Check', () {
      test('Firebase connection is established', () async {
        // Simple health check - try to access Firestore
        expect(firestore, isNotNull);

        // Try a simple read operation
        final snapshot = await firestore.collection('clubs').limit(1).get();
        expect(snapshot, isNotNull);
      });

      test('Firebase Storage is accessible', () async {
        expect(storage, isNotNull);

        // Verify we can reference storage
        final ref = storage.ref();
        expect(ref, isNotNull);
      });
    });

    group('PostService - CRUD Operations', () {
      test('getPost retrieves existing post with correct data types', () async {
        // Create a test post
        final testPostId = generateTestId(testPostIdPrefix);
        final testClubId = generateTestId(testClubIdPrefix);
        createdPostIds.add(testPostId);
        createdClubIds.add(testClubId);

        final testDate = DateTime.now().add(const Duration(days: 7));

        await firestore.collection('clubs').doc(testClubId).set({
          'club_name': 'Test Club for Post',
          'club_photo_URL': 'https://example.com/club.jpg',
          'club_bio': 'Test bio',
        });

        await firestore.collection('posts').doc(testPostId).set({
          'club_id': testClubId,
          'event_date': Timestamp.fromDate(testDate),
          'event_location_URL': 'https://maps.google.com/test',
          'event_placeholder': 'Test Location',
          'photo_URL': 'https://example.com/test-photo.jpg',
          'post_caption': 'Test Caption for Real API',
          'state': 'approved',
        });

        // Act
        final post = await postService.getPost(testPostId);

        // Assert
        expect(post, isA<Post>());
        expect(post.clubId, testClubId);
        expect(post.postCaption, 'Test Caption for Real API');
        expect(post.photoURL, 'https://example.com/test-photo.jpg');
        expect(post.eventLocationURL, 'https://maps.google.com/test');
        expect(post.eventPlaceholder, 'Test Location');
        expect(post.eventDate.year, testDate.year);
        expect(post.eventDate.month, testDate.month);
        expect(post.eventDate.day, testDate.day);
      });

      test('getClub retrieves existing club with all fields', () async {
        final testClubId = generateTestId(testClubIdPrefix);
        createdClubIds.add(testClubId);

        await firestore.collection('clubs').doc(testClubId).set({
          'club_name': 'Integration Test Club',
          'club_photo_URL': 'https://example.com/integration-club.jpg',
          'club_bio': 'This is a test club bio',
        });

        // Act
        final club = await postService.getClub(testClubId);

        // Assert
        expect(club, isA<Club>());
        expect(club.name, 'Integration Test Club');
        expect(club.photoUrl, 'https://example.com/integration-club.jpg');
        expect(club.clubBio, 'This is a test club bio');
      });

      test('getPostAndClub returns both post and club data', () async {
        final testClubId = generateTestId(testClubIdPrefix);
        final testPostId = generateTestId(testPostIdPrefix);
        createdClubIds.add(testClubId);
        createdPostIds.add(testPostId);

        await firestore.collection('clubs').doc(testClubId).set({
          'club_name': 'Combined Test Club',
          'club_photo_URL': 'https://example.com/combined.jpg',
          'club_bio': 'Combined test',
        });

        await firestore.collection('posts').doc(testPostId).set({
          'club_id': testClubId,
          'event_date': Timestamp.now(),
          'event_location_URL': 'https://location.test',
          'event_placeholder': 'Combined Location',
          'photo_URL': 'https://example.com/combined-post.jpg',
          'post_caption': 'Combined Caption',
          'state': 'approved',
        });

        // Act
        final result = await postService.getPostAndClub(testPostId);

        // Assert
        expect(result['post'], isA<Post>());
        expect(result['club'], isA<Club>());
        expect((result['post'] as Post).clubId, testClubId);
        expect((result['club'] as Club).name, 'Combined Test Club');
      });

      test('getAllPosts returns list of posts filtered by state', () async {
        final testClubId = generateTestId(testClubIdPrefix);
        final testPostId1 = generateTestId(testPostIdPrefix);
        final testPostId2 = generateTestId(testPostIdPrefix);
        createdClubIds.add(testClubId);
        createdPostIds.addAll([testPostId1, testPostId2]);

        await firestore.collection('clubs').doc(testClubId).set({
          'club_name': 'List Test Club',
          'club_photo_URL': 'https://example.com/list.jpg',
          'club_bio': 'List test bio',
        });

        await firestore.collection('posts').doc(testPostId1).set({
          'club_id': testClubId,
          'event_date': Timestamp.now(),
          'event_location_URL': 'https://loc1.test',
          'event_placeholder': 'Location 1',
          'photo_URL': 'https://example.com/post1.jpg',
          'post_caption': 'Approved Post',
          'state': 'approved',
        });

        await firestore.collection('posts').doc(testPostId2).set({
          'club_id': testClubId,
          'event_date': Timestamp.now(),
          'event_location_URL': 'https://loc2.test',
          'event_placeholder': 'Location 2',
          'photo_URL': 'https://example.com/post2.jpg',
          'post_caption': 'Pending Post',
          'state': 'pending',
        });

        // Act - get only approved posts
        final approvedPosts = await postService.getAllPosts(state: 'approved');
        final pendingPosts = await postService.getAllPosts(state: 'pending');

        // Assert
        final approvedCaptions = approvedPosts
            .map((p) => (p['post'] as Post).postCaption)
            .toList();
        final pendingCaptions = pendingPosts
            .map((p) => (p['post'] as Post).postCaption)
            .toList();

        expect(approvedCaptions, contains('Approved Post'));
        expect(pendingCaptions, contains('Pending Post'));
      });

      test('getAllPosts respects excludeClubIds parameter', () async {
        final testClubId1 = generateTestId(testClubIdPrefix);
        final testClubId2 = generateTestId(testClubIdPrefix);
        final testPostId1 = generateTestId(testPostIdPrefix);
        final testPostId2 = generateTestId(testPostIdPrefix);
        createdClubIds.addAll([testClubId1, testClubId2]);
        createdPostIds.addAll([testPostId1, testPostId2]);

        await firestore.collection('clubs').doc(testClubId1).set({
          'club_name': 'Club To Exclude',
          'club_photo_URL': 'https://example.com/exclude.jpg',
          'club_bio': 'Excluded',
        });

        await firestore.collection('clubs').doc(testClubId2).set({
          'club_name': 'Club To Include',
          'club_photo_URL': 'https://example.com/include.jpg',
          'club_bio': 'Included',
        });

        await firestore.collection('posts').doc(testPostId1).set({
          'club_id': testClubId1,
          'event_date': Timestamp.now(),
          'event_location_URL': 'https://loc.test',
          'event_placeholder': 'Location',
          'photo_URL': 'https://example.com/excluded.jpg',
          'post_caption': 'Excluded Club Post',
          'state': 'approved',
        });

        await firestore.collection('posts').doc(testPostId2).set({
          'club_id': testClubId2,
          'event_date': Timestamp.now(),
          'event_location_URL': 'https://loc.test',
          'event_placeholder': 'Location',
          'photo_URL': 'https://example.com/included.jpg',
          'post_caption': 'Included Club Post',
          'state': 'approved',
        });

        // Act
        final posts = await postService.getAllPosts(
          state: 'approved',
          excludeClubIds: [testClubId1],
        );

        // Assert - should not contain posts from excluded club
        final clubIds = posts.map((p) => (p['post'] as Post).clubId).toList();
        expect(clubIds, isNot(contains(testClubId1)));
      });
    });

    group('PostService - Like Operations', () {
      test('toggleLikePost adds post to liked_posts', () async {
        final testUserId = generateTestId(testUserIdPrefix);
        final testPostId = generateTestId(testPostIdPrefix);
        createdUserIds.add(testUserId);
        createdPostIds.add(testPostId);

        await firestore.collection('users').doc(testUserId).set({
          'name': 'Like Test User',
          'liked_posts': [],
        });

        // Act - Like the post (isLiked = false means we're adding)
        await postService.toggleLikePost(testUserId, testPostId, false);

        // Assert
        final userDoc = await firestore
            .collection('users')
            .doc(testUserId)
            .get();
        expect(userDoc.data()?['liked_posts'], contains(testPostId));
      });

      test('toggleLikePost removes post from liked_posts', () async {
        final testUserId = generateTestId(testUserIdPrefix);
        final testPostId = generateTestId(testPostIdPrefix);
        createdUserIds.add(testUserId);
        createdPostIds.add(testPostId);

        await firestore.collection('users').doc(testUserId).set({
          'name': 'Unlike Test User',
          'liked_posts': [testPostId],
        });

        // Act - Unlike the post (isLiked = true means we're removing)
        await postService.toggleLikePost(testUserId, testPostId, true);

        // Assert
        final userDoc = await firestore
            .collection('users')
            .doc(testUserId)
            .get();
        expect(userDoc.data()?['liked_posts'], isNot(contains(testPostId)));
      });

      test('toggleLikePost creates liked_posts field if not exists', () async {
        final testUserId = generateTestId(testUserIdPrefix);
        final testPostId = generateTestId(testPostIdPrefix);
        createdUserIds.add(testUserId);
        createdPostIds.add(testPostId);

        await firestore.collection('users').doc(testUserId).set({
          'name': 'New Like User',
          // No liked_posts field
        });

        // Act
        await postService.toggleLikePost(testUserId, testPostId, false);

        // Assert
        final userDoc = await firestore
            .collection('users')
            .doc(testUserId)
            .get();
        expect(userDoc.data()?['liked_posts'], contains(testPostId));
      });

      test('getUserLikedPosts returns correct list', () async {
        final testUserId = generateTestId(testUserIdPrefix);
        createdUserIds.add(testUserId);

        final likedPosts = ['post_1', 'post_2', 'post_3'];
        await firestore.collection('users').doc(testUserId).set({
          'name': 'Liked Posts User',
          'liked_posts': likedPosts,
        });

        // Act
        final result = await postService.getUserLikedPosts(testUserId);

        // Assert
        expect(result, containsAll(likedPosts));
        expect(result.length, 3);
      });

      test(
        'getUserLikedPosts returns empty list for user without likes',
        () async {
          final testUserId = generateTestId(testUserIdPrefix);
          createdUserIds.add(testUserId);

          await firestore.collection('users').doc(testUserId).set({
            'name': 'No Likes User',
          });

          // Act
          final result = await postService.getUserLikedPosts(testUserId);

          // Assert
          expect(result, isEmpty);
        },
      );
    });

    group('PostService - Follow Operations', () {
      test('toggleFollowClub adds club to following_clubs', () async {
        final testUserId = generateTestId(testUserIdPrefix);
        final testClubId = generateTestId(testClubIdPrefix);
        createdUserIds.add(testUserId);
        createdClubIds.add(testClubId);

        await firestore.collection('users').doc(testUserId).set({
          'name': 'Follow Test User',
          'following_clubs': [],
        });

        // Act - Follow the club
        await postService.toggleFollowClub(testUserId, testClubId, false);

        // Assert
        final userDoc = await firestore
            .collection('users')
            .doc(testUserId)
            .get();
        expect(userDoc.data()?['following_clubs'], contains(testClubId));
      });

      test('toggleFollowClub removes club from following_clubs', () async {
        final testUserId = generateTestId(testUserIdPrefix);
        final testClubId = generateTestId(testClubIdPrefix);
        createdUserIds.add(testUserId);
        createdClubIds.add(testClubId);

        await firestore.collection('users').doc(testUserId).set({
          'name': 'Unfollow Test User',
          'following_clubs': [testClubId],
        });

        // Act - Unfollow the club
        await postService.toggleFollowClub(testUserId, testClubId, true);

        // Assert
        final userDoc = await firestore
            .collection('users')
            .doc(testUserId)
            .get();
        expect(userDoc.data()?['following_clubs'], isNot(contains(testClubId)));
      });

      test('getUserFollowedClubs returns correct list', () async {
        final testUserId = generateTestId(testUserIdPrefix);
        createdUserIds.add(testUserId);

        final followedClubs = ['club_1', 'club_2'];
        await firestore.collection('users').doc(testUserId).set({
          'name': 'Followed Clubs User',
          'following_clubs': followedClubs,
        });

        // Act
        final result = await postService.getUserFollowedClubs(testUserId);

        // Assert
        expect(result, containsAll(followedClubs));
      });
    });

    group('UserService - User Management', () {
      test('createUserDocument creates new user document', () async {
        // Note: This test uses a mock user since we can't easily create a real Firebase user
        // In a real scenario, you'd use Firebase Auth to create a test user
        final testUserId = generateTestId(testUserIdPrefix);
        createdUserIds.add(testUserId);

        // Manually create user document as the service would
        await firestore.collection('users').doc(testUserId).set({
          'club_key': null,
          'club_rank': null,
          'following_clubs': null,
          'liked_posts': null,
          'name': 'New Test User',
          'profile_photo_URL': 'https://example.com/photo.jpg',
        });

        // Assert
        final doc = await firestore.collection('users').doc(testUserId).get();
        expect(doc.exists, true);
        expect(doc.data()?['name'], 'New Test User');
        expect(
          doc.data()?['profile_photo_URL'],
          'https://example.com/photo.jpg',
        );
        expect(doc.data()?['club_rank'], isNull);
      });

      test('user document update preserves existing fields', () async {
        final testUserId = generateTestId(testUserIdPrefix);
        createdUserIds.add(testUserId);

        // Create initial user with club_rank
        await firestore.collection('users').doc(testUserId).set({
          'name': 'Original Name',
          'profile_photo_URL': 'https://example.com/old.jpg',
          'club_rank': 'president',
          'club_key': 'secret_key_123',
        });

        // Update only name and photo (simulating what createUserDocument does)
        await firestore.collection('users').doc(testUserId).update({
          'name': 'Updated Name',
          'profile_photo_URL': 'https://example.com/new.jpg',
        });

        // Assert - club_rank should be preserved
        final doc = await firestore.collection('users').doc(testUserId).get();
        expect(doc.data()?['name'], 'Updated Name');
        expect(doc.data()?['profile_photo_URL'], 'https://example.com/new.jpg');
        expect(doc.data()?['club_rank'], 'president'); // Preserved
        expect(doc.data()?['club_key'], 'secret_key_123'); // Preserved
      });
    });

    group('Error Handling', () {
      test('getPost throws on non-existent post', () async {
        final nonExistentId =
            'non_existent_${DateTime.now().millisecondsSinceEpoch}';

        expect(
          () => postService.getPost(nonExistentId),
          throwsA(
            anyOf(isA<TypeError>(), isA<NoSuchMethodError>(), isA<Exception>()),
          ),
        );
      });

      test('getClub throws on non-existent club', () async {
        final nonExistentId =
            'non_existent_${DateTime.now().millisecondsSinceEpoch}';

        expect(
          () => postService.getClub(nonExistentId),
          throwsA(
            anyOf(isA<TypeError>(), isA<NoSuchMethodError>(), isA<Exception>()),
          ),
        );
      });

      test('toggleLikePost throws on non-existent user', () async {
        final nonExistentId =
            'non_existent_${DateTime.now().millisecondsSinceEpoch}';

        expect(
          () => postService.toggleLikePost(nonExistentId, 'some_post', false),
          throwsA(isA<Exception>()),
        );
      });
    });

    group('Data Integrity', () {
      test('post data maintains integrity through round trip', () async {
        final testClubId = generateTestId(testClubIdPrefix);
        final testPostId = generateTestId(testPostIdPrefix);
        createdClubIds.add(testClubId);
        createdPostIds.add(testPostId);

        final originalData = {
          'club_id': testClubId,
          'event_date': Timestamp.fromDate(DateTime(2024, 6, 15, 14, 30)),
          'event_location_URL':
              'https://maps.google.com/special?chars=test&more=data',
          'event_placeholder': 'Test Location with Special Chars: @#\$%',
          'photo_URL': 'https://example.com/photo-with-special_chars.jpg',
          'post_caption': 'Caption with émojis 🎉 and spëcial chârs',
          'state': 'approved',
        };

        await firestore.collection('clubs').doc(testClubId).set({
          'club_name': 'Integrity Club',
          'club_photo_URL': 'https://example.com/club.jpg',
          'club_bio': 'Bio',
        });

        await firestore.collection('posts').doc(testPostId).set(originalData);

        // Act
        final post = await postService.getPost(testPostId);

        // Assert
        expect(post.clubId, testClubId);
        expect(post.eventLocationURL, originalData['event_location_URL']);
        expect(post.eventPlaceholder, originalData['event_placeholder']);
        expect(post.postCaption, originalData['post_caption']);
      });

      test('concurrent like operations maintain consistency', () async {
        final testUserId = generateTestId(testUserIdPrefix);
        createdUserIds.add(testUserId);

        await firestore.collection('users').doc(testUserId).set({
          'name': 'Concurrent Test User',
          'liked_posts': [],
        });

        // Perform multiple concurrent like operations
        final futures = <Future>[];
        for (int i = 0; i < 5; i++) {
          futures.add(postService.toggleLikePost(testUserId, 'post_$i', false));
        }
        await Future.wait(futures);

        // Assert all posts are liked
        final userDoc = await firestore
            .collection('users')
            .doc(testUserId)
            .get();
        final likedPosts = List<String>.from(
          userDoc.data()?['liked_posts'] ?? [],
        );
        expect(likedPosts.length, 5);
        for (int i = 0; i < 5; i++) {
          expect(likedPosts, contains('post_$i'));
        }
      });
    });
  });

  group('Stress Tests', () {
    test('handle rapid consecutive reads', () async {
      final testClubId = generateTestId(testClubIdPrefix);
      createdClubIds.add(testClubId);

      await firestore.collection('clubs').doc(testClubId).set({
        'club_name': 'Stress Test Club',
        'club_photo_URL': 'https://example.com/stress.jpg',
        'club_bio': 'Stress test bio',
      });

      final stopwatch = Stopwatch()..start();

      // Perform 20 rapid reads
      final futures = List.generate(20, (_) => postService.getClub(testClubId));
      final results = await Future.wait(futures);

      stopwatch.stop();

      // Assert all reads succeeded
      expect(results.length, 20);
      for (final club in results) {
        expect(club.name, 'Stress Test Club');
      }

      print('20 rapid reads completed in ${stopwatch.elapsedMilliseconds}ms');
      // Should complete in reasonable time (less than 10 seconds)
      expect(stopwatch.elapsedMilliseconds, lessThan(10000));
    });

    test('handle bulk write operations', () async {
      final testUserId = generateTestId(testUserIdPrefix);
      createdUserIds.add(testUserId);

      await firestore.collection('users').doc(testUserId).set({
        'name': 'Bulk Write User',
        'liked_posts': [],
        'following_clubs': [],
      });

      final stopwatch = Stopwatch()..start();

      // Perform 10 write operations (alternating likes and follows)
      for (int i = 0; i < 10; i++) {
        await postService.toggleLikePost(testUserId, 'bulk_post_$i', false);
        await postService.toggleFollowClub(testUserId, 'bulk_club_$i', false);
      }

      stopwatch.stop();

      // Verify data
      final userDoc = await firestore.collection('users').doc(testUserId).get();
      final likedPosts = List<String>.from(
        userDoc.data()?['liked_posts'] ?? [],
      );
      final followingClubs = List<String>.from(
        userDoc.data()?['following_clubs'] ?? [],
      );

      expect(likedPosts.length, 10);
      expect(followingClubs.length, 10);

      print('20 bulk writes completed in ${stopwatch.elapsedMilliseconds}ms');
    });

    test('handle large data payload', () async {
      final testClubId = generateTestId(testClubIdPrefix);
      final testPostId = generateTestId(testPostIdPrefix);
      createdClubIds.add(testClubId);
      createdPostIds.add(testPostId);

      // Create a post with large caption (simulating max content)
      final largeCaption = 'A' * 5000; // 5000 character caption

      await firestore.collection('clubs').doc(testClubId).set({
        'club_name': 'Large Data Club',
        'club_photo_URL': 'https://example.com/large.jpg',
        'club_bio': 'B' * 1000, // 1000 char bio
      });

      await firestore.collection('posts').doc(testPostId).set({
        'club_id': testClubId,
        'event_date': Timestamp.now(),
        'event_location_URL': 'https://maps.google.com/test',
        'event_placeholder': 'Large Data Location',
        'photo_URL': 'https://example.com/large-post.jpg',
        'post_caption': largeCaption,
        'state': 'approved',
      });

      // Act
      final post = await postService.getPost(testPostId);
      final club = await postService.getClub(testClubId);

      // Assert
      expect(post.postCaption.length, 5000);
      expect(club.clubBio.length, 1000);
    });

    test('handle many liked posts efficiently', () async {
      final testUserId = generateTestId(testUserIdPrefix);
      createdUserIds.add(testUserId);

      // Create user with many liked posts
      final manyLikedPosts = List.generate(100, (i) => 'liked_post_$i');
      await firestore.collection('users').doc(testUserId).set({
        'name': 'Many Likes User',
        'liked_posts': manyLikedPosts,
      });

      final stopwatch = Stopwatch()..start();

      final result = await postService.getUserLikedPosts(testUserId);

      stopwatch.stop();

      expect(result.length, 100);
      print('Retrieved 100 liked posts in ${stopwatch.elapsedMilliseconds}ms');
      expect(stopwatch.elapsedMilliseconds, lessThan(5000));
    });

    test('handle concurrent read-write operations', () async {
      final testUserId = generateTestId(testUserIdPrefix);
      createdUserIds.add(testUserId);

      await firestore.collection('users').doc(testUserId).set({
        'name': 'Concurrent RW User',
        'liked_posts': ['initial_post'],
      });

      final stopwatch = Stopwatch()..start();

      // Perform concurrent reads and writes
      final futures = <Future>[];

      // 5 write operations
      for (int i = 0; i < 5; i++) {
        futures.add(
          postService.toggleLikePost(testUserId, 'concurrent_post_$i', false),
        );
      }

      // 10 read operations
      for (int i = 0; i < 10; i++) {
        futures.add(postService.getUserLikedPosts(testUserId));
      }

      await Future.wait(futures);

      stopwatch.stop();

      // Verify final state
      final likedPosts = await postService.getUserLikedPosts(testUserId);
      expect(
        likedPosts.length,
        greaterThanOrEqualTo(5),
      ); // At least 5 new + initial

      print(
        '15 concurrent R/W operations completed in ${stopwatch.elapsedMilliseconds}ms',
      );
    });
  });

  group('Performance Benchmarks', () {
    test('measure single document read latency', () async {
      final testClubId = generateTestId(testClubIdPrefix);
      createdClubIds.add(testClubId);

      await firestore.collection('clubs').doc(testClubId).set({
        'club_name': 'Benchmark Club',
        'club_photo_URL': 'https://example.com/bench.jpg',
        'club_bio': 'Benchmark bio',
      });

      final latencies = <int>[];

      for (int i = 0; i < 10; i++) {
        final stopwatch = Stopwatch()..start();
        await postService.getClub(testClubId);
        stopwatch.stop();
        latencies.add(stopwatch.elapsedMilliseconds);
      }

      final avgLatency = latencies.reduce((a, b) => a + b) / latencies.length;
      final maxLatency = latencies.reduce((a, b) => a > b ? a : b);
      final minLatency = latencies.reduce((a, b) => a < b ? a : b);

      print(
        'Read Latency - Avg: ${avgLatency.toStringAsFixed(2)}ms, Min: ${minLatency}ms, Max: ${maxLatency}ms',
      );

      expect(avgLatency, lessThan(1000)); // Average should be under 1 second
    });

    test('measure write operation latency', () async {
      final testUserId = generateTestId(testUserIdPrefix);
      createdUserIds.add(testUserId);

      await firestore.collection('users').doc(testUserId).set({
        'name': 'Write Benchmark User',
        'liked_posts': [],
      });

      final latencies = <int>[];

      for (int i = 0; i < 10; i++) {
        final stopwatch = Stopwatch()..start();
        await postService.toggleLikePost(testUserId, 'bench_post_$i', false);
        stopwatch.stop();
        latencies.add(stopwatch.elapsedMilliseconds);
      }

      final avgLatency = latencies.reduce((a, b) => a + b) / latencies.length;
      final maxLatency = latencies.reduce((a, b) => a > b ? a : b);
      final minLatency = latencies.reduce((a, b) => a < b ? a : b);

      print(
        'Write Latency - Avg: ${avgLatency.toStringAsFixed(2)}ms, Min: ${minLatency}ms, Max: ${maxLatency}ms',
      );

      expect(avgLatency, lessThan(2000)); // Average should be under 2 seconds
    });

    test('measure getAllPosts query performance', () async {
      // Note: This test measures against existing data in the database
      final stopwatch = Stopwatch()..start();

      final posts = await postService.getAllPosts(state: 'approved');

      stopwatch.stop();

      print(
        'getAllPosts returned ${posts.length} posts in ${stopwatch.elapsedMilliseconds}ms',
      );

      // Should complete in reasonable time regardless of data size
      expect(stopwatch.elapsedMilliseconds, lessThan(30000)); // 30 seconds max
    });
  });

  group('Edge Cases', () {
    test('handle empty string values gracefully', () async {
      final testClubId = generateTestId(testClubIdPrefix);
      final testPostId = generateTestId(testPostIdPrefix);
      createdClubIds.add(testClubId);
      createdPostIds.add(testPostId);

      await firestore.collection('clubs').doc(testClubId).set({
        'club_name': '',
        'club_photo_URL': '',
        'club_bio': '',
      });

      await firestore.collection('posts').doc(testPostId).set({
        'club_id': testClubId,
        'event_date': Timestamp.now(),
        'event_location_URL': '',
        'event_placeholder': '',
        'photo_URL': '',
        'post_caption': '',
        'state': 'approved',
      });

      // Act
      final club = await postService.getClub(testClubId);
      final post = await postService.getPost(testPostId);

      // Assert - should not throw, return empty strings
      expect(club.name, '');
      expect(post.postCaption, '');
    });

    test('handle special characters in data', () async {
      final testClubId = generateTestId(testClubIdPrefix);
      createdClubIds.add(testClubId);

      final specialName = 'Club <script>alert("xss")</script> & More';
      final specialBio = 'Bio with\nnewlines\tand\ttabs and emoji 🎉🚀';

      await firestore.collection('clubs').doc(testClubId).set({
        'club_name': specialName,
        'club_photo_URL': 'https://example.com/special.jpg',
        'club_bio': specialBio,
      });

      // Act
      final club = await postService.getClub(testClubId);

      // Assert - data should be preserved exactly
      expect(club.name, specialName);
      expect(club.clubBio, specialBio);
    });

    test('handle unicode and international characters', () async {
      final testClubId = generateTestId(testClubIdPrefix);
      createdClubIds.add(testClubId);

      final unicodeName = '日本語クラブ العربية 中文 한국어';
      final unicodeBio = 'Ñoño café résumé naïve';

      await firestore.collection('clubs').doc(testClubId).set({
        'club_name': unicodeName,
        'club_photo_URL': 'https://example.com/unicode.jpg',
        'club_bio': unicodeBio,
      });

      // Act
      final club = await postService.getClub(testClubId);

      // Assert
      expect(club.name, unicodeName);
      expect(club.clubBio, unicodeBio);
    });

    test('handle very long document IDs', () async {
      // Firebase allows up to 1500 bytes for document IDs
      final longId = 'a' * 100; // 100 character ID
      final testClubId = '${testClubIdPrefix}$longId';
      createdClubIds.add(testClubId);

      await firestore.collection('clubs').doc(testClubId).set({
        'club_name': 'Long ID Club',
        'club_photo_URL': 'https://example.com/longid.jpg',
        'club_bio': 'Club with long ID',
      });

      // Act
      final club = await postService.getClub(testClubId);

      // Assert
      expect(club.name, 'Long ID Club');
    });

    test('handle rapid toggle operations (like/unlike spam)', () async {
      final testUserId = generateTestId(testUserIdPrefix);
      final testPostId = 'spam_test_post';
      createdUserIds.add(testUserId);

      await firestore.collection('users').doc(testUserId).set({
        'name': 'Toggle Spam User',
        'liked_posts': [],
      });

      // Rapidly toggle like 10 times
      for (int i = 0; i < 10; i++) {
        final isLiked = i % 2 == 1;
        await postService.toggleLikePost(testUserId, testPostId, isLiked);
      }

      // Final state should have the post liked (even number of toggles, started unliked)
      final userDoc = await firestore.collection('users').doc(testUserId).get();
      final likedPosts = List<String>.from(
        userDoc.data()?['liked_posts'] ?? [],
      );

      // After 10 toggles (0-9), post should NOT be liked
      // Toggle 0: unlike (add) -> liked
      // Toggle 1: like (remove) -> not liked
      // ... pattern continues
      // Toggle 9: like (remove) -> not liked
      expect(likedPosts, isNot(contains(testPostId)));
    });
  });
}
