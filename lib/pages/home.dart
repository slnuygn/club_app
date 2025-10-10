import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    const double imageHeight = 180;
    final double overlayHeight = imageHeight / 3;
    const String description =
        'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Vestibulum vehicula, nisl sed congue dictum, metus augue dapibus purus.';
    final List<String> words = description
        .trim()
        .split(RegExp(r'\s+'))
        .where((word) => word.isNotEmpty)
        .toList();
    final bool showReadMore = words.length > 6;
    final String displayDescription = showReadMore
        ? '${words.take(6).join(' ')}...'
        : description;

    return Scaffold(
      backgroundColor: const Color(0xFF282323),
      body: Align(
        alignment: Alignment.topLeft,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Today's events",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: SizedBox(
                  width: double.infinity,
                  height: imageHeight,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Image.network(
                        'https://picsum.photos/400/220',
                        fit: BoxFit.cover,
                      ),
                      Align(
                        alignment: Alignment.bottomCenter,
                        child: Container(
                          height: overlayHeight,
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.5),
                            borderRadius: const BorderRadius.only(
                              bottomLeft: Radius.circular(6),
                              bottomRight: Radius.circular(6),
                            ),
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              CircleAvatar(
                                radius: (overlayHeight - 16) / 2,
                                backgroundImage: const NetworkImage(
                                  'https://picsum.photos/seed/avatar/80',
                                ),
                                backgroundColor: Colors.white24,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Text(
                                      'Dummy Community',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                        height: 1,
                                      ),
                                    ),
                                    Wrap(
                                      crossAxisAlignment:
                                          WrapCrossAlignment.center,
                                      spacing: 4,
                                      runSpacing: 2,
                                      children: [
                                        Text(
                                          displayDescription,
                                          style: const TextStyle(
                                            color: Colors.white70,
                                            fontSize: 12,
                                            height: 1.1,
                                          ),
                                        ),
                                        if (showReadMore)
                                          const Text(
                                            'Read more',
                                            style: TextStyle(
                                              color: Colors.blue,
                                              fontSize: 12,
                                              decoration:
                                                  TextDecoration.underline,
                                            ),
                                          ),
                                      ],
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
              ),
            ],
          ),
        ),
      ),
    );
  }
}
