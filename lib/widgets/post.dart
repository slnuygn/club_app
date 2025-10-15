import 'package:flutter/material.dart';
import 'package:readmore/readmore.dart';

class PostCard extends StatefulWidget {
  const PostCard({
    super.key,
    this.child,
    this.caption,
    this.isFavorite = false,
    this.onFavoriteToggle,
    this.avatarUrl,
    this.backgroundImageUrl,
  });

  final Widget? child;
  final String? caption;
  final bool isFavorite;
  final VoidCallback? onFavoriteToggle;
  final String? avatarUrl;
  final String? backgroundImageUrl;

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
    const String defaultCaption =
        'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed do a eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam.';
    final String displayCaption = widget.caption ?? defaultCaption;

    final double avatarRadius = 26; // Larger visible size

    // Generate random avatar
    final String randomAvatarUrl = 'https://picsum.photos/200/200';

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
                    backgroundImage: NetworkImage(randomAvatarUrl),
                    backgroundColor: Colors.white,
                  ),
                  const SizedBox(width: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      RichText(
                        text: TextSpan(
                          text: 'Dummy Community',
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
                            const Text(
                              'Dummy Location',
                              style: TextStyle(
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
                  'https://picsum.photos/400/200',
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
                      const Text(
                        '16 Oct 2023, 10:00 AM',
                        style: TextStyle(color: Colors.white70, fontSize: 14),
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
          if (widget.backgroundImageUrl != null)
            Positioned.fill(
              child: Image.network(
                widget.backgroundImageUrl!,
                fit: BoxFit.cover,
              ),
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
