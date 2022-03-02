import 'package:flutter/material.dart';

class C {
  static const Color mainColor = Color.fromARGB(255, 255, 200, 255);
  static const Color subColor = Color.fromARGB(255, 255, 90, 255);
  static const Color accentColor = Color.fromARGB(255, 255, 0, 255);
}

class Nav {
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
}

///グローバル変数
bool timeSequence = true;
//todo todayThanksをFirestoreからのみ取得へ変更、データをFirestoreに置く、prefsは排除
int todayThanks = 0;
int lastPostDay = 20220213;
//todo 連続達成したら++、達成できなかったら0↓
int consecutiveNum = 25;
