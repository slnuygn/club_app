import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'login.dart';
import '../services/post_service.dart';
import 'posting.dart';

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
  bool _isLoading = true;
  List<String> _followingClubs = [];
  User? _user;
  late TabController _tabController;

  void _onTabChanged() {
    setState(() {});
  }

  void _createTabController() {
    final newLength = _clubKey != null ? 3 : 2;
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
          setState(() {
            _clubKey = data?['club_key'];
            _followingClubs = List<String>.from(data?['following_clubs'] ?? []);
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
                                    Text(
                                      'Welcome, \n${_user!.displayName ?? 'User'}',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 30,
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
                    final tabLabels = _clubKey != null
                        ? ['Notifications', 'Clubs', 'Posts']
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
                        if (_clubKey != null)
                          const Center(
                            child: Text(
                              'Gönderiler',
                              style: TextStyle(color: Colors.white),
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
