import 'package:flutter/material.dart';

/// Data class for user search item
class UserSearchData {
  const UserSearchData({
    required this.userName,
    required this.userAvatarUrl,
    required this.userId,
  });

  final String userName;
  final String userAvatarUrl;
  final String userId;
}

class UserSearchItem extends StatelessWidget {
  const UserSearchItem({super.key, required this.data, this.onTap});

  final UserSearchData data;
  final VoidCallback? onTap;

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
        child: Row(
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
      ),
    );
  }
}
