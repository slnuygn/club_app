import 'package:flutter/material.dart';

class NotificationItem extends StatelessWidget {
  final String message;

  const NotificationItem({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF121212),
      margin: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
      padding: const EdgeInsets.all(16.0),
      child: Text(message, style: const TextStyle(color: Colors.white)),
    );
  }
}
