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

class _ProfilePageState extends State<ProfilePage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final PostService _postService = PostService();
  String? _clubKey;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
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
            _isLoading = false;
          });
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF282323),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.white))
          : const Center(
              child: Text(
                'Pasdasdasda Page',
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
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
                  backgroundColor: const Color(0xFF807373),
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
              backgroundColor: const Color(0xFF807373),
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
    );
  }
}
