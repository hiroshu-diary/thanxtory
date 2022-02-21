import 'package:flutter/material.dart';
import 'constant.dart';

class ScaffoldMessengerController<T> {
  final scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();

  Future<T?> showAchievement(String achieveMessage) {
    return showDialog<T>(
      context: scaffoldMessengerKey.currentContext!,
      builder: (context) {
        return AlertDialog(
          contentPadding: const EdgeInsets.all(2.0),
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(
              Radius.circular(20),
            ),
          ),
          content: SizedBox(
            height: 80,
            child: Center(
              child: Text(
                achieveMessage,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: C.accentColor,
                  fontSize: 18,
                  fontFamily: 'NotoSansJP',
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
