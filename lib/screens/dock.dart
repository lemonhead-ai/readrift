import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:readrift/theme.dart';
import 'package:readrift/widgets/bouncy_tap.dart';

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

  final List<_DockItemData> _items = const [
    _DockItemData(icon: Icons.home_outlined, activeIcon: Icons.home_rounded, label: 'Home'),
    _DockItemData(icon: Icons.search_rounded, activeIcon: Icons.search_rounded, label: 'Search'),
    _DockItemData(icon: Icons.menu_book_outlined, activeIcon: Icons.menu_book_rounded, label: 'Library'),
    _DockItemData(icon: Icons.account_circle_outlined, activeIcon: Icons.account_circle_rounded, label: 'Profile'),
  ];

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

    _animationController.value = 1.0;

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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, (80 + bottomPadding) * (1 - _slideAnimation.value)),
          child: Opacity(
            opacity: _slideAnimation.value,
            child: child,
          ),
        );
      },
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: isDark
              ? AppColors.oledBlack.withValues(alpha: 0.95)
              : Colors.white.withValues(alpha: 0.95),
          border: Border(
            top: BorderSide(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.12)
                  : Colors.black.withValues(alpha: 0.08),
              width: 1.0,
            ),
          ),
          boxShadow: [
            BoxShadow(
              color: isDark
                  ? Colors.black.withValues(alpha: 0.5)
                  : Colors.black.withValues(alpha: 0.05),
              blurRadius: 16,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: ClipRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
            child: SafeArea(
              top: false,
              child: Container(
                height: 64,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: List.generate(_items.length, (index) {
                    return Expanded(
                      child: _buildNavItem(context, _items[index], index),
                    );
                  }),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(BuildContext context, _DockItemData item, int index) {
    final bool isSelected = widget.selectedIndex == index;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final unselectedColor = isDark
        ? Colors.white.withValues(alpha: 0.5)
        : Colors.black.withValues(alpha: 0.5);

    return BouncyTap(
      onTap: () {
        widget.onItemTapped(index);
      },
      child: Container(
        color: Colors.transparent,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.accentOrange.withValues(alpha: 0.18)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(
                isSelected ? item.activeIcon : item.icon,
                size: 24,
                color: isSelected ? AppColors.accentOrange : unselectedColor,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              item.label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                color: isSelected ? AppColors.accentOrange : unselectedColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DockItemData {
  final IconData icon;
  final IconData activeIcon;
  final String label;

  const _DockItemData({
    required this.icon,
    required this.activeIcon,
    required this.label,
  });
}