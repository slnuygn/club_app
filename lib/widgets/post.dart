import 'package:flutter/material.dart';
import 'package:readmore/readmore.dart';

/// Encapsulates the mutable content for a post card so callers can render
/// multiple cards by supplying only post-specific data.
class PostCardData {
  const PostCardData({
    required this.communityName,
    required this.communityAvatarUrl,
    required this.location,
    required this.caption,
    required this.dateDisplay,
    required this.imageUrl,
  });

  final String communityName;
  final String communityAvatarUrl;
  final String location;
  final String caption;
  final String dateDisplay;
  final String imageUrl;
}

class PostCard extends StatefulWidget {
  const PostCard({
    super.key,
    required this.data,
    this.isFavorite = false,
    this.onFavoriteToggle,
  });

  final PostCardData data;
  final bool isFavorite;
  final VoidCallback? onFavoriteToggle;

  @override
  State<PostCard> createState() => _PostCardState();
}

class _PostCardState extends State<PostCard> {
  late bool _isFavorite;

  @override
  void initState() {
    super.initState();
    _isFavorite = widget.isFavorite;
  }

  @override
  void didUpdateWidget(PostCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isFavorite != widget.isFavorite) {
      _isFavorite = widget.isFavorite;
    }
  }

  @override
  Widget build(BuildContext context) {
    final double avatarRadius = 26;
    final String displayCaption = widget.data.caption;

    return Container(
      width: double.infinity,
      // height: 300, // Removed fixed height to allow dynamic sizing based on content
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF1B1B1B),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: avatarRadius,
                    backgroundImage: NetworkImage(
                      widget.data.communityAvatarUrl,
                    ),
                    backgroundColor: Colors.white,
                  ),
                  const SizedBox(width: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      RichText(
                        text: TextSpan(
                          text: widget.data.communityName,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            height: 2,
                          ),
                          children: [
                            TextSpan(
                              text: ' ∙ Follow',
                              style: const TextStyle(
                                color: Color(0xFF007D99),
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                height: 2,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Transform.translate(
                        offset: const Offset(0, -6),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.location_on,
                              color: Colors.white70,
                              size: 15,
                            ),
                            const SizedBox(width: 1),
                            Text(
                              widget.data.location,
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 6),
              SizedBox(
                // Remove fixed width to take full container width
                child: ReadMoreText(
                  displayCaption,
                  trimLines: 2,
                  trimMode: TrimMode.Line,
                  trimCollapsedText: 'Read More',
                  trimExpandedText: '',
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 13,
                    height: 1.1,
                  ),
                  moreStyle: const TextStyle(
                    color: Color(0xFF007D99),
                    fontSize: 12,
                    height: 1.1,
                    fontWeight: FontWeight.bold,
                    decoration: TextDecoration.underline,
                  ),
                  lessStyle: const TextStyle(
                    color: Colors.transparent,
                    fontSize: 12,
                    height: 1.1,
                    fontWeight: FontWeight.bold,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(3),
                child: Image.network(
                  widget.data.imageUrl,
                  height: 150,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.access_time,
                        color: Colors.white70,
                        size: 16,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        widget.data.dateDisplay,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: () {
                      // Handle share action
                    },
                    child: const Icon(
                      Icons.share,
                      color: Colors.white70,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: GestureDetector(
                      onTap: () {
                        setState(() => _isFavorite = !_isFavorite);
                        widget.onFavoriteToggle?.call();
                      },
                      child: Icon(
                        _isFavorite ? Icons.favorite : Icons.favorite_border,
                        color: _isFavorite ? Colors.red : Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          Positioned(
            top: 8,
            right: 8,
            child: GestureDetector(
              onTap: () {
                // Handle settings action
              },
              child: const Icon(
                Icons.more_vert,
                color: Colors.white70,
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
