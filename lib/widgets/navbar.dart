import 'package:flutter/material.dart';

const navBarIconColor = Color(0xFF807373);
const double navBarIconSize = 30;

class NavBar extends StatelessWidget {
  const NavBar({
    super.key,
    required this.selectedIndex,
    required this.onItemTapped,
    required this.selectedSearchIcon,
  });

  final int selectedIndex;
  final ValueChanged<int> onItemTapped;
  final Widget selectedSearchIcon;

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
    Icons.bookmark,
    color: navBarIconColor,
    weight: 700,
  );
  static const Icon _bookmarkOutlined = Icon(
    Icons.bookmark_border,
    color: navBarIconColor,
    weight: 100,
  );
  static const Icon _personFilled = Icon(
    Icons.person,
    color: navBarIconColor,
    weight: 700,
  );
  static const Icon _personOutlined = Icon(
    Icons.person_outline_rounded,
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
          IconButton(
            icon: selectedIndex == 3 ? _personFilled : _personOutlined,
            iconSize: navBarIconSize,
            onPressed: () => onItemTapped(3),
          ),
        ],
      ),
    );
  }
}
