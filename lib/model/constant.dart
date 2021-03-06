import 'package:flutter/material.dart';

///グローバル変数
bool timeSequence = true;

class C {
  static const Color mainColor = Color.fromARGB(255, 255, 200, 255);
  static const Color subColor = Color.fromARGB(255, 255, 90, 255);
  static const Color accentColor = Color.fromARGB(255, 255, 0, 255);
}

class Nav {
  ///方向指定可能、ただしpushReplacement
  static Future<dynamic> navigate(
    BuildContext context,
    Widget returnContext,
    Offset beginOffset,
  ) {
    return Navigator.of(context).pushReplacement(
      PageRouteBuilder(pageBuilder: (
        BuildContext? context,
        Animation? animation,
        Animation? secondaryAnimation,
      ) {
        return returnContext;
      }, transitionsBuilder: (
        BuildContext context,
        Animation<double>? animation,
        Animation? secondaryAnimation,
        Widget? child,
      ) {
        return SlideTransition(
          position: Tween(
            begin: beginOffset,
            end: Offset.zero,
          ).animate(animation!),
          child: child,
        );
      }),
    );
  }

  ///Dialog用のNavigator
  static Future<dynamic> popUntil(
    BuildContext context,
    Widget returnContext,
    Offset beginOffset,
  ) {
    return Navigator.of(context).pushReplacement(
      PageRouteBuilder(pageBuilder: (
        BuildContext? context,
        Animation? animation,
        Animation? secondaryAnimation,
      ) {
        return returnContext;
      }, transitionsBuilder: (
        BuildContext context,
        Animation<double>? animation,
        Animation? secondaryAnimation,
        Widget? child,
      ) {
        return SlideTransition(
          position: Tween(
            begin: beginOffset,
            end: Offset.zero,
          ).animate(animation!),
          child: child,
        );
      }),
    );
  }

  ///全方向移動のNavigator.push
  static void navigate360(BuildContext context, Offset offset, Widget page) {
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) {
          return page;
        },
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          final Offset begin = offset; // 下から上
          const Offset end = Offset.zero;
          final Animatable<Offset> tween = Tween(begin: begin, end: end)
              .chain(CurveTween(curve: Curves.easeInOut));
          final Animation<Offset> offsetAnimation = animation.drive(tween);
          return SlideTransition(
            position: offsetAnimation,
            child: child,
          );
        },
      ),
    );
  }

  ///ホワイトアウトorブラックアウト
  static void whiteNavi(
    BuildContext context,
    Widget page,
    int length,
  ) {
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) {
          return page;
        },
        transitionDuration: Duration(milliseconds: length),
        reverseTransitionDuration: Duration(milliseconds: length),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          final color = ColorTween(
            begin: Colors.transparent,
            // end: Colors.black, // ブラックアウト
            end: Colors.white, // ホワイトアウト
          ).animate(CurvedAnimation(
            parent: animation,
            // 前半
            curve: const Interval(
              0.0,
              0.5,
              curve: Curves.easeInOut,
            ),
          ));
          final opacity = Tween<double>(
            begin: 0.0,
            end: 1.0,
          ).animate(CurvedAnimation(
            parent: animation,
            // 後半
            curve: const Interval(
              0.5,
              1.0,
              curve: Curves.easeInOut,
            ),
          ));
          return AnimatedBuilder(
            animation: animation,
            builder: (context, child) {
              return Container(
                color: color.value,
                child: Opacity(
                  opacity: opacity.value,
                  child: child,
                ),
              );
            },
            child: child,
          );
        },
      ),
    );
  }

  ///フェード
  static void fadeNavi(BuildContext context, Widget page) {
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) {
          return page;
        },
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const double begin = 0.0;
          const double end = 1.0;
          final Animatable<double> tween = Tween(begin: begin, end: end)
              .chain(CurveTween(curve: Curves.easeInOut));
          final Animation<double> doubleAnimation = animation.drive(tween);
          return FadeTransition(
            opacity: doubleAnimation,
            child: child,
          );
        },
      ),
    );
  }
}

class Scroller {
  static void scrollToTop(scrollController) {
    final topOffset = scrollController.position.minScrollExtent;
    scrollController.animateTo(
      topOffset,
      duration: const Duration(milliseconds: 390),
      curve: Curves.easeIn,
    );
  }
}

class Style {
  static TextStyle countStyle() {
    return const TextStyle(
      fontFamily: 'NotoSansJP',
      fontSize: 26,
      fontWeight: FontWeight.bold,
      color: C.subColor,
    );
  }
}

class Tile {
  static InkWell buildTile(Icon icon, String title, VoidCallback onTap,
      [Widget? trailing]) {
    return InkWell(
      onTap: onTap,
      splashColor: C.mainColor,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: ListTile(
          leading: Padding(
            padding: const EdgeInsets.only(left: 8.0),
            child: icon,
          ),
          title: Text(
            title,
            style: const TextStyle(
              fontSize: 20.0,
              fontFamily: 'NotoSansJP',
              fontWeight: FontWeight.w500,
            ),
          ),
          trailing: trailing,
        ),
      ),
    );
  }
}

class AllUser {
  late String id;
  late String name;

  AllUser({
    required this.id,
    required this.name,
  });
}
