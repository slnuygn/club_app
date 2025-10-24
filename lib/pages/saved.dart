import 'package:flutter/material.dart';

class SavedPage extends StatelessWidget {
  const SavedPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF282323),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.only(left: 10, top: 1),
          child: Text(
            'My events',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}
