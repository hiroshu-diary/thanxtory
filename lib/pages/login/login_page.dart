import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:thanxtory/main.dart';
import 'package:thanxtory/pages/login/auth_error.dart';
import 'package:thanxtory/pages/login/email_checker.dart';
import 'package:thanxtory/pages/login/registraion_page.dart';

import '../../model/constant.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  _Login createState() => _Login();
}

class _Login extends State<LoginPage> {
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
                cursorColor: C.accentColor,
                decoration: const InputDecoration(
                  labelText: 'メールアドレス',
                  labelStyle: TextStyle(color: C.subColor),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(
                      color: C.mainColor,
                    ),
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: C.subColor),
                  ),
                ),
                onChanged: (String value) {
                  _mail = value;
                },
              ),
            ),

            // パスワードの入力フォーム
            Padding(
              padding: const EdgeInsets.fromLTRB(25.0, 0, 25.0, 10.0),
              child: TextFormField(
                cursorColor: C.accentColor,
                decoration: const InputDecoration(
                  labelText: 'パスワード（8～20文字）',
                  labelStyle: TextStyle(color: C.subColor),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(
                      color: C.mainColor,
                    ),
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: C.subColor),
                  ),
                ),
                obscureText: true,
                maxLength: 20,
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
              minWidth: 330.0,
              child: MaterialButton(
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
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
                textColor: Colors.white,
                color: C.subColor,
              ),
            ),

            // ログイン失敗時のエラーメッセージ
            TextButton(
              child: const Text(
                '上記メールアドレスにパスワード再設定メールを送信',
                style: TextStyle(color: C.accentColor),
              ),
              onPressed: () => _auth.sendPasswordResetEmail(email: _mail),
            ),
          ],
        ),
      ),

      // 画面下にアカウント作成画面への遷移ボタンを配置
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.only(bottom: 40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: ButtonTheme(
                minWidth: 330.0,
                child: MaterialButton(
                  child: const Text(
                    'アカウントを作成する',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  textColor: C.accentColor,
                  color: C.mainColor,
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
