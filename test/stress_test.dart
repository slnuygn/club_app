import 'package:flutter_test/flutter_test.dart';
import 'package:club_app/models/post_data.dart';
import 'package:club_app/widgets/post.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

void main() {
  group('Club App Stress Tests', () {
    test('Stress Test Report', () {
      print(
        '\n\n================================================================',
      );
      print('                   CLUB APP STRESS TEST REPORT                  ');
      print(
        '================================================================\n',
      );

      _runJsonParsingStressTest();
      _runListProcessingStressTest();
      _runWidgetInstantiationStressTest();

      print(
        '\n================================================================',
      );
      print('                       END OF REPORT                            ');
      print(
        '================================================================\n\n',
      );
    });
  });
}

void _runJsonParsingStressTest() {
  const int itemCount = 10000;
  const int idealDurationMs = 300; // Ideal time to parse 10k items

  print('Scenario 1: JSON Parsing Stress Test');
  print('Description: Parsing $itemCount raw JSON maps into Post objects.');

  // Generate dummy data
  final List<Map<String, dynamic>> rawData = List.generate(itemCount, (index) {
    return {
      'club_id': 'club_$index',
      'event_date': Timestamp.now(),
      'event_location_URL': 'https://maps.google.com/?q=$index',
      'event_placeholder': 'Placeholder $index',
      'photo_URL': 'https://example.com/photo_$index.jpg',
      'post_caption':
          'This is a caption for post $index. It is long enough to be realistic.',
    };
  });

  final stopwatch = Stopwatch()..start();

  // Perform the stress operation
  final List<Post> posts = rawData
      .map((data) => Post.fromFirestore(data))
      .toList();

  stopwatch.stop();
  final int elapsed = stopwatch.elapsedMilliseconds;

  _printResult(idealDurationMs, elapsed);
}

void _runListProcessingStressTest() {
  const int itemCount = 20000;
  const int idealDurationMs = 150; // Ideal time to filter and sort 20k items

  print('Scenario 2: List Processing (Filter & Sort)');
  print(
    'Description: Filtering and sorting a list of $itemCount Post objects.',
  );

  // Generate objects
  final List<Post> posts = List.generate(itemCount, (index) {
    return Post(
      clubId: 'club_${index % 10}', // 10 different clubs
      eventDate: DateTime.now().add(Duration(days: index % 365)),
      eventLocationURL: 'url',
      eventPlaceholder: 'placeholder',
      photoURL: 'url',
      postCaption: 'caption $index',
    );
  });

  final stopwatch = Stopwatch()..start();

  // 1. Filter: Get posts for 'club_5'
  final filtered = posts.where((p) => p.clubId == 'club_5').toList();

  // 2. Sort: Sort by event date
  filtered.sort((a, b) => a.eventDate.compareTo(b.eventDate));

  stopwatch.stop();
  final int elapsed = stopwatch.elapsedMilliseconds;

  _printResult(idealDurationMs, elapsed);
}

void _runWidgetInstantiationStressTest() {
  const int itemCount = 50000;
  const int idealDurationMs = 200;

  print('Scenario 3: Widget Instantiation Stress Test');
  print(
    'Description: Creating $itemCount PostCard widget objects (memory/cpu).',
  );

  final stopwatch = Stopwatch()..start();

  // Create many widget objects (simulating a very long list being built)
  final List<PostCard> widgets = List.generate(itemCount, (index) {
    return PostCard(
      data: PostCardData(
        communityName: 'Community $index',
        communityAvatarUrl: 'avatar_url',
        location: 'Location $index',
        caption: 'Caption $index',
        dateDisplay: 'Today',
        imageUrl: 'image_url',
        clubId: 'club_$index',
      ),
    );
  });

  stopwatch.stop();
  final int elapsed = stopwatch.elapsedMilliseconds;

  _printResult(idealDurationMs, elapsed);
}

void _printResult(int ideal, int actual) {
  final double score = (ideal / actual) * 100;
  final bool isPass = actual <= ideal;

  // ANSI Color Codes
  const String green = '\x1B[32m';
  const String red = '\x1B[31m';
  const String reset = '\x1B[0m';

  final String status = isPass ? '${green}PASS${reset}' : '${red}WARN${reset}';

  print('Ideal Score (Time): < ${ideal}ms');
  print('App Score (Time):   ${actual}ms');
  print('Performance Index:  ${score.toStringAsFixed(1)}% (Higher is better)');
  print('Status:             $status');
  print('----------------------------------------------------------------\n');
}
