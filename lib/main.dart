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
  static final List<Widget> _widgetOptions = <Widget>[
    HomePage(),
    SearchPage(),
    SavedPage(),
    ProfilePage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF282323),
      body: Center(child: _widgetOptions.elementAt(_selectedIndex)),
      bottomNavigationBar: Container(
        height: 70,
        color: Colors.black, // Changed to black
        padding: EdgeInsets.only(bottom: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            IconButton(
              icon: Icon(
                _selectedIndex == 0 ? Icons.home : Icons.home_outlined,
                color: Color(0xFF807373),
                weight: _selectedIndex == 0 ? 700 : 100,
              ),
              iconSize: 30,
              onPressed: () => _onItemTapped(0),
            ),
            IconButton(
              icon: _selectedIndex == 1
                  ? SvgPicture.asset(
                      'assets/icons/search_filled.svg',
                      colorFilter: ColorFilter.mode(
                        Color(0xFF807373),
                        BlendMode.srcIn,
                      ),
                      width: 30,
                      height: 30,
                    )
                  : Icon(
                      Icons.search_outlined,
                      color: Color(0xFF807373),
                      weight: 100,
                    ),
              iconSize: 30,
              onPressed: () => _onItemTapped(1),
            ),
            IconButton(
              icon: Icon(
                _selectedIndex == 2 ? Icons.bookmark : Icons.bookmark_border,
                color: Color(0xFF807373),
                weight: _selectedIndex == 2 ? 700 : 100,
              ),
              iconSize: 30,
              onPressed: () => _onItemTapped(2),
            ),
            IconButton(
              icon: Icon(
                _selectedIndex == 3
                    ? Icons.person
                    : Icons.person_outline_rounded,
                color: Color(0xFF807373),
                weight: _selectedIndex == 3 ? 700 : 100,
              ),
              iconSize: 30,
              onPressed: () => _onItemTapped(3),
            ),
          ],
        ),
      ),
    );
  }
}
