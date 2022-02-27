import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:thanxtory/pages/login/auth_error.dart';
import 'package:thanxtory/pages/login/email_checker.dart';
import 'package:thanxtory/pages/login/registration_page.dart';

import '../../model/constant.dart';
//todo エラーメッセージの日本語化

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  _Login createState() => _Login();
}

class _Login extends State<LoginPage> {
  final _auth = FirebaseAuth.instance;
  late UserCredential _result;
  late User _user;

  String _mail = "";
  String _password = "";
  String _infoText = "";

  // エラーメッセージを日本語化するためのクラス
  final authError = AuthenticationError();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Padding(
              padding: EdgeInsets.only(bottom: 80),
              child: Text(
                'Thanxtory',
                style: TextStyle(
                  color: C.accentColor,
                  fontSize: 39,
                  fontWeight: FontWeight.w500,
                  fontFamily: 'NotoSansJP',
                ),
              ),
            ),
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

            SizedBox(
              width: 300,
              child: CupertinoButton(
                padding: EdgeInsets.zero,
                color: C.subColor,
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
                              mail: _mail,
                              password: _password,
                              from: 2,
                            );
                          },
                        ),
                      );
                    }
                  } on FirebaseAuthException catch (e) {
                    // ログインに失敗した場合
                    setState(() {
                      _infoText = authError.loginErrorMsg(e.code);
                    });
                  }
                },

                // ボタン内の文字や書式
                child: const Text(
                  'ログイン',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 18,
                  ),
                ),
              ),
            ),

            // ログイン失敗時のエラーメッセージ
            Padding(
              padding: const EdgeInsets.only(top: 20),
              child: CupertinoButton(
                padding: EdgeInsets.zero,
                child: const Text(
                  '上記メールアドレスにパスワード再設定メールを送信',
                  style: TextStyle(
                    color: C.accentColor,
                    fontSize: 14,
                  ),
                ),
                onPressed: () => _auth.sendPasswordResetEmail(email: _mail),
              ),
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
            SizedBox(
              width: 300,
              child: CupertinoButton(
                padding: EdgeInsets.zero,
                child: const Text(
                  'アカウントを作成する',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: C.accentColor,
                  ),
                ),
                color: C.mainColor,
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      fullscreenDialog: true,
                      builder: (BuildContext context) {
                        return const Registration();
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
