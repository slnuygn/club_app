import 'package:club_app/services/post_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
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
  List<String> _showcasePostIds = []; // Store showcase post IDs separately
  List<String> _postIds = []; // Store all post IDs
  final Set<String> _likedPostIds = <String>{}; // Changed to store post IDs
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
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        setState(() {
          _isLoading = false;
        });
        return;
      }

      // Fetch user's liked posts
      final likedPosts = await _postService.getUserLikedPosts(user.uid);

      final allPostsData = await _postService.getAllPosts();

      final List<PostShowcaseData> showcasePosts = [];
      final List<String> showcasePostIds = []; // Separate list for showcase IDs
      final List<PostCardData> popularPosts = [];
      final List<String> postIds = [];

      // Get today's date (without time component)
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);

      for (var data in allPostsData) {
        final Post post = data['post'];
        final Club club = data['club'];
        final String postId = data['postId']; // Get the post ID

        // Get post event date (without time component)
        final eventDate = post.eventDate;
        final eventDay = DateTime(
          eventDate.year,
          eventDate.month,
          eventDate.day,
        );

        // Check if the event is today
        final isToday = eventDay.isAtSameMomentAs(today);

        final postShowcaseData = PostShowcaseData(
          backgroundImageUrl: post.photoURL,
          communityAvatarUrl: club.photoUrl,
          communityName: club.name,
          postCaption: post.postCaption,
          dateDisplay: DateFormat(
            'MMM d, yyyy · h:mm a',
          ).format(post.eventDate),
          placeDisplay: post.eventPlaceholder,
        );

        final postCardData = PostCardData(
          communityName: club.name,
          communityAvatarUrl: club.photoUrl,
          location: post.eventPlaceholder,
          caption: post.postCaption,
          dateDisplay: DateFormat(
            'MMM d, yyyy · h:mm a',
          ).format(post.eventDate),
          imageUrl: post.photoURL,
        );

        // Only add to showcase if event is today
        if (isToday) {
          showcasePosts.add(postShowcaseData);
          showcasePostIds.add(postId);
        }

        // All posts go to popular section
        popularPosts.add(postCardData);
        postIds.add(postId);
      }

      setState(() {
        _posts = showcasePosts;
        _showcasePostIds = showcasePostIds;
        _popularPosts = popularPosts;
        _postIds = postIds;
        _likedPostIds.clear();
        _likedPostIds.addAll(likedPosts);
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

  Future<void> _toggleFavorite(int index) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null || index >= _showcasePostIds.length) return;

    final postId = _showcasePostIds[index];
    final isCurrentlyLiked = _likedPostIds.contains(postId);

    // Optimistically update UI
    setState(() {
      if (isCurrentlyLiked) {
        _likedPostIds.remove(postId);
      } else {
        _likedPostIds.add(postId);
      }
    });

    try {
      // Update Firestore
      await _postService.toggleLikePost(user.uid, postId, isCurrentlyLiked);
    } catch (e) {
      // Revert on error
      setState(() {
        if (isCurrentlyLiked) {
          _likedPostIds.add(postId);
        } else {
          _likedPostIds.remove(postId);
        }
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error updating like: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _togglePopularFavorite(int index) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null || index >= _postIds.length) return;

    final postId = _postIds[index];
    final isCurrentlyLiked = _likedPostIds.contains(postId);

    // Optimistically update UI
    setState(() {
      if (isCurrentlyLiked) {
        _likedPostIds.remove(postId);
      } else {
        _likedPostIds.add(postId);
      }
    });

    try {
      // Update Firestore
      await _postService.toggleLikePost(user.uid, postId, isCurrentlyLiked);
    } catch (e) {
      // Revert on error
      setState(() {
        if (isCurrentlyLiked) {
          _likedPostIds.add(postId);
        } else {
          _likedPostIds.remove(postId);
        }
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error updating like: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
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
            : _popularPosts.isEmpty
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
                      // Only show "Today's events" section if there are events today
                      if (_posts.isNotEmpty) ...[
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
                          isFavorite: _likedPostIds.contains(
                            _showcasePostIds.isNotEmpty
                                ? _showcasePostIds[_currentIndex]
                                : '',
                          ),
                          onFavoriteToggle: () =>
                              _toggleFavorite(_currentIndex),
                          onPrevious: _showPrevious,
                          onNext: _showNext,
                          imageHeight: _imageHeight,
                        ),
                        const SizedBox(height: 12),
                        PostShowcaseIndicator(
                          count: _posts.length,
                          activeIndex: _currentIndex,
                        ),
                        const SizedBox(height: 12),
                      ],
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
                            isFavorite: _likedPostIds.contains(
                              entry.key < _postIds.length
                                  ? _postIds[entry.key]
                                  : '',
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
