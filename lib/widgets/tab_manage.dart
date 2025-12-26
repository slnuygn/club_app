import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';
import 'post.dart';
import 'package:intl/intl.dart';

class TabManage extends StatefulWidget {
  final String clubId;
  const TabManage({Key? key, required this.clubId}) : super(key: key);

  @override
  State<TabManage> createState() => _TabManageState();
}

class _TabManageState extends State<TabManage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  User? _user;
  String? _currentUserClubRank;
  final TextEditingController _clubNameController = TextEditingController();
  final TextEditingController _clubDescriptionController =
      TextEditingController();
  final TextEditingController _clubPhotoUrlController = TextEditingController();
  File? _selectedImage;
  Map<String, dynamic>? _clubData;

  @override
  void initState() {
    super.initState();
    _user = FirebaseAuth.instance.currentUser;
    _loadCurrentUserRank();
    _loadClubData();
  }

  @override
  void dispose() {
    _clubNameController.dispose();
    _clubDescriptionController.dispose();
    _clubPhotoUrlController.dispose();
    super.dispose();
  }

  Future<void> _loadCurrentUserRank() async {
    try {
      if (_user == null) return;
      final doc = await _firestore.collection('users').doc(_user!.uid).get();
      if (doc.exists) {
        final data = doc.data();
        setState(() {
          _currentUserClubRank = data?['club_rank'] as String?;
        });
      }
    } catch (_) {}
  }

  Future<void> _loadClubData() async {
    try {
      final doc = await _firestore.collection('clubs').doc(widget.clubId).get();
      if (doc.exists) {
        final data = doc.data();
        setState(() {
          _clubData = data;
          _clubPhotoUrlController.text =
              data?['club_photo_URL'] as String? ?? '';
        });
      }
    } catch (_) {}
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

  Future<String?> _uploadImage(File image) async {
    try {
      final ref = _storage.ref().child('club_photos/${widget.clubId}.jpg');
      await ref.putFile(image);
      return await ref.getDownloadURL();
    } catch (e) {
      return null;
    }
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

  Future<void> _evokeCoPresidency(String memberId) async {
    try {
      await _firestore.collection('users').doc(memberId).update({
        'club_rank': 'Board',
        'notifications': FieldValue.arrayUnion([
          'Your Co-Presidency in ${_clubData?['club_name'] ?? 'Unknown Club'} was revoked. You are now a Board member.',
        ]),
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Co-Presidency revoked. Member set to Board'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error revoking co-presidency: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _evokeMembership(String memberId) async {
    try {
      await _firestore.collection('users').doc(memberId).update({
        'club_rank': '',
        'club_key': '',
        'notifications': FieldValue.arrayUnion([
          'Your membership has been revoked from ${_clubData?['club_name'] ?? 'Unknown Club'}.',
        ]),
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Membership revoked. Member removed from club'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error revoking membership: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _promoteToCoPresident(String memberId) async {
    try {
      await _firestore.collection('users').doc(memberId).update({
        'club_rank': 'Co-President',
        'notifications': FieldValue.arrayUnion([
          'Congratulations! You have been promoted to Co-President in ${_clubData?['club_name'] ?? 'Unknown Club'}.',
        ]),
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Member promoted to Co-President'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error promoting member: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _saveClubChanges() async {
    if (_user == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('You must be logged in to save changes'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }
    try {
      String? photoUrl = _clubPhotoUrlController.text.trim();
      if (_selectedImage != null) {
        photoUrl = await _uploadImage(_selectedImage!);
        if (photoUrl == null) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Error uploading image'),
                backgroundColor: Colors.red,
              ),
            );
          }
          return;
        }
      }

      Map<String, dynamic> updateData = {};

      if (_clubNameController.text.trim().isNotEmpty) {
        updateData['club_name'] = _clubNameController.text.trim();
      }
      if (_clubDescriptionController.text.trim().isNotEmpty) {
        updateData['club_bio'] = _clubDescriptionController.text.trim();
      }
      updateData['club_photo_URL'] = photoUrl;

      if (updateData.isNotEmpty) {
        await _firestore
            .collection('clubs')
            .doc(widget.clubId)
            .update(updateData);
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Club updated successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        setState(() {
          _selectedImage = null;
        });
        _loadClubData(); // Reload to update hints
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error updating club: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(3.0, 10.0, 3.0, 10.0),
      child: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFF121212),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Theme(
                data: Theme.of(
                  context,
                ).copyWith(dividerColor: Colors.transparent),
                child: ExpansionTile(
                  tilePadding: const EdgeInsets.symmetric(
                    horizontal: 13,
                    vertical: 2,
                  ),
                  collapsedBackgroundColor: Colors.transparent,
                  backgroundColor: Colors.transparent,
                  iconColor: Colors.white,
                  collapsedIconColor: Colors.white,
                  childrenPadding: const EdgeInsets.fromLTRB(
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
                      padding: const EdgeInsets.only(bottom: 4.0),
                      child: StreamBuilder<QuerySnapshot>(
                        stream: FirebaseFirestore.instance
                            .collection('posts')
                            .where('club_id', isEqualTo: widget.clubId)
                            .where('state', isEqualTo: 'pending')
                            .snapshots(),
                        builder: (context, snapshot) {
                          if (snapshot.hasError) {
                            return const Center(
                              child: Text(
                                'Error loading posts',
                                style: TextStyle(color: Colors.white),
                              ),
                            );
                          }
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const Center(
                              child: CircularProgressIndicator(
                                color: Colors.white,
                              ),
                            );
                          }
                          if (!snapshot.hasData ||
                              snapshot.data!.docs.isEmpty) {
                            return const Center(
                              child: Padding(
                                padding: EdgeInsets.symmetric(vertical: 16),
                                child: Text(
                                  'No pending posts',
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                            );
                          }

                          final docs = snapshot.data!.docs;

                          return ListView.separated(
                            padding: const EdgeInsets.only(bottom: 4),
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: docs.length,
                            separatorBuilder: (_, __) =>
                                const SizedBox(height: 8),
                            itemBuilder: (context, index) {
                              final doc = docs[index];
                              final data =
                                  doc.data() as Map<String, dynamic>? ?? {};

                              // Get club data
                              final clubId = data['club_id'] as String? ?? '';

                              return FutureBuilder<DocumentSnapshot>(
                                future: FirebaseFirestore.instance
                                    .collection('clubs')
                                    .doc(clubId)
                                    .get(),
                                builder: (context, clubSnapshot) {
                                  if (!clubSnapshot.hasData) {
                                    return const SizedBox(
                                      height: 100,
                                      child: Center(
                                        child: CircularProgressIndicator(
                                          color: Colors.white,
                                        ),
                                      ),
                                    );
                                  }

                                  final clubData =
                                      clubSnapshot.data!.data()
                                          as Map<String, dynamic>? ??
                                      {};

                                  // Prepare post data for PostCard
                                  final eventDate =
                                      data['event_date'] as Timestamp?;
                                  final dateDisplay = eventDate != null
                                      ? DateFormat(
                                          'MMM d, yyyy • h:mm a',
                                        ).format(eventDate.toDate())
                                      : '';

                                  final postCardData = PostCardData(
                                    communityName:
                                        clubData['club_name'] as String? ?? '',
                                    communityAvatarUrl:
                                        clubData['club_photo_URL'] as String? ??
                                        '',
                                    location:
                                        data['event_placeholder'] as String? ??
                                        '',
                                    caption:
                                        data['post_caption'] as String? ?? '',
                                    dateDisplay: dateDisplay,
                                    imageUrl:
                                        data['photo_URL'] as String? ?? '',
                                    clubId: clubId,
                                  );

                                  return Stack(
                                    children: [
                                      Transform.scale(
                                        scale: 0.95,
                                        alignment: Alignment.topCenter,
                                        child: PostCard(
                                          data: postCardData,
                                          isFavorite: false,
                                          isFollowing: false,
                                        ),
                                      ),
                                      Positioned(
                                        bottom: 8,
                                        right: 8,
                                        child: Container(
                                          decoration: BoxDecoration(
                                            color: Colors.black87,
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                          ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              IconButton(
                                                onPressed: () =>
                                                    _approvePost(doc.id),
                                                icon: const Icon(
                                                  Icons.check,
                                                  color: Colors.green,
                                                ),
                                                tooltip: 'Approve',
                                              ),
                                              IconButton(
                                                onPressed: () =>
                                                    _rejectPost(doc.id),
                                                icon: const Icon(
                                                  Icons.close,
                                                  color: Colors.orange,
                                                ),
                                                tooltip: 'Reject',
                                              ),
                                              IconButton(
                                                onPressed: () =>
                                                    _deletePost(doc.id),
                                                icon: const Icon(
                                                  Icons.delete,
                                                  color: Colors.red,
                                                ),
                                                tooltip: 'Delete',
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  );
                                },
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
                data: Theme.of(
                  context,
                ).copyWith(dividerColor: Colors.transparent),
                child: ExpansionTile(
                  tilePadding: const EdgeInsets.symmetric(
                    horizontal: 13,
                    vertical: 2,
                  ),
                  collapsedBackgroundColor: Colors.transparent,
                  backgroundColor: Colors.transparent,
                  iconColor: Colors.white,
                  collapsedIconColor: Colors.white,
                  childrenPadding: const EdgeInsets.fromLTRB(
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
                      padding: const EdgeInsets.only(bottom: 4.0),
                      child: StreamBuilder<QuerySnapshot>(
                        stream: FirebaseFirestore.instance
                            .collection('users')
                            .where('club_key', isEqualTo: widget.clubId)
                            .snapshots(),
                        builder: (context, snapshot) {
                          if (snapshot.hasError) {
                            return const Center(
                              child: Text(
                                'Error loading members',
                                style: TextStyle(color: Colors.white),
                              ),
                            );
                          }
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const Center(
                              child: CircularProgressIndicator(
                                color: Colors.white,
                              ),
                            );
                          }
                          if (!snapshot.hasData ||
                              snapshot.data!.docs.isEmpty) {
                            return const Center(
                              child: Padding(
                                padding: EdgeInsets.symmetric(vertical: 16),
                                child: Text(
                                  'No members found',
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                            );
                          }

                          final docs = snapshot.data!.docs.reversed.toList();

                          return ListView.builder(
                            padding: const EdgeInsets.only(bottom: 4),
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: docs.length,
                            itemBuilder: (context, index) {
                              final doc = docs[index];
                              final data =
                                  doc.data() as Map<String, dynamic>? ?? {};
                              final displayName =
                                  data['displayName'] as String?;
                              final email = data['email'] as String? ?? '';
                              final rank = data['club_rank'] as String? ?? '';
                              final memberId = doc.id;
                              final profilePhotoUrl =
                                  (data['profile_photo_URL'] ??
                                          data['photoURL'] ??
                                          '')
                                      as String;
                              final userName = displayName?.isNotEmpty == true
                                  ? displayName!
                                  : ((data['name'] as String?)?.isNotEmpty ==
                                            true
                                        ? data['name'] as String
                                        : 'Unknown');
                              final memberClubKey = data['club_key'] as String?;
                              final isCurrentUser =
                                  _user != null && memberId == _user!.uid;

                              return Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16.0,
                                  vertical: 12.0,
                                ),
                                child: Row(
                                  children: [
                                    CircleAvatar(
                                      radius: 25,
                                      backgroundImage:
                                          profilePhotoUrl.isNotEmpty
                                          ? NetworkImage(profilePhotoUrl)
                                          : null,
                                      backgroundColor: Colors.grey,
                                      child: profilePhotoUrl.isEmpty
                                          ? const Icon(
                                              Icons.person,
                                              color: Colors.white,
                                              size: 25,
                                            )
                                          : null,
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            userName,
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 16,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            rank,
                                            style: const TextStyle(
                                              color: Colors.white70,
                                              fontSize: 14,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    if (!isCurrentUser &&
                                        (_currentUserClubRank == 'President' ||
                                            ((_currentUserClubRank ==
                                                        'Co-President' ||
                                                    _currentUserClubRank ==
                                                        'Board') &&
                                                rank != 'President')))
                                      PopupMenuButton<String>(
                                        icon: const Icon(
                                          Icons.more_vert,
                                          color: Colors.white70,
                                          size: 20,
                                        ),
                                        color: const Color(0xFF1B1B1B),
                                        offset: const Offset(-20, 40),
                                        onSelected: (String value) async {
                                          if (!mounted) return;
                                          if (value == 'evoke_copres') {
                                            await _evokeCoPresidency(memberId);
                                            return;
                                          }
                                          if (value == 'promote_copres') {
                                            await _promoteToCoPresident(
                                              memberId,
                                            );
                                            return;
                                          }
                                          if (value == 'evoke_membership') {
                                            await _evokeMembership(memberId);
                                            return;
                                          }
                                          // default feedback for other actions
                                          ScaffoldMessenger.of(
                                            context,
                                          ).showSnackBar(
                                            SnackBar(
                                              content: Text(
                                                'Action: $value for $userName',
                                              ),
                                            ),
                                          );
                                        },
                                        itemBuilder: (BuildContext context) {
                                          final memberRank =
                                              data['club_rank'] as String? ??
                                              '';
                                          final List<PopupMenuEntry<String>>
                                          items = [];

                                          if (memberClubKey != null &&
                                              memberClubKey.isNotEmpty) {
                                            // If current user is President and member is Co-President,
                                            // allow evoking co-presidency (demote to Board)
                                            if (_currentUserClubRank ==
                                                    'President' &&
                                                memberRank == 'Co-President') {
                                              items.add(
                                                const PopupMenuItem<String>(
                                                  value: 'evoke_copres',
                                                  child: Text(
                                                    'Evoke Co-Presidency',
                                                    style: TextStyle(
                                                      color: Colors.white,
                                                    ),
                                                  ),
                                                ),
                                              );
                                              items.add(
                                                const PopupMenuItem<String>(
                                                  value: 'evoke_membership',
                                                  child: Text(
                                                    'Evoke Membership',
                                                    style: TextStyle(
                                                      color: Colors.white,
                                                    ),
                                                  ),
                                                ),
                                              );
                                            }

                                            if (_currentUserClubRank ==
                                                    'President' &&
                                                memberRank == 'Board') {
                                              items.add(
                                                const PopupMenuItem<String>(
                                                  value: 'promote_copres',
                                                  child: Text(
                                                    'Promote to Co-President',
                                                    style: TextStyle(
                                                      color: Colors.white,
                                                    ),
                                                  ),
                                                ),
                                              );
                                              items.add(
                                                const PopupMenuItem<String>(
                                                  value: 'evoke_membership',
                                                  child: Text(
                                                    'Evoke Membership',
                                                    style: TextStyle(
                                                      color: Colors.white,
                                                    ),
                                                  ),
                                                ),
                                              );
                                            }

                                            // Generic evoke membership option when applicable
                                            if (!(_currentUserClubRank ==
                                                    'President' &&
                                                (memberRank == 'Co-President' ||
                                                    memberRank == 'Board'))) {
                                              items.add(
                                                const PopupMenuItem<String>(
                                                  value: 'evoke_membership',
                                                  child: Text(
                                                    'Evoke Membership',
                                                    style: TextStyle(
                                                      color: Colors.white,
                                                    ),
                                                  ),
                                                ),
                                              );
                                            }
                                          } else {
                                            items.addAll([
                                              const PopupMenuItem<String>(
                                                value: 'grant',
                                                child: Text(
                                                  'Grant Membership',
                                                  style: TextStyle(
                                                    color: Colors.white,
                                                  ),
                                                ),
                                              ),
                                              const PopupMenuItem<String>(
                                                value: 'report',
                                                child: Text(
                                                  'Report User',
                                                  style: TextStyle(
                                                    color: Colors.white,
                                                  ),
                                                ),
                                              ),
                                              const PopupMenuItem<String>(
                                                value: 'block',
                                                child: Text(
                                                  'Block User',
                                                  style: TextStyle(
                                                    color: Colors.white,
                                                  ),
                                                ),
                                              ),
                                            ]);
                                          }

                                          return items;
                                        },
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
            if (_currentUserClubRank == 'President')
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF121212),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Theme(
                  data: Theme.of(
                    context,
                  ).copyWith(dividerColor: Colors.transparent),
                  child: ExpansionTile(
                    tilePadding: const EdgeInsets.symmetric(
                      horizontal: 13,
                      vertical: 2,
                    ),
                    collapsedBackgroundColor: Colors.transparent,
                    backgroundColor: Colors.transparent,
                    iconColor: Colors.white,
                    collapsedIconColor: Colors.white,
                    childrenPadding: const EdgeInsets.fromLTRB(
                      0.0,
                      0.0,
                      0.0,
                      6.0,
                    ),
                    title: const Text(
                      'Edit Club',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Club Photo',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Expanded(
                                  child: Container(
                                    height: 100,
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF1B1B1B),
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(color: Colors.white24),
                                    ),
                                    child: _selectedImage != null
                                        ? ClipRRect(
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                            child: Image.file(
                                              _selectedImage!,
                                              fit: BoxFit.cover,
                                            ),
                                          )
                                        : _clubPhotoUrlController
                                              .text
                                              .isNotEmpty
                                        ? ClipRRect(
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                            child: Image.network(
                                              _clubPhotoUrlController.text,
                                              fit: BoxFit.cover,
                                              errorBuilder:
                                                  (
                                                    context,
                                                    error,
                                                    stackTrace,
                                                  ) => const Icon(
                                                    Icons.image,
                                                    color: Colors.white70,
                                                    size: 40,
                                                  ),
                                            ),
                                          )
                                        : const Icon(
                                            Icons.image,
                                            color: Colors.white70,
                                            size: 40,
                                          ),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                ElevatedButton(
                                  onPressed: _pickImage,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF282323),
                                    foregroundColor: Colors.white,
                                  ),
                                  child: const Text('Choose Image'),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            const Text(
                              'Club Name',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 8),
                            TextField(
                              controller: _clubNameController,
                              style: const TextStyle(color: Colors.white),
                              decoration: InputDecoration(
                                filled: true,
                                fillColor: const Color(0xFF1B1B1B),
                                border: const OutlineInputBorder(),
                                focusedBorder: const OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color: Color(0xFF282323),
                                  ),
                                ),
                                hintText:
                                    _clubData?['club_name'] ?? 'Club Name',
                                hintStyle: const TextStyle(
                                  color: Colors.white70,
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            const Text(
                              'Club Bio',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 8),
                            TextField(
                              controller: _clubDescriptionController,
                              maxLines: 3,
                              style: const TextStyle(color: Colors.white),
                              decoration: InputDecoration(
                                filled: true,
                                fillColor: const Color(0xFF1B1B1B),
                                border: const OutlineInputBorder(),
                                focusedBorder: const OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color: Color(0xFF282323),
                                  ),
                                ),
                                hintText: _clubData?['club_bio'] ?? 'Club Bio',
                                hintStyle: const TextStyle(
                                  color: Colors.white70,
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: _saveClubChanges,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF282323),
                                foregroundColor: Colors.white,
                              ),
                              child: const Text('Save Changes'),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
