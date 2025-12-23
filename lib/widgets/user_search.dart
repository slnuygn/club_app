import 'package:flutter/material.dart';

/// Data class for user search item
class UserSearchData {
  const UserSearchData({
    required this.userName,
    required this.userAvatarUrl,
    required this.userId,
    this.clubKey,
  });

  final String userName;
  final String userAvatarUrl;
  final String userId;
  final String? clubKey;
}

class UserSearchItem extends StatelessWidget {
  const UserSearchItem({
    super.key,
    required this.data,
    this.onTap,
    this.isCurrentUser = false,
    this.onMenuAction,
    this.currentUserClubKey,
  });

  final UserSearchData data;
  final VoidCallback? onTap;
  final bool isCurrentUser;
  final Function(String action, String userId)? onMenuAction;
  final String? currentUserClubKey;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFF1B1B1B),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Stack(
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundImage: data.userAvatarUrl.isNotEmpty
                      ? NetworkImage(data.userAvatarUrl)
                      : null,
                  backgroundColor: Colors.white,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    data.userName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            if (!isCurrentUser)
              Positioned(
                top: 0,
                right: 0,
                child: PopupMenuButton<String>(
                  icon: const Icon(
                    Icons.more_vert,
                    color: Colors.white70,
                    size: 20,
                  ),
                  color: const Color(0xFF121212),
                  offset: const Offset(-20, 40),
                  onSelected: (String value) {
                    if (onMenuAction != null) {
                      onMenuAction!(value, data.userId);
                    }
                  },
                  itemBuilder: (BuildContext context) {
                    if (data.clubKey != null && data.clubKey!.isNotEmpty) {
                      // User has club_key - only show evoke membership
                      return [
                        const PopupMenuItem<String>(
                          value: 'evoke',
                          child: Text(
                            'Evoke Membership',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.normal,
                            ),
                          ),
                        ),
                      ];
                    } else {
                      // User doesn't have club_key - show grant, report, block
                      return [
                        const PopupMenuItem<String>(
                          value: 'grant',
                          child: Text(
                            'Grant Membership',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.normal,
                            ),
                          ),
                        ),
                        const PopupMenuItem<String>(
                          value: 'report',
                          child: Text(
                            'Report User',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.normal,
                            ),
                          ),
                        ),
                        const PopupMenuItem<String>(
                          value: 'block',
                          child: Text(
                            'Block User',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.normal,
                            ),
                          ),
                        ),
                      ];
                    }
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}
