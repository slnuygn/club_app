import 'package:flutter/material.dart';

/// Data class for club search item
class ClubSearchData {
  const ClubSearchData({
    required this.clubName,
    required this.clubAvatarUrl,
    required this.clubId,
  });

  final String clubName;
  final String clubAvatarUrl;
  final String clubId;
}

class ClubSearchItem extends StatelessWidget {
  const ClubSearchItem({super.key, required this.data, this.onTap});

  final ClubSearchData data;
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
              backgroundImage: data.clubAvatarUrl.isNotEmpty
                  ? NetworkImage(data.clubAvatarUrl)
                  : null,
              backgroundColor: Colors.white,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                data.clubName,
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
