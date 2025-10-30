import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/post_data.dart';
import '../services/post_service.dart';
import '../widgets/post.dart';

class SavedPage extends StatefulWidget {
  const SavedPage({super.key});

  @override
  State<SavedPage> createState() => _SavedPageState();
}

class _SavedPageState extends State<SavedPage> {
  final PostService _postService = PostService();
  List<Map<String, dynamic>> _likedPosts = [];
  Set<String> _likedPostIds = {};
  Set<String> _followedClubIds = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchLikedPosts();
  }

  Future<void> _fetchLikedPosts() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        setState(() {
          _isLoading = false;
        });
        return;
      }

      // Get user's liked post IDs
      final likedPostIds = await _postService.getUserLikedPosts(user.uid);

      // Get user's followed clubs
      final followedClubs = await _postService.getUserFollowedClubs(user.uid);

      if (likedPostIds.isEmpty) {
        setState(() {
          _isLoading = false;
          _likedPostIds = {};
          _likedPosts = [];
        });
        return;
      }

      // Fetch full post data for each liked post
      List<Map<String, dynamic>> likedPostsData = [];

      for (String postId in likedPostIds) {
        try {
          final postData = await _postService.getPostAndClub(postId);
          final Post post = postData['post'];
          final Club club = postData['club'];

          likedPostsData.add({'postId': postId, 'post': post, 'club': club});
        } catch (e) {
          print('Error fetching post $postId: $e');
          // Continue with other posts even if one fails
        }
      }

      setState(() {
        _likedPosts = likedPostsData;
        _likedPostIds = Set.from(likedPostIds);
        _followedClubIds = Set.from(followedClubs);
        _isLoading = false;
      });
    } catch (e) {
      print('Error fetching liked posts: $e');
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading saved posts: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _toggleLike(String postId) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final isCurrentlyLiked = _likedPostIds.contains(postId);

    // Optimistically update UI
    setState(() {
      if (isCurrentlyLiked) {
        _likedPostIds.remove(postId);
        _likedPosts.removeWhere((post) => post['postId'] == postId);
      }
    });

    try {
      await _postService.toggleLikePost(user.uid, postId, isCurrentlyLiked);
    } catch (e) {
      // Revert on error
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error updating like: $e'),
            backgroundColor: Colors.red,
          ),
        );
        // Refresh to get correct state
        _fetchLikedPosts();
      }
    }
  }

  Future<void> _toggleFollow(String clubId) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final isCurrentlyFollowing = _followedClubIds.contains(clubId);

    // Optimistically update UI
    setState(() {
      if (isCurrentlyFollowing) {
        _followedClubIds.remove(clubId);
      } else {
        _followedClubIds.add(clubId);
      }
    });

    try {
      await _postService.toggleFollowClub(
        user.uid,
        clubId,
        isCurrentlyFollowing,
      );
    } catch (e) {
      // Revert on error
      setState(() {
        if (isCurrentlyFollowing) {
          _followedClubIds.add(clubId);
        } else {
          _followedClubIds.remove(clubId);
        }
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error updating follow: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
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
            : _likedPosts.isEmpty
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.favorite_border,
                      size: 64,
                      color: Colors.white54,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'No saved events yet',
                      style: TextStyle(
                        fontSize: 20,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Like posts to save them here',
                      style: TextStyle(fontSize: 14, color: Colors.white54),
                    ),
                    const SizedBox(height: 24),
                    TextButton.icon(
                      onPressed: _fetchLikedPosts,
                      icon: const Icon(Icons.refresh, color: Colors.white),
                      label: const Text(
                        'Refresh',
                        style: TextStyle(color: Colors.white),
                      ),
                      style: TextButton.styleFrom(
                        backgroundColor: const Color(0xFF807373),
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
                onRefresh: _fetchLikedPosts,
                color: Colors.blueAccent,
                backgroundColor: const Color(0xFF282323),
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.only(left: 10, right: 10, top: 1),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'My events',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 12),
                      ..._likedPosts.asMap().entries.map((
                        MapEntry<int, Map<String, dynamic>> entry,
                      ) {
                        final Post post = entry.value['post'];
                        final Club club = entry.value['club'];
                        final String postId = entry.value['postId'];
                        final bool isLast = entry.key == _likedPosts.length - 1;

                        // Check if the event is outdated by more than 2 hours
                        final now = DateTime.now();
                        final timeDifference = now.difference(post.eventDate);
                        final isOutdated = timeDifference.inHours >= 2;

                        final postCardData = PostCardData(
                          communityName: club.name,
                          communityAvatarUrl: club.photoUrl,
                          location: post.eventPlaceholder,
                          caption: post.postCaption,
                          dateDisplay: DateFormat(
                            'MMM d, yyyy · h:mm a',
                          ).format(post.eventDate),
                          imageUrl: post.photoURL,
                          clubId: post.clubId,
                        );

                        return Padding(
                          padding: EdgeInsets.only(bottom: isLast ? 0 : 12),
                          child: Opacity(
                            opacity: isOutdated ? 0.5 : 1.0,
                            child: PostCard(
                              data: postCardData,
                              isFavorite: true,
                              onFavoriteToggle: () => _toggleLike(postId),
                              isFollowing: _followedClubIds.contains(
                                post.clubId,
                              ),
                              onFollowToggle: () => _toggleFollow(post.clubId),
                            ),
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
