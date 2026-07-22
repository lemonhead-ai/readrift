import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';


class FadePageRoute<T> extends PageRoute<T> {
  final Widget child;
  final Duration duration;

  FadePageRoute({
    required this.child,
    this.duration = const Duration(milliseconds: 300),
  });

  @override
  Color? get barrierColor => null;

  @override
  String? get barrierLabel => null;

  @override
  bool get maintainState => true;

  @override
  Duration get transitionDuration => duration;

  @override
  Widget buildPage(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
  ) {
    return FadeTransition(
      opacity: animation,
      child: child,
    );
  }
}

class SlidePageRoute<T> extends PageRoute<T> {
  final Widget child;
  final Duration duration;
  final Offset begin;
  final Offset end;

  SlidePageRoute({
    required this.child,
    this.duration = const Duration(milliseconds: 300),
    this.begin = const Offset(1.0, 0.0),
    this.end = Offset.zero,
  });

  @override
  Color? get barrierColor => null;

  @override
  String? get barrierLabel => null;

  @override
  bool get maintainState => true;

  @override
  Duration get transitionDuration => duration;

  @override
  Widget buildPage(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
  ) {
    return SlideTransition(
      position: Tween<Offset>(
        begin: begin,
        end: end,
      ).animate(CurvedAnimation(
        parent: animation,
        curve: Curves.easeInOut,
      )),
      child: child,
    );
  }
}

class ScalePageRoute<T> extends PageRoute<T> {
  final Widget child;
  final Duration duration;
  final double begin;
  final double end;

  ScalePageRoute({
    required this.child,
    this.duration = const Duration(milliseconds: 300),
    this.begin = 0.5,
    this.end = 1.5,
  });

  @override
  Color? get barrierColor => null;

  @override
  String? get barrierLabel => null;

  @override
  bool get maintainState => true;

  @override
  Duration get transitionDuration => duration;

  @override
  Widget buildPage(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
  ) {
    return ScaleTransition(
      scale: Tween<double>(
        begin: begin,
        end: end,
      ).animate(CurvedAnimation(
        parent: animation,
        curve: Curves.easeInOut,
      )),
      child: FadeTransition(
        opacity: animation,
        child: child,
      ),
    );
  }
}

CustomTransitionPage<T> buildAdaptivePageRoute<T>({
  required BuildContext context,
  required GoRouterState state,
  required Widget child,
}) {
  // Check target platform dynamically (works on Web too)
  final platform = Theme.of(context).platform;
  final bool isIOS = platform == TargetPlatform.iOS || platform == TargetPlatform.macOS;

  if (isIOS) {
    // iOS 26/27 "Liquid Glass" transition: smooth easeInOutCubic slide & slight scale overlay
    return CustomTransitionPage<T>(
      key: state.pageKey,
      child: child,
      transitionDuration: const Duration(milliseconds: 400),
      reverseTransitionDuration: const Duration(milliseconds: 350),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        final slideIn = Tween<Offset>(
          begin: const Offset(1.0, 0.0),
          end: Offset.zero,
        ).animate(CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutCubic,
          reverseCurve: Curves.easeInCubic,
        ));

        final scaleOut = Tween<double>(
          begin: 1.0,
          end: 0.96,
        ).animate(CurvedAnimation(
          parent: secondaryAnimation,
          curve: Curves.easeInOutCubic,
        ));

        return SlideTransition(
          position: slideIn,
          child: ScaleTransition(
            scale: scaleOut,
            child: child,
          ),
        );
      },
    );
  } else {
    // Android 17 Material 3 Shared Axis: subtle scale & fade
    return CustomTransitionPage<T>(
      key: state.pageKey,
      child: child,
      transitionDuration: const Duration(milliseconds: 300),
      reverseTransitionDuration: const Duration(milliseconds: 250),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        final scaleIn = Tween<double>(
          begin: 0.94,
          end: 1.0,
        ).animate(CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutCubic,
          reverseCurve: Curves.easeInCubic,
        ));

        return FadeTransition(
          opacity: animation,
          child: ScaleTransition(
            scale: scaleIn,
            child: child,
          ),
        );
      },
    );
  }
}

