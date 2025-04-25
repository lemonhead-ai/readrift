import 'package:flutter/material.dart';
import 'package:ReadRift/screens/dock.dart';

class LibraryScreen extends StatefulWidget {
  const LibraryScreen({super.key});

  @override
  _LibraryScreenState createState() => _LibraryScreenState();
}

class _LibraryScreenState extends State<LibraryScreen> {
  int _selectedIndex = 2;

  void _onNavIconTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          const SafeArea(
            bottom: false,
            child: Center(
              child: Text('Library Screen - To Be Implemented'),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Dock(
              selectedIndex: _selectedIndex,
              onItemTapped: _onNavIconTapped,
            ),
          ),
        ],
      ),
    );
  }
}