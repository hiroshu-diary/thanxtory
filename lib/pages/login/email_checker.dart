import 'dart:io';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../model/constant.dart';

class EmailCheck extends StatefulWidget {
  final String mail;
  final String password;
  final int from;

  const EmailCheck({
    Key? key,
    required this.mail,
    required this.password,
    required this.from,
  }) : super(key: key);

  @override
  _EmailCheck createState() => _EmailCheck();
}

class _EmailCheck extends State<EmailCheck> {
  final _auth = FirebaseAuth.instance;

  late UserCredential _result;
  late String _stateText;
  int _buttonNum = 0;
  var servedPosts = FirebaseFirestore.instance.collection('servedPosts');
  var receivedPosts = FirebaseFirestore.instance.collection('receivedPosts');
  var clappedPosts = FirebaseFirestore.instance.collection('clappedPosts');
  var userProfiles = FirebaseFirestore.instance.collection('userProfiles');
  final storage = FirebaseStorage.instance;

  Future<File> getImageFileFromAssets() async {
    final byteData = await rootBundle.load('assets/default_image.jpeg');
    final directory = await getApplicationDocumentsDirectory();
    final directoryPath = directory.path;
    final file = File('$directoryPath/default_image.jpeg');
    await file.writeAsBytes(byteData.buffer
        .asUint8List(byteData.offsetInBytes, byteData.lengthInBytes));

    return file;
  }

  @override
  Widget build(BuildContext context) {
    // 前画面から遷移後の初期表示内容
    if (_buttonNum == 0) {
      widget.from == 1
          ? _stateText = '${widget.mail}\nに確認メールを送信しました。'
          : 'まだメール確認が完了していません。\n確認メール内のリンクをクリックしてください。';
    }

    return Scaffold(
      // メイン画面
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 確認メール未完了時のメッセージ
            Padding(
              padding: const EdgeInsets.fromLTRB(20.0, 0, 20.0, 20.0),
              child: Text(
                _stateText,
                style: TextStyle(
                  color: widget.from != 1 ? Colors.red : Colors.black,
                ),
              ),
            ),

            SizedBox(
              width: 300,
              child: CupertinoButton(
                padding: EdgeInsets.zero,
                color: Colors.grey,
                child: const Text(
                  '確認メールを再送信',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                onPressed: () async {
                  _result = await _auth.signInWithEmailAndPassword(
                    email: widget.mail,
                    password: widget.password,
                  );

                  _result.user!.sendEmailVerification();
                  setState(() {
                    _buttonNum++;
                    _stateText = '${widget.mail}\nに確認メールを送信しました。';
                  });
                },
              ),
            ),

            // メール確認完了のボタン配置（Home画面に遷移）
            Padding(
              padding: const EdgeInsets.only(top: 40),
              child: SizedBox(
                width: 300,
                child: CupertinoButton(
                  padding: EdgeInsets.zero,
                  color: C.subColor,
                  child: const Text(
                    'メール確認完了',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  onPressed: () async {
                    _result = await _auth.signInWithEmailAndPassword(
                      email: widget.mail,
                      password: widget.password,
                    );

                    //todo ４つのドキュメントを追加

                    if (_result.user!.emailVerified) {
                      final uid = _result.user!.uid;
                      await userProfiles.doc(uid).set({
                        'mail': widget.mail,
                        'name': 'hiroshi',
                        'introduction': 'hiroshiがThanxtoryを始めました。',
                        'todayThanks': 0,
                        'rowCount': 0,
                        'servedCount': 0,
                        'receivedCount': 0
                      });
                      final File f = await getImageFileFromAssets();

                      await storage.ref('$uid/default_image.jpeg').putFile(f);

                      Navigator.pop(context);
                      Navigator.pop(context);
                    } else {
                      setState(() {
                        _buttonNum++;
                        _stateText =
                            "まだメール確認が完了していません。\n確認メール内のリンクをクリックしてください。";
                      });
                    }
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
