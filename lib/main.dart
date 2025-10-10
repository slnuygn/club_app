import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'home.dart';
import 'search.dart';
import 'saved.dart';
import 'profile.dart';

/// Flutter code sample for [BottomNavigationBar].

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const ClubsApp());
}

class ClubsApp extends StatelessWidget {
  const ClubsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(useMaterial3: true),
      home: const ClubsHome(),
    );
  }
}

class ClubsHome extends StatefulWidget {
  const ClubsHome({super.key});

  @override
  State<ClubsHome> createState() => _ClubsHomeState();
}

class _ClubsHomeState extends State<ClubsHome> {
  int _selectedIndex = 0;
  static const List<Widget> _pages = <Widget>[
    HomePage(),
    SearchPage(),
    SavedPage(),
    ProfilePage(),
  ];

  static const Color _navIconColor = Color(0xFF807373);
  static const double _navIconSize = 30;

  late final SvgPicture _selectedSearchIcon;

  @override
  void initState() {
    super.initState();
    _selectedSearchIcon = SvgPicture.asset(
      'assets/icons/search_filled.svg',
      colorFilter: const ColorFilter.mode(_navIconColor, BlendMode.srcIn),
      width: _navIconSize,
      height: _navIconSize,
    );
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF282323),
      body: IndexedStack(index: _selectedIndex, children: _pages),
      bottomNavigationBar: Container(
        height: 70,
        color: Colors.black,
        padding: const EdgeInsets.only(bottom: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            IconButton(
              icon: _selectedIndex == 0
                  ? const Icon(Icons.home, color: _navIconColor, weight: 700)
                  : const Icon(
                      Icons.home_outlined,
                      color: _navIconColor,
                      weight: 100,
                    ),
              iconSize: _navIconSize,
              onPressed: () => _onItemTapped(0),
            ),
            IconButton(
              icon: _selectedIndex == 1
                  ? _selectedSearchIcon
                  : const Icon(
                      Icons.search_outlined,
                      color: _navIconColor,
                      weight: 100,
                    ),
              iconSize: _navIconSize,
              onPressed: () => _onItemTapped(1),
            ),
            IconButton(
              icon: _selectedIndex == 2
                  ? const Icon(
                      Icons.bookmark,
                      color: _navIconColor,
                      weight: 700,
                    )
                  : const Icon(
                      Icons.bookmark_border,
                      color: _navIconColor,
                      weight: 100,
                    ),
              iconSize: _navIconSize,
              onPressed: () => _onItemTapped(2),
            ),
            IconButton(
              icon: _selectedIndex == 3
                  ? const Icon(Icons.person, color: _navIconColor, weight: 700)
                  : const Icon(
                      Icons.person_outline_rounded,
                      color: _navIconColor,
                      weight: 100,
                    ),
              iconSize: _navIconSize,
              onPressed: () => _onItemTapped(3),
            ),
          ],
        ),
      ),
    );
  }
}
