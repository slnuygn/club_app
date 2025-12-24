import 'package:flutter/material.dart';
import 'club_profile.dart';

/// Data class for club search item
class ClubSearchData {
  const ClubSearchData({
    required this.clubName,
    required this.clubAvatarUrl,
    required this.clubId,
    required this.clubBio,
  });

  final String clubName;
  final String clubAvatarUrl;
  final String clubId;
  final String clubBio;
}

class ClubSearchItem extends StatefulWidget {
  const ClubSearchItem({
    super.key,
    required this.data,
    this.onTap,
    this.isFollowing = false,
    this.onFollowToggle,
  });

  final ClubSearchData data;
  final VoidCallback? onTap;
  final bool isFollowing;
  final VoidCallback? onFollowToggle;

  @override
  State<ClubSearchItem> createState() => _ClubSearchItemState();
}

class _ClubSearchItemState extends State<ClubSearchItem> {
  late bool _isFollowing;

  @override
  void initState() {
    super.initState();
    _isFollowing = widget.isFollowing;
  }

  @override
  void didUpdateWidget(ClubSearchItem oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isFollowing != widget.isFollowing) {
      _isFollowing = widget.isFollowing;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap:
          widget.onTap ??
          () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ClubProfile(clubId: widget.data.clubId),
              ),
            );
          },
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFF1B1B1B),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 30,
              backgroundImage: widget.data.clubAvatarUrl.isNotEmpty
                  ? NetworkImage(widget.data.clubAvatarUrl)
                  : null,
              backgroundColor: Colors.white,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        widget.data.clubName,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const Text(
                        ' ∙ ',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          height: 2,
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          setState(() => _isFollowing = !_isFollowing);
                          widget.onFollowToggle?.call();
                        },
                        child: Text(
                          _isFollowing ? 'Following' : 'Follow',
                          style: const TextStyle(
                            color: Color(0xFF007D99),
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            height: 2,
                          ),
                        ),
                      ),
                    ],
                  ),
                  Text(
                    widget.data.clubBio,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                      height: 1.0,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
