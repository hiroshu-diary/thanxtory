import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:thanxtory/pages/login/auth_error.dart';
import 'package:thanxtory/pages/login/email_checker.dart';

// アカウント登録ページ
class Registration extends StatefulWidget {
  const Registration({Key? key}) : super(key: key);

  @override
  _RegistrationState createState() => _RegistrationState();
}

class _RegistrationState extends State<Registration> {
  // Firebase Authenticationを利用するためのインスタンス
  final _auth = FirebaseAuth.instance;
  late UserCredential _result;
  late User _user;

  String _mail = ""; // 入力されたメールアドレス
  String _password = ""; // 入力されたパスワード
  String _infoText = ""; // 登録に関する情報を表示
  bool _isActivePassword = false; // パスワードが有効な文字数を満たしているかどうか

  // エラーメッセージを日本語化するためのクラス
  final authError = AuthenticationError();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            const Padding(
              padding: EdgeInsets.fromLTRB(25.0, 0, 25.0, 30.0),
              child: Text(
                '新規アカウントの作成',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),

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
                    if (value.length >= 8) {
                      _password = value;
                      _isActivePassword = true;
                    } else {
                      _isActivePassword = false;
                    }
                  }),
            ),

            // 登録失敗時のエラーメッセージ
            Padding(
              padding: const EdgeInsets.fromLTRB(20.0, 0, 20.0, 5.0),
              child: Text(
                _infoText,
                style: const TextStyle(color: Colors.red),
              ),
            ),

            // アカウント作成のボタン配置
            ButtonTheme(
              minWidth: 350.0,
              // height: 100.0,
              child: RaisedButton(
                child: const Text(
                  '登録',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                textColor: Colors.white,
                color: Colors.blue,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                onPressed: () async {
                  if (_isActivePassword) {
                    try {
                      // メール/パスワードでユーザー登録
                      _result = await _auth.createUserWithEmailAndPassword(
                        email: _mail,
                        password: _password,
                      );

                      // 登録成功
                      _user = _result.user!; // 登録したユーザー情報
                      _user.sendEmailVerification(); // Email確認のメールを送信
                      Navigator.push(context, MaterialPageRoute(
                        builder: (context) {
                          return EmailCheck(
                            email: _mail,
                            password: _password,
                            from: 1,
                          );
                        },
                      ));
                    } catch (e) {
                      // 登録に失敗した場合
                      setState(() {
                        _infoText = authError.registerErrorMsg(e.toString());
                      });
                    }
                  } else {
                    setState(() {
                      _infoText = 'パスワードは8文字以上です。';
                    });
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
