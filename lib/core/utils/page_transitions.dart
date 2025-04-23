import 'package:flutter/material.dart';

/// انتقال مخصص للصفحات مع تأثير التلاشي
class FadePageRoute<T> extends PageRoute<T> {
  final Widget child;
  final Duration duration;

  FadePageRoute({
    required this.child,
    this.duration = const Duration(milliseconds: 300),
  }) : super(
          settings: const RouteSettings(),
          fullscreenDialog: false,
        );

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

/// انتقال مخصص للصفحات مع تأثير الانزلاق
class SlidePageRoute<T> extends PageRoute<T> {
  final Widget child;
  final Duration duration;
  final SlideDirection direction;

  SlidePageRoute({
    required this.child,
    this.duration = const Duration(milliseconds: 300),
    this.direction = SlideDirection.fromRight,
  }) : super(
          settings: const RouteSettings(),
          fullscreenDialog: false,
        );

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
    Offset begin;
    switch (direction) {
      case SlideDirection.fromRight:
        begin = const Offset(1.0, 0.0);
        break;
      case SlideDirection.fromLeft:
        begin = const Offset(-1.0, 0.0);
        break;
      case SlideDirection.fromBottom:
        begin = const Offset(0.0, 1.0);
        break;
      case SlideDirection.fromTop:
        begin = const Offset(0.0, -1.0);
        break;
    }

    return SlideTransition(
      position: Tween<Offset>(
        begin: begin,
        end: Offset.zero,
      ).animate(CurvedAnimation(
        parent: animation,
        curve: Curves.easeOutCubic,
      )),
      child: child,
    );
  }
}

enum SlideDirection {
  fromRight,
  fromLeft,
  fromBottom,
  fromTop,
}

/// دالة مساعدة للانتقال إلى صفحة جديدة مع تأثير التلاشي
Future<T?> navigateWithFade<T>(BuildContext context, Widget page) {
  return Navigator.of(context).push(FadePageRoute<T>(child: page));
}

/// دالة مساعدة للانتقال إلى صفحة جديدة مع تأثير الانزلاق
Future<T?> navigateWithSlide<T>(
  BuildContext context,
  Widget page, {
  SlideDirection direction = SlideDirection.fromRight,
}) {
  return Navigator.of(context).push(
    SlidePageRoute<T>(
      child: page,
      direction: direction,
    ),
  );
}
