import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'login.dart';
import '../services/post_service.dart';
import 'posting.dart';
import '../widgets/post.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage>
    with TickerProviderStateMixin {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final PostService _postService = PostService();
  String? _clubKey;
  String? _clubRank;
  bool _isLoading = true;
  List<String> _followingClubs = [];
  User? _user;
  late TabController _tabController;
  String? _clubName;

  void _onTabChanged() {
    setState(() {});
  }

  void _createTabController() {
    final newLength =
        _clubKey != null &&
            (_clubRank == 'President' || _clubRank == 'Co-President')
        ? 3
        : 2;
    // If controller already exists with same length, keep it.
    if (_tabController != null && _tabController.length == newLength) return;
    // Preserve current index if possible
    int currentIndex = 0;
    try {
      currentIndex = _tabController.index;
    } catch (_) {
      currentIndex = 0;
    }
    // Dispose old controller if present
    try {
      _tabController.removeListener(_onTabChanged);
      _tabController.dispose();
    } catch (_) {}

    _tabController = TabController(
      length: newLength,
      vsync: this,
      initialIndex: currentIndex < newLength ? currentIndex : 0,
    );
    _tabController.addListener(_onTabChanged);
  }

  @override
  void initState() {
    super.initState();
    _user = FirebaseAuth.instance.currentUser;
    // Start with 2 tabs by default; we'll recreate after fetching user data
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(_onTabChanged);
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final userDoc = await _firestore
            .collection('users')
            .doc(user.uid)
            .get();
        if (userDoc.exists) {
          final data = userDoc.data();
          final clubKey = data?['club_key'];
          setState(() {
            _clubKey = clubKey;
            _clubRank = data?['club_rank'] as String?;
            _followingClubs = List<String>.from(data?['following_clubs'] ?? []);
          });

          // Fetch club name if user has a club
          if (clubKey != null) {
            try {
              final club = await _postService.getClub(clubKey);
              setState(() {
                _clubName = club.name;
              });
            } catch (e) {
              print('Error fetching club name: $e');
              setState(() {
                _clubName = 'Club'; // Fallback
              });
            }
          }

          setState(() {
            _isLoading = false;
          });
          // Recreate tab controller to reflect whether the "Gönderilerim" tab should be available
          _createTabController();
        } else {
          setState(() {
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error fetching user data: $e')));
      }
    }
  }

  Future<void> _handlePostButtonPress() async {
    if (_clubKey == null) return;

    try {
      // Fetch the club name using the club key
      final club = await _postService.getClub(_clubKey!);

      if (mounted) {
        // Navigate to posting page
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) =>
                PostingPage(clubId: _clubKey!, clubName: club.name),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error fetching club info: $e')));
      }
    }
  }

  Future<void> _logout() async {
    try {
      // Sign out from Google Sign-In first
      await GoogleSignIn().signOut();
      // Then sign out from Firebase
      await FirebaseAuth.instance.signOut();

      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const LoginPage()),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error signing out: $e')));
      }
    }
  }

  Future<void> _refreshData() async {
    setState(() {
      _isLoading = true;
    });
    await _fetchUserData();
  }

  Future<void> _approvePost(String postId) async {
    try {
      await _firestore.collection('posts').doc(postId).update({
        'state': 'approved',
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Post approved successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error approving post: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _rejectPost(String postId) async {
    try {
      await _firestore.collection('posts').doc(postId).update({
        'state': 'rejected',
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Post rejected'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error rejecting post: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _deletePost(String postId) async {
    try {
      await _firestore.collection('posts').doc(postId).delete();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Post deleted'),
            backgroundColor: Colors.grey,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error deleting post: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    try {
      _tabController.removeListener(_onTabChanged);
    } catch (_) {}
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1B1B1B),
      body: (_isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.white))
          : Column(
              children: [
                RefreshIndicator(
                  onRefresh: _refreshData,
                  color: Colors.white,
                  backgroundColor: const Color(0xFF807373),
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.only(left: 10, right: 10, top: 1),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _user != null
                            ? Padding(
                                padding: const EdgeInsets.only(top: 16),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    CircleAvatar(
                                      radius: 70,
                                      backgroundImage: _user!.photoURL != null
                                          ? NetworkImage(
                                              _user!.photoURL!.replaceAll(
                                                RegExp(r'=s\d+'),
                                                '=s400',
                                              ),
                                            )
                                          : null,
                                      backgroundColor: Colors.grey,
                                      child: _user!.photoURL == null
                                          ? const Icon(
                                              Icons.person,
                                              color: Colors.white,
                                            )
                                          : null,
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: Text(
                                        'Welcome, \n${_user!.displayName ?? 'User'}',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 30,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                        maxLines: 2,
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            : const SizedBox.shrink(),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Builder(
                  builder: (context) {
                    final tabLabels =
                        _clubKey != null &&
                            (_clubRank == 'President' ||
                                _clubRank == 'Co-President')
                        ? ['Notifications', 'Clubs', 'Manage']
                        : ['Notifications', 'Clubs'];
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: List.generate(
                        tabLabels.length,
                        (i) => GestureDetector(
                          onTap: () {
                            if (i < _tabController.length)
                              _tabController.animateTo(i);
                          },
                          child: Container(
                            width:
                                MediaQuery.of(context).size.width /
                                tabLabels.length,
                            decoration: BoxDecoration(
                              color: _tabController.index == i
                                  ? const Color(0xFF282323)
                                  : Colors.transparent,
                              borderRadius: _tabController.index == i
                                  ? const BorderRadius.only(
                                      topLeft: Radius.circular(10),
                                      topRight: Radius.circular(10),
                                    )
                                  : BorderRadius.zero,
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            alignment: Alignment.center,
                            child: Text(
                              tabLabels[i],
                              style: TextStyle(
                                color: _tabController.index == i
                                    ? Colors.white
                                    : Colors.white70,
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
                Expanded(
                  child: Container(
                    color: const Color(0xFF282323),
                    child: TabBarView(
                      controller: _tabController,
                      children: [
                        const Center(
                          child: Text(
                            'Bildirimler',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                        const Center(
                          child: Text(
                            'Topluluklar',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                        if (_clubKey != null &&
                            (_clubRank == 'President' ||
                                _clubRank == 'Co-President'))
                          Padding(
                            padding: const EdgeInsets.fromLTRB(
                              3.0,
                              10.0,
                              3.0,
                              10.0,
                            ),
                            child: Column(
                              children: [
                                Container(
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF121212),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Theme(
                                    data: Theme.of(context).copyWith(
                                      dividerColor: Colors.transparent,
                                    ),
                                    child: ExpansionTile(
                                      tilePadding: const EdgeInsets.symmetric(
                                        horizontal: 13,
                                        vertical: 2,
                                      ),
                                      collapsedBackgroundColor:
                                          Colors.transparent,
                                      backgroundColor: Colors.transparent,
                                      iconColor: Colors.white,
                                      collapsedIconColor: Colors.white,
                                      childrenPadding:
                                          const EdgeInsets.fromLTRB(
                                            0.0,
                                            0.0,
                                            0.0,
                                            6.0,
                                          ),
                                      title: const Text(
                                        'Pending Posts',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      children: <Widget>[
                                        Padding(
                                          padding: const EdgeInsets.only(
                                            bottom: 4.0,
                                          ),
                                          child: StreamBuilder<QuerySnapshot>(
                                            stream: FirebaseFirestore.instance
                                                .collection('posts')
                                                .where(
                                                  'club_id',
                                                  isEqualTo: _clubKey,
                                                )
                                                .where(
                                                  'state',
                                                  isEqualTo: 'pending',
                                                )
                                                .snapshots(),
                                            builder: (context, snapshot) {
                                              if (snapshot.hasError) {
                                                return Center(
                                                  child: Text(
                                                    'Error loading posts: ${snapshot.error}',
                                                    style: const TextStyle(
                                                      color: Colors.white70,
                                                    ),
                                                  ),
                                                );
                                              }
                                              if (snapshot.connectionState ==
                                                  ConnectionState.waiting) {
                                                return const Center(
                                                  child:
                                                      CircularProgressIndicator(
                                                        color: Colors.white,
                                                      ),
                                                );
                                              }
                                              if (!snapshot.hasData ||
                                                  snapshot.data!.docs.isEmpty) {
                                                return const Center(
                                                  child: Text(
                                                    'No pending posts',
                                                    style: TextStyle(
                                                      color: Colors.white70,
                                                    ),
                                                  ),
                                                );
                                              }

                                              final docs = snapshot.data!.docs;

                                              return ListView.separated(
                                                padding: const EdgeInsets.only(
                                                  top: 8,
                                                  bottom: 4,
                                                ),
                                                shrinkWrap: true,
                                                physics:
                                                    const NeverScrollableScrollPhysics(),
                                                itemCount: docs.length,
                                                separatorBuilder: (_, __) =>
                                                    const SizedBox(height: 8),
                                                itemBuilder: (context, index) {
                                                  final data =
                                                      docs[index].data()
                                                          as Map<
                                                            String,
                                                            dynamic
                                                          >;
                                                  final photoUrl =
                                                      data['photo_URL'] ?? '';
                                                  final caption =
                                                      data['post_caption'] ??
                                                      '';
                                                  final location =
                                                      data['event_placeholder'] ??
                                                      '';
                                                  final Timestamp ts =
                                                      data['event_date']
                                                          as Timestamp;
                                                  final dateDisplay =
                                                      DateTime.fromMillisecondsSinceEpoch(
                                                        ts.millisecondsSinceEpoch,
                                                      );

                                                  final postData = PostCardData(
                                                    communityName:
                                                        _clubName ?? 'Club',
                                                    communityAvatarUrl: '',
                                                    location: location,
                                                    caption: caption,
                                                    dateDisplay:
                                                        '${dateDisplay.toLocal()}',
                                                    imageUrl: photoUrl,
                                                    clubId:
                                                        data['club_id'] ?? '',
                                                  );

                                                  final postId = docs[index].id;

                                                  return Padding(
                                                    padding:
                                                        const EdgeInsets.symmetric(
                                                          horizontal: 12.0,
                                                          vertical: 6.0,
                                                        ),
                                                    child: Column(
                                                      children: [
                                                        PostCard(
                                                          data: postData,
                                                        ),
                                                        const SizedBox(
                                                          height: 8,
                                                        ),
                                                        Row(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .spaceEvenly,
                                                          children: [
                                                            Expanded(
                                                              child: ElevatedButton.icon(
                                                                onPressed: () =>
                                                                    _approvePost(
                                                                      postId,
                                                                    ),
                                                                icon: const Icon(
                                                                  Icons.check,
                                                                  color: Colors
                                                                      .white,
                                                                  size: 18,
                                                                ),
                                                                label: const Text(
                                                                  'Approve',
                                                                  style: TextStyle(
                                                                    color: Colors
                                                                        .white,
                                                                  ),
                                                                ),
                                                                style: ElevatedButton.styleFrom(
                                                                  backgroundColor:
                                                                      Colors
                                                                          .green,
                                                                  padding:
                                                                      const EdgeInsets.symmetric(
                                                                        vertical:
                                                                            8,
                                                                      ),
                                                                ),
                                                              ),
                                                            ),
                                                            const SizedBox(
                                                              width: 8,
                                                            ),
                                                            Expanded(
                                                              child: ElevatedButton.icon(
                                                                onPressed: () =>
                                                                    _rejectPost(
                                                                      postId,
                                                                    ),
                                                                icon: const Icon(
                                                                  Icons.close,
                                                                  color: Colors
                                                                      .white,
                                                                  size: 18,
                                                                ),
                                                                label: const Text(
                                                                  'Reject',
                                                                  style: TextStyle(
                                                                    color: Colors
                                                                        .white,
                                                                  ),
                                                                ),
                                                                style: ElevatedButton.styleFrom(
                                                                  backgroundColor:
                                                                      Colors
                                                                          .orange,
                                                                  padding:
                                                                      const EdgeInsets.symmetric(
                                                                        vertical:
                                                                            8,
                                                                      ),
                                                                ),
                                                              ),
                                                            ),
                                                            const SizedBox(
                                                              width: 8,
                                                            ),
                                                            IconButton(
                                                              onPressed: () =>
                                                                  _deletePost(
                                                                    postId,
                                                                  ),
                                                              icon: const Icon(
                                                                Icons.delete,
                                                                color:
                                                                    Colors.red,
                                                              ),
                                                              tooltip:
                                                                  'Delete post',
                                                            ),
                                                          ],
                                                        ),
                                                      ],
                                                    ),
                                                  );
                                                },
                                              );
                                            },
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 10),
                                Container(
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF121212),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Theme(
                                    data: Theme.of(context).copyWith(
                                      dividerColor: Colors.transparent,
                                    ),
                                    child: ExpansionTile(
                                      tilePadding: const EdgeInsets.symmetric(
                                        horizontal: 13,
                                        vertical: 2,
                                      ),
                                      collapsedBackgroundColor:
                                          Colors.transparent,
                                      backgroundColor: Colors.transparent,
                                      iconColor: Colors.white,
                                      collapsedIconColor: Colors.white,
                                      childrenPadding:
                                          const EdgeInsets.fromLTRB(
                                            0.0,
                                            0.0,
                                            0.0,
                                            6.0,
                                          ),
                                      title: const Text(
                                        'Members',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      children: <Widget>[
                                        Padding(
                                          padding: const EdgeInsets.only(
                                            bottom: 4.0,
                                          ),
                                          child: StreamBuilder<QuerySnapshot>(
                                            stream: FirebaseFirestore.instance
                                                .collection('users')
                                                .where(
                                                  'club_key',
                                                  isEqualTo: _clubKey,
                                                )
                                                .snapshots(),
                                            builder: (context, snapshot) {
                                              if (snapshot.hasError) {
                                                return Center(
                                                  child: Text(
                                                    'Error loading members: ${snapshot.error}',
                                                    style: const TextStyle(
                                                      color: Colors.white70,
                                                    ),
                                                  ),
                                                );
                                              }
                                              if (snapshot.connectionState ==
                                                  ConnectionState.waiting) {
                                                return const Center(
                                                  child:
                                                      CircularProgressIndicator(
                                                        color: Colors.white,
                                                      ),
                                                );
                                              }
                                              if (!snapshot.hasData ||
                                                  snapshot.data!.docs.isEmpty) {
                                                return const Center(
                                                  child: Padding(
                                                    padding:
                                                        EdgeInsets.symmetric(
                                                          vertical: 16.0,
                                                        ),
                                                    child: Text(
                                                      'No members found',
                                                      style: TextStyle(
                                                        color: Colors.white70,
                                                      ),
                                                    ),
                                                  ),
                                                );
                                              }

                                              final docs = snapshot
                                                  .data!
                                                  .docs
                                                  .reversed
                                                  .toList();

                                              return ListView.builder(
                                                padding: const EdgeInsets.only(
                                                  top: 8,
                                                  bottom: 4,
                                                ),
                                                shrinkWrap: true,
                                                physics:
                                                    const NeverScrollableScrollPhysics(),
                                                itemCount: docs.length,
                                                itemBuilder: (context, index) {
                                                  final data =
                                                      docs[index].data()
                                                          as Map<
                                                            String,
                                                            dynamic
                                                          >;
                                                  final userName =
                                                      data['name'] ?? 'Unknown';
                                                  final clubRank =
                                                      data['club_rank'] ??
                                                      'Member';
                                                  final profilePhotoUrl =
                                                      data['profile_photo_URL'] ??
                                                      '';

                                                  return Container(
                                                    padding:
                                                        const EdgeInsets.symmetric(
                                                          horizontal: 16.0,
                                                          vertical: 12.0,
                                                        ),
                                                    child: Row(
                                                      children: [
                                                        CircleAvatar(
                                                          radius: 25,
                                                          backgroundImage:
                                                              profilePhotoUrl
                                                                  .isNotEmpty
                                                              ? NetworkImage(
                                                                  profilePhotoUrl,
                                                                )
                                                              : null,
                                                          backgroundColor:
                                                              Colors.grey,
                                                          child:
                                                              profilePhotoUrl
                                                                  .isEmpty
                                                              ? const Icon(
                                                                  Icons.person,
                                                                  color: Colors
                                                                      .white,
                                                                  size: 25,
                                                                )
                                                              : null,
                                                        ),
                                                        const SizedBox(
                                                          width: 16,
                                                        ),
                                                        Expanded(
                                                          child: Column(
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .start,
                                                            children: [
                                                              Text(
                                                                userName,
                                                                style: const TextStyle(
                                                                  color: Colors
                                                                      .white,
                                                                  fontSize: 16,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w500,
                                                                ),
                                                              ),
                                                              const SizedBox(
                                                                height: 4,
                                                              ),
                                                              Text(
                                                                clubRank,
                                                                style: const TextStyle(
                                                                  color: Colors
                                                                      .white70,
                                                                  fontSize: 14,
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  );
                                                },
                                              );
                                            },
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            )),
      floatingActionButton: _isLoading
          ? null
          : _clubKey != null
          ? Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                FloatingActionButton.extended(
                  onPressed: _handlePostButtonPress,
                  backgroundColor: const Color(0xFF807373),
                  heroTag: 'postButton',
                  elevation: 0,
                  icon: const Icon(Icons.add, color: Colors.white),
                  label: const Text(
                    'Post',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                FloatingActionButton.extended(
                  onPressed: _logout,
                  backgroundColor: const Color.fromARGB(255, 72, 64, 64),
                  heroTag: 'logoutButton',
                  elevation: 0,
                  icon: const Icon(Icons.logout, color: Colors.white),
                  label: const Text(
                    'Log out',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            )
          : FloatingActionButton.extended(
              onPressed: _logout,
              backgroundColor: const Color.fromARGB(255, 72, 64, 64),
              elevation: 0,
              icon: const Icon(Icons.logout, color: Colors.white),
              label: const Text(
                'Log out',
                style: TextStyle(color: Colors.white),
              ),
            ),
    );
  }
}
