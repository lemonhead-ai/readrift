import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class Dock extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onItemTapped;

  const Dock({
    super.key,
    required this.selectedIndex,
    required this.onItemTapped,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 25.0),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(60.0),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            height: 90,
            decoration: BoxDecoration(
              color: Theme.of(context)
                  .bottomNavigationBarTheme
                  .backgroundColor
                  ?.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(60.0),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 30,
                  offset: const Offset(0, 10),
                ),
              ],
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.1),
                width: 1.0,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNavIcon(context, Icons.home_max_rounded, 0),
                _buildNavIcon(context, Icons.search_rounded, 1),
                _buildNavIcon(context, Icons.menu_book_rounded, 2),
                _buildNavIcon(context, Icons.account_circle_outlined, 3),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavIcon(BuildContext context, IconData icon, int index) {
    final bool isSelected = selectedIndex == index;
    return GestureDetector(
      onTap: () {
        onItemTapped(index);
        switch (index) {
          case 0:
            context.go('/');
            break;
          case 1:
            context.go('/search');
            break;
          case 2:
            context.go('/library');
            break;
          case 3:
            context.go('/profile');
            break;
        }
      },
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: isSelected
            ? BoxDecoration(
          color: Colors.white.withValues(alpha: 0.2),
          shape: BoxShape.circle,
        )
            : null,
        child: Icon(
          icon,
          size: 30,
          color: isSelected
              ? Theme.of(context).bottomNavigationBarTheme.selectedItemColor
              : Theme.of(context).bottomNavigationBarTheme.unselectedItemColor,
        ),
      ),
    );
  }
}