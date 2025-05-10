import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:readrift/theme.dart';

class BlurredStatusBar extends StatelessWidget {
  final Widget child;

  const BlurredStatusBar({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final double statusBarHeight = MediaQuery.of(context).padding.top;

    return Stack(
      children: [
        child,
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          height: statusBarHeight,
          child: ClipRRect(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 23, sigmaY: 23),
              child: Container(
                color: Theme.of(context).brightness == Brightness.light
                    ? AppColors.lightDockBackground.withValues(alpha: 0.1)
                    : AppColors.darkDockBackground.withValues(alpha: 0.1),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
