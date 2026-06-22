import 'package:flutter/material.dart';

import '../screens/bookings_screen.dart';
import '../screens/find_tutor_screen.dart';
import '../screens/home_screen.dart';
import '../screens/profile_screen.dart';

/// The main shell shown after a user logs in.
///
/// Holds the [BottomNavigationBar] with four tabs (Home, AI Search, Bookings,
/// Profile) and swaps the body between them using an [IndexedStack] so each
/// tab keeps its own state. Screens opened on top of a tab (tutor profile,
/// booking form, payment, search results) are pushed with Navigator and have
/// their own Scaffold — they are NOT part of this bar.
class MainScaffold extends StatefulWidget {
  const MainScaffold({super.key});

  @override
  State<MainScaffold> createState() => _MainScaffoldState();
}

class _MainScaffoldState extends State<MainScaffold> {
  // Index of the currently selected bottom-navigation tab.
  int _selectedIndex = 0;

  void _setTab(int index) => setState(() => _selectedIndex = index);

  @override
  Widget build(BuildContext context) {
    // Built inside build() so HomeScreen can receive a callback that switches
    // to the AI Search tab when the "Start AI Search" banner is tapped.
    final tabs = <Widget>[
      HomeScreen(onStartAiSearch: () => _setTab(1)),
      const FindTutorScreen(),
      const BookingsScreen(),
      const ProfileScreen(),
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('TutorLINK')),
      body: IndexedStack(index: _selectedIndex, children: tabs),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _setTab,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.travel_explore),
            label: 'AI Search',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.event_note),
            label: 'Bookings',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
