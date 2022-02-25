import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../model/constant.dart';

class EmailCheck extends StatefulWidget {
  // 呼び出し元Widgetから受け取った後、変更をしないためfinalを宣言。
  final String email;
  final String password;
  final int from;

  const EmailCheck({
    Key? key,
    required this.email,
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
  CollectionReference servedPosts =
      FirebaseFirestore.instance.collection('servedPosts');
  CollectionReference receivedPosts =
      FirebaseFirestore.instance.collection('receivedPosts');
  CollectionReference clappedPosts =
      FirebaseFirestore.instance.collection('clappedPosts');
  CollectionReference userProfiles =
      FirebaseFirestore.instance.collection('userProfiles');

  //todo 値をsetできるようにする
  Future<void> addUser() {
    return userProfiles.doc(_result.user!.uid).set({
      'mail': widget.email,
      'name': "hiroshi",
      'introduction': "i am hiroshi",
      'image': "FireStoreからのレファレンス",
      'todayThanks': 0,
      'rowCount': 0,
      'servedCount': 0,
      'receivedCount': 0
    });
  }

  @override
  Widget build(BuildContext context) {
    // 前画面から遷移後の初期表示内容
    if (_buttonNum == 0) {
      widget.from == 1
          ? _stateText = '${widget.email}\nに確認メールを送信しました。'
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
                    email: widget.email,
                    password: widget.password,
                  );

                  _result.user!.sendEmailVerification();
                  setState(() {
                    _buttonNum++;
                    _stateText = '${widget.email}\nに確認メールを送信しました。';
                  });
                },

                //todo メールを日本語にする
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
                      email: widget.email,
                      password: widget.password,
                    );

                    // Email確認が済んでいる場合は、Home画面へ遷移

                    if (_result.user!.emailVerified) {
                      await addUser();
                      //todo FirestoreにuserIdで４つのコレクション中にサブコレクションを追加
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
