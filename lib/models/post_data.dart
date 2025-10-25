import 'package:cloud_firestore/cloud_firestore.dart';

class Club {
  final String name;
  final String photoUrl;

  Club({required this.name, required this.photoUrl});

  factory Club.fromFirestore(Map<String, dynamic> data) {
    return Club(
      name: data['club_name'] ?? '',
      photoUrl: data['club_photo_URL'] ?? '',
    );
  }
}

class Post {
  final String clubId;
  final DateTime eventDate;
  final String eventLocationURL;
  final String photoURL;
  final String postCaption;

  Post({
    required this.clubId,
    required this.eventDate,
    required this.eventLocationURL,
    required this.photoURL,
    required this.postCaption,
  });

  factory Post.fromFirestore(Map<String, dynamic> data) {
    return Post(
      clubId: data['club_id'] ?? '',
      eventDate: (data['event_date'] as Timestamp).toDate(),
      eventLocationURL: data['event_location_URL'] ?? '',
      photoURL: data['photo_URL'] ?? '',
      postCaption: data['post_caption'] ?? '',
    );
  }
}
