import 'package:flutter/material.dart';
import 'detections_screen.dart';
import 'progress_screen.dart';
import 'calendar_screen.dart';

/// [HomeScreen] is a stateful widget that serves as the main navigation point of the app.
/// It uses a bottom navigation bar to switch between different screens: 
/// [ProgressScreen], [DetectionsScreen], and [CalendarScreen].
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _HomeScreenState createState() => _HomeScreenState();
}

/// The state for this widget
class _HomeScreenState extends State<HomeScreen> {
  // Tracks the currently selected index of the bottom navigation bar.
  int _selectedIndex = 1;

  /// Updates the selected index when a navigation item is tapped
  /// and triggers a rebuild to reflect the new screen.
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    // List of widgets that represent different screens in the app.
    final List<Widget> screens = [
      const ProgressScreen(),
      const DetectionsScreen(),
      const CalendarScreen(),
    ];

    return Scaffold(
      // AppBar at the top of the screen with a title.
      appBar: AppBar(
        title: const Text('Plants Monitoring'),
        backgroundColor: Colors.green,
      ),
      // The body of the Scaffold shows the screen corresponding to the selected index.
      body: screens[_selectedIndex],
      
      // Bottom navigation bar to allow switching between screens.
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.analytics),
            label: 'Progress',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: 'Detections',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_month),
            label: 'Calendar',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.green,
        onTap: _onItemTapped,
        backgroundColor: Colors.grey[200],
      ),
    );
  }
}
