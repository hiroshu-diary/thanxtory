import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../model/constant.dart';

Center selectionPage(BuildContext context) {
  return Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 32,
            vertical: 24,
          ),
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(color: C.subColor),
              borderRadius: BorderRadius.circular(10),
            ),
            child: CupertinoButton(
              child: const Center(
                child: Text(
                  'Thanxtoryアカウントを探す',
                  style: TextStyle(
                    color: C.subColor,
                    fontSize: 20,
                    fontFamily: 'NotoSansJP',
                  ),
                ),
              ),
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) {
                  return Scaffold(
                    body: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text('アカウントを検索して選ぶページ'),
                          MaterialButton(
                            color: Colors.pinkAccent,
                            child: const Text('戻るボタン'),
                            onPressed: () {
                              Navigator.pop(context);
                              Navigator.pop(context);
                            },
                          ),
                        ],
                      ),
                    ),
                  );
                }));
              },
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 32,
            vertical: 24,
          ),
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(color: C.subColor),
              borderRadius: BorderRadius.circular(10),
            ),
            child: CupertinoButton(
              child: const Center(
                child: Text(
                  '自分に贈る',
                  style: TextStyle(
                    color: C.subColor,
                    fontSize: 20,
                    fontFamily: 'NotoSansJP',
                  ),
                ),
              ),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 32,
            vertical: 24,
          ),
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.black54),
              borderRadius: BorderRadius.circular(10),
            ),
            child: CupertinoButton(
              child: const Center(
                child: Text(
                  '宛先を指定しない',
                  style: TextStyle(
                    color: Colors.black54,
                    fontSize: 20,
                    fontFamily: 'NotoSansJP',
                  ),
                ),
              ),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ),
        ),
      ],
    ),
  );
}
