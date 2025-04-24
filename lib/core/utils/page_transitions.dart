import 'package:flutter/material.dart';

/// انتقال مخصص للصفحات مع تأثير التلاشي
class FadePageRoute<T> extends PageRouteBuilder<T> {
  final Widget child;

  FadePageRoute({
    required this.child,
  }) : super(
          pageBuilder: (
            BuildContext context,
            Animation<double> animation,
            Animation<double> secondaryAnimation,
          ) =>
              child,
          transitionDuration: const Duration(milliseconds: 200),
          transitionsBuilder: (
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
            Widget child,
          ) =>
              FadeTransition(
                opacity: CurvedAnimation(
                  parent: animation,
                  curve: Curves.easeInOut,
                ),
                child: child,
              ),
        );
}

/// انتقال مخصص للصفحات مع تأثير الانزلاق
class SlidePageRoute<T> extends PageRouteBuilder<T> {
  final Widget child;
  final SlideDirection direction;

  SlidePageRoute({
    required this.child,
    this.direction = SlideDirection.fromRight,
  }) : super(
          pageBuilder: (
            BuildContext context,
            Animation<double> animation,
            Animation<double> secondaryAnimation,
          ) =>
              child,
          transitionDuration: const Duration(milliseconds: 200),
          transitionsBuilder: (
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
            Widget child,
          ) {
            Offset begin = _getSlideOffset(direction);
            return SlideTransition(
              position: Tween<Offset>(
                begin: begin,
                end: Offset.zero,
              ).animate(CurvedAnimation(
                parent: animation,
                curve: Curves.fastOutSlowIn,
              )),
              child: child,
            );
          },
        );
}

Offset _getSlideOffset(SlideDirection direction) {
  switch (direction) {
    case SlideDirection.fromRight:
      return const Offset(1.0, 0.0);
    case SlideDirection.fromLeft:
      return const Offset(-1.0, 0.0);
    case SlideDirection.fromBottom:
      return const Offset(0.0, 1.0);
    case SlideDirection.fromTop:
      return const Offset(0.0, -1.0);
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
