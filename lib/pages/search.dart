import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../widgets/club_search.dart';
import '../widgets/user_search.dart';
import '../widgets/club_profile.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  String? _userClubRank;
  String? _currentUserClubKey;
  final TextEditingController _searchController = TextEditingController();
  List<ClubSearchData> _allClubs = [];
  List<ClubSearchData> _clubSearchResults = [];
  List<UserSearchData> _allUsers = [];
  List<UserSearchData> _userSearchResults = [];
  bool _isSearching = false;
  bool _isLoadingUsers = false;
  bool _usersLoaded = false;
  String _searchType = 'club'; // 'club' or 'user'
  Set<String> _followedClubs = {};

  @override
  void initState() {
    super.initState();
    _fetchUserClubRank();
    _loadAllClubs();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchUserClubRank() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      if (userDoc.exists) {
        final data = userDoc.data()!;
        setState(() {
          _userClubRank = data['club_rank'] as String?;
          _currentUserClubKey = data['club_key'] as String?;
          _followedClubs = Set.from(data['following_clubs'] ?? []);
        });
      }
    }
  }

  Future<void> _toggleFollowClub(String clubId) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    setState(() {
      if (_followedClubs.contains(clubId)) {
        _followedClubs.remove(clubId);
      } else {
        _followedClubs.add(clubId);
      }
    });

    try {
      await FirebaseFirestore.instance.collection('users').doc(user.uid).update(
        {'following_clubs': _followedClubs.toList()},
      );
    } catch (e) {
      // Revert on error
      setState(() {
        if (_followedClubs.contains(clubId)) {
          _followedClubs.remove(clubId);
        } else {
          _followedClubs.add(clubId);
        }
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update follow status: $e')),
        );
      }
    }
  }

  Future<void> _loadAllUsers() async {
    setState(() {
      _isLoadingUsers = true;
    });
    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('users')
          .limit(50) // Load up to 50 users by default
          .get();

      final results = querySnapshot.docs.map((doc) {
        final data = doc.data();
        final userName = data['name'] ?? '';
        return UserSearchData(
          userName: userName,
          userAvatarUrl: data['profile_photo_URL'] ?? '',
          userId: doc.id,
          clubKey: data['club_key'],
          clubRank: data['club_rank'],
        );
      }).toList();

      setState(() {
        _allUsers = results;
        _userSearchResults = results;
        _isLoadingUsers = false;
      });
    } catch (e) {
      print('Error loading users: $e');
      setState(() {
        _isLoadingUsers = false;
      });
    }
  }

  Future<void> _loadAllClubs() async {
    setState(() {
      _isSearching = true;
    });

    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('clubs')
          .limit(50) // Load up to 50 clubs by default
          .get();

      final results = querySnapshot.docs.map((doc) {
        final data = doc.data();
        final clubName = data['club_name'] ?? '';
        return ClubSearchData(
          clubName: clubName,
          clubAvatarUrl: data['club_photo_URL'] ?? '',
          clubId: doc.id,
          clubBio: data['club_bio'] ?? '',
        );
      }).toList();

      setState(() {
        _allClubs = results;
        _clubSearchResults = results;
        _isSearching = false;
      });
    } catch (e) {
      print('Error loading clubs: $e');
      setState(() {
        _isSearching = false;
      });
    }
  }

  void _onSearchChanged() {
    final query = _searchController.text.trim().toLowerCase();
    if (query.isNotEmpty) {
      if (_searchType == 'club') {
        // Filter from all clubs based on search query
        final filteredResults = _allClubs
            .where((club) => club.clubName.toLowerCase().contains(query))
            .toList();
        setState(() {
          _clubSearchResults = filteredResults;
        });
      } else {
        // Filter from all users based on search query
        final filteredResults = _allUsers
            .where((user) => user.userName.toLowerCase().contains(query))
            .toList();
        setState(() {
          _userSearchResults = filteredResults;
        });
      }
    } else {
      // Show all items when search is cleared
      if (_searchType == 'club') {
        setState(() {
          _clubSearchResults = _allClubs;
        });
      } else {
        setState(() {
          _userSearchResults = _allUsers;
        });
      }
    }
  }

  bool get _shouldShowFilter {
    return _userClubRank == 'President' || _userClubRank == 'Co-President';
  }

  List<dynamic> _getCurrentSearchResults() {
    return _searchType == 'club' ? _clubSearchResults : _userSearchResults;
  }

  Future<void> _handleMenuAction(String action, String userId) async {
    try {
      if (action == 'grant') {
        if (_currentUserClubKey == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'You must be a member of a club to grant membership',
              ),
              backgroundColor: Colors.red,
            ),
          );
          return;
        }

        await FirebaseFirestore.instance.collection('users').doc(userId).update(
          {'club_key': _currentUserClubKey, 'club_rank': 'Board'},
        );

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Membership granted successfully'),
              backgroundColor: Colors.green,
            ),
          );
          // Reload users to reflect the change
          await _loadAllUsers();
        }
      } else if (action == 'evoke') {
        // TODO: Implement evoke membership
        print('Evoke membership for user: $userId');
      } else if (action == 'report') {
        // TODO: Implement report user
        print('Report user: $userId');
      } else if (action == 'block') {
        // TODO: Implement block user
        print('Block user: $userId');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF282323),
      body: SafeArea(
        child: Column(
          children: [
            // Search bar at the top
            Container(
              padding: const EdgeInsets.only(left: 20, right: 20, top: 1),
              color: Color(0xFF282323), // Match the background color
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Color(0xFF807373), // Search bar background color
                  hintText: 'Search...',
                  hintStyle: TextStyle(
                    color: Color(0xFFFFFFFF), // White placeholder text
                  ),
                  prefixIcon: Icon(
                    Icons.search,
                    color: Color(0xFFFFFFFF), // White search icon
                  ),
                  suffixIcon: _shouldShowFilter
                      ? PopupMenuButton<String>(
                          icon: Icon(
                            Icons.filter_list,
                            color: Color(0xFFFFFFFF), // White filter icon
                          ),
                          color: Color.fromARGB(
                            255,
                            72,
                            64,
                            64,
                          ), // Custom filter menu background
                          offset: Offset(
                            -20,
                            40,
                          ), // Position more to the left and below
                          onSelected: (String value) async {
                            if (value == 'user' && !_usersLoaded) {
                              await _loadAllUsers();
                              _usersLoaded = true;
                            }
                            setState(() {
                              _searchType = value;
                              _onSearchChanged(); // Trigger search update
                            });
                          },
                          itemBuilder: (BuildContext context) => [
                            PopupMenuItem<String>(
                              value: 'club',
                              child: Text(
                                'Club',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.normal,
                                ),
                              ),
                            ),
                            PopupMenuItem<String>(
                              value: 'user',
                              child: Text(
                                'User',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.normal,
                                ),
                              ),
                            ),
                          ],
                        )
                      : null,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24.0),
                    borderSide: BorderSide.none, // Remove border
                  ),
                  contentPadding: EdgeInsets.symmetric(vertical: 12.0),
                ),
                style: TextStyle(
                  color: Color(0xFFFFFFFF), // White text when typing
                ),
              ),
            ),
            // Search results
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: (_isSearching || _isLoadingUsers)
                    ? const Center(
                        child: CircularProgressIndicator(color: Colors.white),
                      )
                    : _getCurrentSearchResults().isEmpty
                    ? Center(
                        child: Text(
                          _searchType == 'club'
                              ? 'No clubs found'
                              : 'No users found',
                          style: TextStyle(color: Colors.white70, fontSize: 16),
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: _searchType == 'club'
                            ? _loadAllClubs
                            : _loadAllUsers,
                        color: Colors.blueAccent,
                        backgroundColor: const Color(0xFF282323),
                        child: ListView.builder(
                          itemCount: _getCurrentSearchResults().length,
                          itemBuilder: (context, index) {
                            if (_searchType == 'club') {
                              final clubData = _clubSearchResults[index];
                              return ClubSearchItem(
                                data: clubData,
                                isFollowing: _followedClubs.contains(
                                  clubData.clubId,
                                ),
                                onFollowToggle: () =>
                                    _toggleFollowClub(clubData.clubId),
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          ClubProfile(clubId: clubData.clubId),
                                    ),
                                  );
                                },
                              );
                            } else {
                              final userData = _userSearchResults[index];
                              final currentUser =
                                  FirebaseAuth.instance.currentUser;
                              final isCurrentUser =
                                  currentUser != null &&
                                  currentUser.uid == userData.userId;
                              return UserSearchItem(
                                data: userData,
                                onTap: () {
                                  // Handle user selection
                                  print('Selected user: ${userData.userName}');
                                },
                                isCurrentUser: isCurrentUser,
                                onMenuAction: _handleMenuAction,
                                currentUserClubKey: _currentUserClubKey,
                                currentUserRank: _userClubRank,
                                targetUserRank: userData.clubRank,
                              );
                            }
                          },
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
