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
  bool _isLoading = true;

  final PostService _postService = PostService();

  @override
  void initState() {
    super.initState();
    _fetchPostData();
  }

  Future<void> _fetchPostData() async {
    try {
      final allPostsData = await _postService.getAllPosts();

      final List<PostShowcaseData> showcasePosts = [];
      final List<PostCardData> popularPosts = [];

      for (var data in allPostsData) {
        final Post post = data['post'];
        final Club club = data['club'];

        final postShowcaseData = PostShowcaseData(
          backgroundImageUrl: post.photoURL,
          communityAvatarUrl: club.photoUrl,
          communityName: club.name,
          postCaption: post.postCaption,
          dateDisplay: DateFormat(
            'MMM d, yyyy · h:mm a',
          ).format(post.eventDate),
          placeDisplay: post.eventLocationURL,
        );

        final postCardData = PostCardData(
          communityName: club.name,
          communityAvatarUrl: club.photoUrl,
          location: post.eventLocationURL,
          caption: post.postCaption,
          dateDisplay: DateFormat(
            'MMM d, yyyy · h:mm a',
          ).format(post.eventDate),
          imageUrl: post.photoURL,
        );

        showcasePosts.add(postShowcaseData);
        popularPosts.add(postCardData);
      }

      setState(() {
        _posts = showcasePosts;
        _popularPosts = popularPosts;
        _isLoading = false;
      });
    } catch (e) {
      // Handle error
      print('Error fetching post data: $e');
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading posts: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
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
        child: _isLoading
            ? const Center(
                child: CircularProgressIndicator(color: Colors.white),
              )
            : _posts.isEmpty
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'No posts available yet',
                      style: TextStyle(color: Colors.white, fontSize: 18),
                    ),
                    const SizedBox(height: 16),
                    TextButton.icon(
                      onPressed: _fetchPostData,
                      icon: const Icon(Icons.refresh, color: Colors.white),
                      label: const Text(
                        'Refresh',
                        style: TextStyle(color: Colors.white),
                      ),
                      style: TextButton.styleFrom(
                        backgroundColor: Colors.blueAccent,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              )
            : RefreshIndicator(
                onRefresh: () async {
                  await _fetchPostData();
                },
                color: Colors.blueAccent,
                backgroundColor: const Color(0xFF282323),
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
                        final bool isLast =
                            entry.key == _popularPosts.length - 1;
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
      ),
    );
  }
}
