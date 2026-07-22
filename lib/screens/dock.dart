import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class Dock extends StatefulWidget {
  final int selectedIndex;
  final Function(int) onItemTapped;
  final ScrollController? scrollController;

  const Dock({
    super.key,
    required this.selectedIndex,
    required this.onItemTapped,
    this.scrollController,
  });

  @override
  State<Dock> createState() => _DockState();
}

class _DockState extends State<Dock> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _slideAnimation;
  bool _isVisible = true;
  double _lastScrollPosition = 0;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _slideAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _animationController.value = 1.0; // Start visible

    if (widget.scrollController != null) {
      widget.scrollController!.addListener(_onScroll);
    }
  }

  @override
  void dispose() {
    if (widget.scrollController != null) {
      widget.scrollController!.removeListener(_onScroll);
    }
    _animationController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (widget.scrollController == null) return;

    final currentScroll = widget.scrollController!.position.pixels;
    final isScrollingDown = currentScroll > _lastScrollPosition;
    _lastScrollPosition = currentScroll;

    if (!isScrollingDown && currentScroll > 0 && _isVisible) {
      _isVisible = false;
      _animationController.reverse();
    } else if (isScrollingDown && !_isVisible) {
      _isVisible = true;
      _animationController.forward();
    }
  }

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;

    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, 100 * (1 - _slideAnimation.value)),
          child: Opacity(
            opacity: _slideAnimation.value,
            child: child,
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 25.0),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(60.0),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
            child: Container(
              height: 70,
              decoration: BoxDecoration(
                // No color or tint to ensure full transparency
                borderRadius: BorderRadius.circular(60.0),
                boxShadow: [
                  BoxShadow(
                    color: brightness == Brightness.light
                        ? Colors.black.withValues(alpha: 0.1)
                        : Colors.white.withValues(alpha: 0.05),
                    blurRadius: 40,
                    offset: const Offset(0, 15),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildNavIcon(context, Icons.home_max_rounded, 0),
                  _buildNavIcon(context, Icons.search_rounded, 1),
                  _buildNavIcon(context, Icons.menu_book_rounded, 2),
                  _buildNavIcon(context, Icons.bookmark_border_rounded, 3),
                  _buildNavIcon(context, Icons.account_circle_outlined, 4),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavIcon(BuildContext context, IconData icon, int index) {
    final bool isSelected = widget.selectedIndex == index;
    final brightness = Theme.of(context).brightness;

    return GestureDetector(
      onTap: () {
        widget.onItemTapped(index);
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
            context.go('/bookmark');
            break;
          case 4:
            context.go('/profile');
            break;
        }
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(12),
        decoration: isSelected
            ? BoxDecoration(
          gradient: LinearGradient(
            colors: [
              brightness == Brightness.light
                  ? Colors.white.withValues(alpha: 0.25)
                  : Colors.black.withValues(alpha: 0.25),
              brightness == Brightness.light
                  ? Colors.white.withValues(alpha: 0.05)
                  : Colors.black.withValues(alpha: 0.05),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: brightness == Brightness.light
                  ? Colors.white.withValues(alpha: 0.15)
                  : Colors.black.withValues(alpha: 0.15),
              blurRadius: 10,
              spreadRadius: 2,
            ),
          ],
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