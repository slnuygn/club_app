import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'firebase_options.dart';
import 'pages/login.dart';
import 'pages/home.dart';
import 'pages/search.dart';
import 'pages/saved.dart';
import 'pages/profile.dart';
import 'widgets/navbar.dart';

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
      debugShowCheckedModeBanner: false,
      theme: ThemeData(useMaterial3: true),
      home: const AuthWrapper(),
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

  late final SvgPicture _selectedSearchIcon;

  @override
  void initState() {
    super.initState();
    _selectedSearchIcon = SvgPicture.asset(
      'assets/icons/search_filled.svg',
      colorFilter: const ColorFilter.mode(navBarIconColor, BlendMode.srcIn),
      width: navBarIconSize,
      height: navBarIconSize,
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
      bottomNavigationBar: NavBar(
        selectedIndex: _selectedIndex,
        onItemTapped: _onItemTapped,
        selectedSearchIcon: _selectedSearchIcon,
        user: FirebaseAuth.instance.currentUser,
      ),
    );
  }
}
