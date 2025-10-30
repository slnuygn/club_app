import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

const navBarIconColor = Color(0xFF807373);
const double navBarIconSize = 30;

class NavBar extends StatelessWidget {
  const NavBar({
    super.key,
    required this.selectedIndex,
    required this.onItemTapped,
    required this.selectedSearchIcon,
    required this.user,
  });

  final int selectedIndex;
  final ValueChanged<int> onItemTapped;
  final Widget selectedSearchIcon;
  final User? user;

  static const double _containerHeight = 70;

  static const Icon _homeFilled = Icon(
    Icons.home,
    color: navBarIconColor,
    weight: 700,
  );
  static const Icon _homeOutlined = Icon(
    Icons.home_outlined,
    color: navBarIconColor,
    weight: 100,
  );
  static const Icon _searchOutlined = Icon(
    Icons.search_outlined,
    color: navBarIconColor,
    weight: 100,
  );
  static const Icon _bookmarkFilled = Icon(
    Icons.favorite,
    color: navBarIconColor,
    weight: 700,
  );
  static const Icon _bookmarkOutlined = Icon(
    Icons.favorite_border,
    color: navBarIconColor,
    weight: 100,
  );

  @override
  Widget build(BuildContext context) {
    return Container(
      height: _containerHeight,
      color: Colors.black,
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          IconButton(
            icon: selectedIndex == 0 ? _homeFilled : _homeOutlined,
            iconSize: navBarIconSize,
            onPressed: () => onItemTapped(0),
          ),
          IconButton(
            icon: selectedIndex == 1 ? selectedSearchIcon : _searchOutlined,
            iconSize: navBarIconSize,
            onPressed: () => onItemTapped(1),
          ),
          IconButton(
            icon: selectedIndex == 2 ? _bookmarkFilled : _bookmarkOutlined,
            iconSize: navBarIconSize,
            onPressed: () => onItemTapped(2),
          ),
          GestureDetector(
            onTap: () => onItemTapped(3),
            child: Container(
              width: navBarIconSize,
              height: navBarIconSize,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: selectedIndex == 3
                    ? Border.all(color: navBarIconColor, width: 2)
                    : null,
              ),
              child: CircleAvatar(
                radius: navBarIconSize / 2,
                backgroundColor: Colors.grey[800],
                backgroundImage: user?.photoURL != null
                    ? NetworkImage(user!.photoURL!)
                    : null,
                child: user?.photoURL == null
                    ? const Icon(Icons.person, color: navBarIconColor, size: 20)
                    : null,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
