import 'dart:math';
import 'package:integration_test/integration_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:club_app/firebase_options.dart';
import 'package:club_app/models/post_data.dart';
import 'package:club_app/services/post_service.dart';
import 'package:club_app/services/user_service.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  late FirebaseFirestore firestore;
  late FirebaseStorage storage;
  late PostService postService;
  late UserService userService;

  final createdUserIds = <String>[];
  final createdClubIds = <String>[];
  final createdPostIds = <String>[];

  String generateTestId(String prefix) {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final random = Random().nextInt(10000);
    return '$prefix${timestamp}_$random';
  }

  setUpAll(() async {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    firestore = FirebaseFirestore.instance;
    storage = FirebaseStorage.instance;
    postService = PostService(firestore: firestore, storage: storage);
    userService = UserService(firestore: firestore);
  });

  tearDown(() async {
    for (final id in createdUserIds) {
      try {
        await firestore.collection('users').doc(id).delete();
      } catch (_) {}
    }
    for (final id in createdClubIds) {
      try {
        await firestore.collection('clubs').doc(id).delete();
      } catch (_) {}
    }
    for (final id in createdPostIds) {
      try {
        await firestore.collection('posts').doc(id).delete();
      } catch (_) {}
    }
    createdUserIds.clear();
    createdClubIds.clear();
    createdPostIds.clear();
  });

  group('Firebase Integration', () {
    testWidgets('initializes and can read/write', (tester) async {
      // health check
      final snap = await firestore.collection('clubs').limit(1).get();
      expect(snap, isNotNull);
    });

    testWidgets('CRUD: post + club', (tester) async {
      final clubId = generateTestId('it_club_');
      final postId = generateTestId('it_post_');
      createdClubIds.add(clubId);
      createdPostIds.add(postId);

      await firestore.collection('clubs').doc(clubId).set({
        'club_name': 'IT Club',
        'club_photo_URL': 'https://example.com/club.jpg',
        'club_bio': 'bio',
      });

      await firestore.collection('posts').doc(postId).set({
        'club_id': clubId,
        'event_date': Timestamp.fromDate(
          DateTime.now().add(const Duration(days: 3)),
        ),
        'event_location_URL': 'https://maps.google.com',
        'event_placeholder': 'loc',
        'photo_URL': 'https://example.com/photo.jpg',
        'post_caption': 'caption',
        'state': 'approved',
      });

      final post = await postService.getPost(postId);
      final club = await postService.getClub(clubId);

      expect(post, isA<Post>());
      expect(club, isA<Club>());
      expect(post.clubId, clubId);
      expect(club.name, 'IT Club');
    });

    testWidgets('likes and follows', (tester) async {
      final userId = generateTestId('it_user_');
      final postId = generateTestId('it_post_');
      final clubId = generateTestId('it_club_');
      createdUserIds.add(userId);
      createdPostIds.add(postId);
      createdClubIds.add(clubId);

      await firestore.collection('users').doc(userId).set({
        'name': 'User',
        'liked_posts': [],
        'following_clubs': [],
      });
      await firestore.collection('clubs').doc(clubId).set({
        'club_name': 'Club',
        'club_photo_URL': 'http://url',
      });

      await postService.toggleLikePost(userId, postId, false);
      await postService.toggleFollowClub(userId, clubId, false);

      var doc = await firestore.collection('users').doc(userId).get();
      expect(
        List<String>.from(doc.data()?['liked_posts'] ?? []),
        contains(postId),
      );
      expect(
        List<String>.from(doc.data()?['following_clubs'] ?? []),
        contains(clubId),
      );

      await postService.toggleLikePost(userId, postId, true);
      await postService.toggleFollowClub(userId, clubId, true);

      doc = await firestore.collection('users').doc(userId).get();
      expect(
        List<String>.from(doc.data()?['liked_posts'] ?? []),
        isNot(contains(postId)),
      );
      expect(
        List<String>.from(doc.data()?['following_clubs'] ?? []),
        isNot(contains(clubId)),
      );
    });

    testWidgets('getAllPosts filtered and excludeClubIds', (tester) async {
      final clubA = generateTestId('it_club_');
      final clubB = generateTestId('it_club_');
      final postA = generateTestId('it_post_');
      final postB = generateTestId('it_post_');
      createdClubIds.addAll([clubA, clubB]);
      createdPostIds.addAll([postA, postB]);

      await firestore.collection('clubs').doc(clubA).set({
        'club_name': 'A',
        'club_photo_URL': 'http://a',
      });
      await firestore.collection('clubs').doc(clubB).set({
        'club_name': 'B',
        'club_photo_URL': 'http://b',
      });

      await firestore.collection('posts').doc(postA).set({
        'club_id': clubA,
        'event_date': Timestamp.now(),
        'event_location_URL': 'loc',
        'event_placeholder': 'place',
        'photo_URL': 'http://photo',
        'post_caption': 'Approved A',
        'state': 'approved',
      });

      await firestore.collection('posts').doc(postB).set({
        'club_id': clubB,
        'event_date': Timestamp.now(),
        'event_location_URL': 'loc',
        'event_placeholder': 'place',
        'photo_URL': 'http://photo',
        'post_caption': 'Pending B',
        'state': 'pending',
      });

      final approved = await postService.getAllPosts(state: 'approved');
      final excluded = await postService.getAllPosts(
        state: 'approved',
        excludeClubIds: [clubA],
      );

      final approvedCaptions = approved
          .map((e) => (e['post'] as Post).postCaption)
          .toList();
      final excludedClubIds = excluded
          .map((e) => (e['post'] as Post).clubId)
          .toList();

      expect(approvedCaptions, contains('Approved A'));
      expect(excludedClubIds, isNot(contains(clubA)));
    });

    testWidgets('stress: rapid reads and bulk writes', (tester) async {
      final clubId = generateTestId('it_club_');
      final userId = generateTestId('it_user_');
      createdClubIds.add(clubId);
      createdUserIds.add(userId);

      await firestore.collection('clubs').doc(clubId).set({
        'club_name': 'Stress',
        'club_photo_URL': 'http://stress',
      });
      await firestore.collection('users').doc(userId).set({
        'name': 'Bulk',
        'liked_posts': [],
        'following_clubs': [],
      });

      final reads = await Future.wait(
        List.generate(10, (_) => postService.getClub(clubId)),
      );
      expect(reads.length, 10);

      for (int i = 0; i < 10; i++) {
        await postService.toggleLikePost(userId, 'bulk_post_$i', false);
        await postService.toggleFollowClub(userId, 'bulk_club_$i', false);
      }

      final doc = await firestore.collection('users').doc(userId).get();
      expect(List<String>.from(doc.data()?['liked_posts'] ?? []).length, 10);
      expect(
        List<String>.from(doc.data()?['following_clubs'] ?? []).length,
        10,
      );
    });
  });
}
