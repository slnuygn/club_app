import 'package:club_app/services/post_service.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/post_data.dart';
import '../widgets/post.dart';
import '../widgets/post_showcase.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  static const double _imageHeight = 180;

  List<PostShowcaseData> _posts = [];
  final Set<int> _favoriteIndices = <int>{};
  final Set<int> _popularFavoriteIndices = <int>{};
  List<PostCardData> _popularPosts = [];
  int _currentIndex = 0;

  final PostService _postService = PostService();

  @override
  void initState() {
    super.initState();
    _fetchPostData();
  }

  void _fetchPostData() async {
    try {
      final data = await _postService.getPostAndClub('t0sDJPIpfdmo04lQOp0P');
      final Post post = data['post'];
      final Club club = data['club'];

      final postShowcaseData = PostShowcaseData(
        backgroundImageUrl: post.photoURL,
        communityAvatarUrl: club.photoUrl,
        communityName: club.name,
        postCaption: post.postCaption,
        dateDisplay: DateFormat('MMM d, yyyy · h:mm a').format(post.eventDate),
        placeDisplay: post.eventLocationURL,
      );

      final postCardData = PostCardData(
        communityName: club.name,
        communityAvatarUrl: club.photoUrl,
        location: post.eventLocationURL,
        caption: post.postCaption,
        dateDisplay: DateFormat('MMM d, yyyy · h:mm a').format(post.eventDate),
        imageUrl: post.photoURL,
      );

      setState(() {
        _posts = [postShowcaseData];
        _popularPosts = [postCardData];
      });
    } catch (e) {
      // Handle error
      print('Error fetching post data: $e');
    }
  }

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
          child: _posts.isEmpty
              ? const Center(child: CircularProgressIndicator())
              : Column(
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
                          isFavorite: _popularFavoriteIndices.contains(
                            entry.key,
                          ),
                          onFavoriteToggle: () =>
                              _togglePopularFavorite(entry.key),
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
