import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../home/home_page.dart';

class EmailCheck extends StatefulWidget {
  // 呼び出し元Widgetから受け取った後、変更をしないためfinalを宣言。
  final String email;
  final String password;
  final int from; //1 → アカウント作成画面から    2 → ログイン画面から

  const EmailCheck(
      {Key? key,
      required this.email,
      required this.password,
      required this.from})
      : super(key: key);

  @override
  _EmailCheck createState() => _EmailCheck();
}

class _EmailCheck extends State<EmailCheck> {
  final _auth = FirebaseAuth.instance;
  late UserCredential _result;
  late String _remindMailCheck;
  late String _sentEmailText;
  int _btn_click_num = 0;

  @override
  Widget build(BuildContext context) {
    // 前画面から遷移後の初期表示内容
    if (_btn_click_num == 0) {
      if (widget.from == 1) {
        // アカウント作成画面から遷移した時
        _remindMailCheck = '';
        _sentEmailText = '${widget.email}\nに確認メールを送信しました。';
      } else {
        _remindMailCheck = 'まだメール確認が完了していません。\n確認メール内のリンクをクリックしてください。';
        _sentEmailText = '';
      }
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
                _remindMailCheck,
                style: const TextStyle(color: Colors.red),
              ),
            ),

            // 確認メール送信時のメッセージ
            Text(_sentEmailText),

            // 確認メールの再送信ボタン
            Padding(
              padding: const EdgeInsets.fromLTRB(0, 0, 0, 30.0),
              child: ButtonTheme(
                minWidth: 200.0,
                // height: 100.0,
                child: RaisedButton(
                  // ボタンの形状
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),

                  onPressed: () async {
                    _result = await _auth.signInWithEmailAndPassword(
                      email: widget.email,
                      password: widget.password,
                    );

                    _result.user!.sendEmailVerification();
                    setState(() {
                      _btn_click_num++;
                      _sentEmailText = '${widget.email}\nに確認メールを送信しました。';
                    });
                  },

                  // ボタン内の文字や書式
                  child: const Text(
                    '確認メールを再送信',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  textColor: Colors.white,
                  color: Colors.grey,
                ),
              ),
            ),

            // メール確認完了のボタン配置（Home画面に遷移）
            ButtonTheme(
              minWidth: 350.0,
              // height: 100.0,
              child: ElevatedButton(
                // ボタンの形状

                onPressed: () async {
                  _result = await _auth.signInWithEmailAndPassword(
                    email: widget.email,
                    password: widget.password,
                  );

                  // Email確認が済んでいる場合は、Home画面へ遷移
                  if (_result.user!.emailVerified) {
                    Navigator.push(context, MaterialPageRoute(
                      builder: (context) {
                        // return HomePage(
                        //   user_id: _result.user.uid,
                        //   auth: _auth,
                        // );
                        return Container();
                      },
                    ));
                  } else {
                    // print('NG');
                    setState(() {
                      _btn_click_num++;
                      _remindMailCheck =
                          "まだメール確認が完了していません。\n確認メール内のリンクをクリックしてください。";
                    });
                  }
                },

                // ボタン内の文字や書式
                child: const Text(
                  'メール確認完了',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
