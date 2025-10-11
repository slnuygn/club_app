import 'package:flutter/material.dart';

import '../widgets/post_showcase.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  static const double _imageHeight = 180;

  final List<PostShowcaseData> _posts = const [
    PostShowcaseData(
      backgroundImageUrl: 'https://picsum.photos/seed/event1/400/220',
      communityAvatarUrl: 'https://picsum.photos/seed/avatar1/80',
      communityName: 'Dummy Community',
      postCaption:
          'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Vestibulum vehicula, nisl sed congue dictum, metus augue dapibus purus.',
      dateDisplay: 'Oct 12, 2025 · 6:30 PM',
      placeDisplay: 'Dummy location',
    ),
    PostShowcaseData(
      backgroundImageUrl: 'https://picsum.photos/seed/event2/400/220',
      communityAvatarUrl: 'https://picsum.photos/seed/avatar2/80',
      communityName: 'Outdoor Enthusiasts',
      postCaption:
          'Trail maintenance day followed by a casual bonfire. Tools provided, bring gloves and water.',
      dateDisplay: 'Oct 14, 2025 · 8:00 AM',
      placeDisplay: 'Riverside Trailhead',
    ),
    PostShowcaseData(
      backgroundImageUrl: 'https://picsum.photos/seed/event3/400/220',
      communityAvatarUrl: 'https://picsum.photos/seed/avatar3/80',
      communityName: 'Campus Creators',
      postCaption:
          'Join us for an evening of live art battles and open mic performances featuring local talent.',
      dateDisplay: 'Oct 18, 2025 · 7:30 PM',
      placeDisplay: 'Union Hall, Main Stage',
    ),
  ];

  final Set<int> _favoriteIndices = <int>{};
  int _currentIndex = 0;

  void _toggleFavorite(int index) {
    setState(() {
      if (_favoriteIndices.contains(index)) {
        _favoriteIndices.remove(index);
      } else {
        _favoriteIndices.add(index);
      }
    });
  }

  void _showPrevious() {
    if (_posts.isEmpty) {
      return;
    }
    setState(() {
      _currentIndex = (_currentIndex - 1) % _posts.length;
      if (_currentIndex < 0) {
        _currentIndex += _posts.length;
      }
    });
  }

  void _showNext() {
    if (_posts.isEmpty) {
      return;
    }
    setState(() {
      _currentIndex = (_currentIndex + 1) % _posts.length;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF282323),
      body: Align(
        alignment: Alignment.topLeft,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Today's events",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 1),
              PostShowcase(
                data: _posts[_currentIndex],
                isFavorite: _favoriteIndices.contains(_currentIndex),
                onFavoriteToggle: () => _toggleFavorite(_currentIndex),
                onPrevious: _showPrevious,
                onNext: _showNext,
                imageHeight: _imageHeight,
              ),
              const SizedBox(height: 12),
              PostShowcaseIndicator(
                count: _posts.length,
                activeIndex: _currentIndex,
              ),
              const Text(
                "Popular events",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  height: 1,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
