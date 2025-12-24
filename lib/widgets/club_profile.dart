import 'package:flutter/material.dart';
import '../services/post_service.dart';
import '../models/post_data.dart';
import 'package:intl/intl.dart';
import 'post.dart';

class ClubProfile extends StatefulWidget {
  final String clubId;

  const ClubProfile({super.key, required this.clubId});

  @override
  State<ClubProfile> createState() => _ClubProfileState();
}

class _ClubProfileState extends State<ClubProfile> {
  final PostService _postService = PostService();
  dynamic _club;
  List<PostCardData> _events = [];
  List<Map<String, dynamic>> _clubPostsRaw = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchClub();
  }

  Future<void> _fetchClub() async {
    try {
      final club = await _postService.getClub(widget.clubId);

      // Fetch approved posts then filter for this club
      final allPosts = await _postService.getAllPosts(state: 'approved');
      final clubPosts = allPosts.where((m) {
        final post = m['post'];
        try {
          return post.clubId == widget.clubId;
        } catch (_) {
          return false;
        }
      }).toList();

      final events = clubPosts.map<PostCardData>((m) {
        final post = m['post'];

        // Prefer the human-readable placeholder; fall back to the location URL
        final location = (post.eventPlaceholder).isNotEmpty
            ? post.eventPlaceholder
            : post.eventLocationURL;

        // Format date and time for display (brief placeholder; UI will use saved format)
        final DateTime eventDt = post.eventDate;
        final dateDisplay = DateFormat(
          'yyyy-MM-dd HH:mm',
        ).format(eventDt.toLocal());

        return PostCardData(
          communityName: club.name,
          communityAvatarUrl: club.photoUrl,
          location: location,
          caption: post.postCaption,
          dateDisplay: dateDisplay,
          imageUrl: post.photoURL,
          clubId: widget.clubId,
        );
      }).toList();

      setState(() {
        _club = club;
        _events = events;
        _clubPostsRaw = clubPosts;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      // Handle error
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF282323),
      appBar: AppBar(
        backgroundColor: Color(0xFF1B1B1B),
        toolbarHeight: 40,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (_club != null && _club.photoUrl.isNotEmpty)
                    Stack(
                      children: [
                        Image.network(
                          _club.photoUrl,
                          height: MediaQuery.of(context).size.height / 3,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        ),
                        Positioned(
                          bottom: 0,
                          left: 0,
                          right: 0,
                          child: Container(
                            height: 50,
                            color: Colors.black.withOpacity(0.5),
                            child: Center(
                              child: Text(
                                _club.name,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 24,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  const SizedBox(height: 4),
                  Padding(
                    padding: const EdgeInsets.only(left: 10),
                    child: const Text(
                      'Bio',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.left,
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.fromLTRB(10, 4, 10, 4),
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1B1B1B),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      _club?.clubBio ?? 'No bio available',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 18,
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Padding(
                    padding: const EdgeInsets.only(left: 10),
                    child: const Text(
                      'Our Events',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.left,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Column(
                      children: _clubPostsRaw.isEmpty
                          ? [
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF1B1B1B),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: const Text(
                                  'No upcoming events',
                                  style: TextStyle(color: Colors.white70),
                                ),
                              ),
                            ]
                          : _clubPostsRaw.asMap().entries.map((
                              MapEntry<int, Map<String, dynamic>> entry,
                            ) {
                              final post = entry.value['post'] as dynamic;
                              final bool isLast =
                                  entry.key == _clubPostsRaw.length - 1;

                              // Check if the event is outdated by more than 2 hours
                              final now = DateTime.now();
                              final timeDifference = now.difference(
                                post.eventDate as DateTime,
                              );
                              final isOutdated = timeDifference.inHours >= 2;

                              final postCardData = PostCardData(
                                communityName: _club?.name ?? '',
                                communityAvatarUrl: _club?.photoUrl ?? '',
                                location:
                                    post.eventPlaceholder ??
                                    post.eventLocationURL ??
                                    '',
                                caption: post.postCaption ?? '',
                                dateDisplay: DateFormat(
                                  'MMM d, yyyy · h:mm a',
                                ).format(post.eventDate as DateTime),
                                imageUrl: post.photoURL ?? '',
                                clubId: post.clubId ?? widget.clubId,
                              );

                              return Padding(
                                padding: EdgeInsets.only(
                                  bottom: isLast ? 0 : 12,
                                ),
                                child: Opacity(
                                  opacity: isOutdated ? 0.5 : 1.0,
                                  child: PostCard(data: postCardData),
                                ),
                              );
                            }).toList(),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
