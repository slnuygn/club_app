import 'package:cloud_firestore/cloud_firestore.dart';

class Club {
  final String name;
  final String photoUrl;
  final String clubBio;

  Club({required this.name, required this.photoUrl, required this.clubBio});

  factory Club.fromFirestore(Map<String, dynamic> data) {
    return Club(
      name: data['club_name'] ?? '',
      photoUrl: data['club_photo_URL'] ?? '',
      clubBio: data['club_bio'] ?? '',
    );
  }
}

class Post {
  final String clubId;
  final DateTime eventDate;
  final String eventLocationURL;
  final String eventPlaceholder;
  final String photoURL;
  final String postCaption;

  Post({
    required this.clubId,
    required this.eventDate,
    required this.eventLocationURL,
    required this.eventPlaceholder,
    required this.photoURL,
    required this.postCaption,
  });

  factory Post.fromFirestore(Map<String, dynamic> data) {
    return Post(
      clubId: data['club_id'] ?? '',
      eventDate: (data['event_date'] as Timestamp).toDate(),
      eventLocationURL: data['event_location_URL'] ?? '',
      eventPlaceholder: data['event_placeholder'] ?? '',
      photoURL: data['photo_URL'] ?? '',
      postCaption: data['post_caption'] ?? '',
    );
  }
}
