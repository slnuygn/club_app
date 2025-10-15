import 'package:flutter/material.dart';

/// Holds the dynamic data for a showcase card so callers supply only
/// content that varies between posts.
class PostShowcaseData {
  const PostShowcaseData({
    required this.backgroundImageUrl,
    required this.communityAvatarUrl,
    required this.communityName,
    required this.postCaption,
    required this.dateDisplay,
    required this.placeDisplay,
  });

  final String backgroundImageUrl;
  final String communityAvatarUrl;
  final String communityName;
  final String postCaption;
  final String dateDisplay;
  final String placeDisplay;
}

/// Renders a fully styled showcase card including background imagery,
/// navigation arrows, overlay chrome, and the mutable post content.
class PostShowcase extends StatelessWidget {
  const PostShowcase({
    super.key,
    required this.data,
    required this.isFavorite,
    required this.onFavoriteToggle,
    required this.onPrevious,
    required this.onNext,
    this.imageHeight = 180,
  });

  final PostShowcaseData data;
  final bool isFavorite;
  final VoidCallback onFavoriteToggle;
  final VoidCallback onPrevious;
  final VoidCallback onNext;
  final double imageHeight;

  @override
  Widget build(BuildContext context) {
    const int maxCharsForText = 70;
    final String truncatedCaption = data.postCaption.length > maxCharsForText
        ? '${data.postCaption.substring(0, maxCharsForText)}...'
        : data.postCaption;

    final double overlayHeight = imageHeight / 3;
    final double avatarRadius = (overlayHeight - 16) / 2;

    return ClipRRect(
      borderRadius: BorderRadius.circular(6),
      child: SizedBox(
        width: double.infinity,
        height: imageHeight,
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.network(data.backgroundImageUrl, fit: BoxFit.cover),
            Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: const EdgeInsets.only(left: 1),
                child: Transform.translate(
                  offset: const Offset(-6, 0),
                  child: IconButton(
                    icon: const Icon(
                      Icons.arrow_back_ios_new,
                      color: Colors.white,
                    ),
                    onPressed: onPrevious,
                  ),
                ),
              ),
            ),
            Align(
              alignment: Alignment.centerRight,
              child: Padding(
                padding: const EdgeInsets.only(right: 1),
                child: Transform.translate(
                  offset: const Offset(6, 0),
                  child: IconButton(
                    icon: const Icon(
                      Icons.arrow_forward_ios,
                      color: Colors.white,
                    ),
                    onPressed: onNext,
                  ),
                ),
              ),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                constraints: BoxConstraints(minHeight: overlayHeight),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.5),
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(6),
                    bottomRight: Radius.circular(6),
                  ),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    CircleAvatar(
                      radius: avatarRadius,
                      backgroundImage: NetworkImage(data.communityAvatarUrl),
                      backgroundColor: Colors.white24,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            data.communityName,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              height: 1,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text.rich(
                            TextSpan(
                              children: [
                                TextSpan(
                                  text: truncatedCaption,
                                  style: const TextStyle(
                                    color: Colors.white70,
                                    fontSize: 12,
                                    height: 1.1,
                                  ),
                                ),
                                const TextSpan(
                                  text: ' Read More',
                                  style: TextStyle(
                                    color: const Color(0xFF007D99),
                                    fontSize: 12,
                                    height: 1.1,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 1),
                          Row(
                            children: [
                              const Icon(
                                Icons.access_time,
                                size: 14,
                                color: Colors.white60,
                              ),
                              const SizedBox(width: 1),
                              Text(
                                data.dateDisplay,
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 12,
                                ),
                              ),
                              const SizedBox(width: 4),
                              const Icon(
                                Icons.location_on,
                                size: 14,
                                color: Colors.white60,
                              ),
                              const SizedBox(width: 1),
                              Expanded(
                                child: Text(
                                  data.placeDisplay,
                                  style: const TextStyle(
                                    color: Colors.white70,
                                    fontSize: 12,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      icon: Icon(
                        isFavorite ? Icons.favorite : Icons.favorite_border,
                        color: isFavorite ? Colors.red : Colors.white,
                      ),
                      onPressed: onFavoriteToggle,
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

/// A reusable indicator row that renders concentric dots to highlight the
/// currently visible showcase entry.
class PostShowcaseIndicator extends StatelessWidget {
  const PostShowcaseIndicator({
    super.key,
    required this.count,
    required this.activeIndex,
  });

  final int count;
  final int activeIndex;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(count, (int index) {
        final bool isActive = index == activeIndex;
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Stack(
            alignment: Alignment.center,
            children: [
              const CircleAvatar(radius: 5, backgroundColor: Color(0xFF1B1B1B)),
              CircleAvatar(
                radius: 3,
                backgroundColor: isActive
                    ? const Color(0xFF807373)
                    : const Color(0xFF1B1B1B),
              ),
            ],
          ),
        );
      }),
    );
  }
}
