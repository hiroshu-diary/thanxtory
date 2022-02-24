import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:thanxtory/pages/login/auth_error.dart';
import 'package:thanxtory/pages/login/email_checker.dart';
import 'package:thanxtory/pages/login/registraion_page.dart';

class Login extends StatefulWidget {
  @override
  _Login createState() => _Login();
}

class _Login extends State<Login> {
  // Firebase 認証
  final _auth = FirebaseAuth.instance;
  late UserCredential _result;
  late User _user;

  String _mail = ""; // 入力されたメールアドレス
  String _password = ""; // 入力されたパスワード
  String _infoText = ""; // ログインに関する情報を表示

  // エラーメッセージを日本語化するためのクラス
  final authError = AuthenticationError();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            // メールアドレスの入力フォーム
            Padding(
                padding: const EdgeInsets.fromLTRB(25.0, 0, 25.0, 0),
                child: TextFormField(
                  decoration: const InputDecoration(labelText: "メールアドレス"),
                  onChanged: (String value) {
                    _mail = value;
                  },
                )),

            // パスワードの入力フォーム
            Padding(
              padding: const EdgeInsets.fromLTRB(25.0, 0, 25.0, 10.0),
              child: TextFormField(
                decoration: const InputDecoration(labelText: "パスワード（8～20文字）"),
                obscureText: true, // パスワードが見えないようRにする
                maxLength: 20, // 入力可能な文字数
                maxLengthEnforced: false, // 入力可能な文字数の制限を超える場合の挙動の制御
                onChanged: (String value) {
                  _password = value;
                },
              ),
            ),

            // ログイン失敗時のエラーメッセージ
            Padding(
              padding: const EdgeInsets.fromLTRB(20.0, 0, 20.0, 5.0),
              child: Text(
                _infoText,
                style: const TextStyle(color: Colors.red),
              ),
            ),

            // ログインボタンの配置
            ButtonTheme(
              minWidth: 350.0,
              // height: 100.0,
              child: RaisedButton(
                // ボタンの形状
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),

                onPressed: () async {
                  try {
                    // メール/パスワードでログイン
                    _result = await _auth.signInWithEmailAndPassword(
                      email: _mail,
                      password: _password,
                    );

                    // ログイン成功
                    _user = _result.user!; // ログインユーザーのIDを取得

                    // Email確認が済んでいる場合のみHome画面へ
                    if (_user.emailVerified) {
                      Navigator.push(context, MaterialPageRoute(
                        builder: (context) {
                          return Container();
                          // Home(user_id: _user.uid, auth: _auth)
                        },
                      ));
                    } else {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) {
                            return EmailCheck(
                              email: _mail,
                              password: _password,
                              from: 2,
                            );
                          },
                        ),
                      );
                    }
                  } catch (e) {
                    // ログインに失敗した場合
                    setState(() {
                      _infoText = authError.loginErrorMsg(e.toString());
                    });
                  }
                },

                // ボタン内の文字や書式
                child: const Text(
                  'ログイン',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                textColor: Colors.white,
                color: Colors.blue,
              ),
            ),

            // ログイン失敗時のエラーメッセージ
            TextButton(
              child: const Text('上記メールアドレスにパスワード再設定メールを送信'),
              onPressed: () => _auth.sendPasswordResetEmail(email: _mail),
            ),
          ],
        ),
      ),

      // 画面下にアカウント作成画面への遷移ボタンを配置
      bottomNavigationBar:
          Column(mainAxisSize: MainAxisSize.min, children: <Widget>[
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: ButtonTheme(
            minWidth: 350.0,
            // height: 100.0,
            child: RaisedButton(
                child: const Text(
                  'アカウントを作成する',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                textColor: Colors.blue,
                color: Colors.blue[50],
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),

                // ボタンクリック後にアカウント作成用の画面の遷移する。
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      fullscreenDialog: true,
                      builder: (BuildContext context) => const Registration(),
                    ),
                  );
                }),
          ),
        ),
      ]),
    );
  }
}
