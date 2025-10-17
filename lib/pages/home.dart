import 'package:flutter/material.dart';

import '../widgets/post.dart';
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
  final Set<int> _popularFavoriteIndices = <int>{};
  final List<PostCardData> _popularPosts = const [
    PostCardData(
      communityName: 'Weekend Explorers',
      communityAvatarUrl: 'https://picsum.photos/seed/popular_avatar1/120',
      location: 'Sunset Point Overlook',
      caption:
          'Sunset hike to the ridge followed by stargazing with astronomy club members. Bring water and a light jacket.',
      dateDisplay: 'Oct 19, 2025 · 5:00 PM',
      imageUrl: 'https://picsum.photos/seed/popular_image1/400/200',
    ),
    PostCardData(
      communityName: 'Campus Foodies',
      communityAvatarUrl: 'https://picsum.photos/seed/popular_avatar2/120',
      location: 'Main Quad, Booth 7',
      caption:
          'Taste dishes from student chefs across campus. Vote for your favorite plate and win café vouchers.',
      dateDisplay: 'Oct 20, 2025 · 12:00 PM',
      imageUrl: 'https://picsum.photos/seed/popular_image2/400/200',
    ),
    PostCardData(
      communityName: 'Makers Collective',
      communityAvatarUrl: 'https://picsum.photos/seed/popular_avatar3/120',
      location: 'Innovation Lab, Room 204',
      caption:
          'Drop-in woodworking workshop covering safe tool use and a quick planter build you can take home.',
      dateDisplay: 'Oct 22, 2025 · 3:30 PM',
      imageUrl: 'https://picsum.photos/seed/popular_image3/400/200',
    ),
  ];
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

  void _togglePopularFavorite(int index) {
    setState(() {
      if (_popularFavoriteIndices.contains(index)) {
        _popularFavoriteIndices.remove(index);
      } else {
        _popularFavoriteIndices.add(index);
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
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(left: 10, right: 10, top: 1),
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
              const SizedBox(height: 12),
              ..._popularPosts.asMap().entries.map((
                MapEntry<int, PostCardData> entry,
              ) {
                final bool isLast = entry.key == _popularPosts.length - 1;
                return Padding(
                  padding: EdgeInsets.only(bottom: isLast ? 0 : 12),
                  child: PostCard(
                    data: entry.value,
                    isFavorite: _popularFavoriteIndices.contains(entry.key),
                    onFavoriteToggle: () => _togglePopularFavorite(entry.key),
                  ),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }
}
