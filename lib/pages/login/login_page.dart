import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:thanxtory/pages/login/auth_error.dart';
import 'package:thanxtory/pages/login/email_checker.dart';
import 'package:thanxtory/pages/login/registration_page.dart';

import '../../model/constant.dart';
import '../../model/form_helper.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  _Login createState() => _Login();
}

class _Login extends State<LoginPage> {
  final _auth = FirebaseAuth.instance;
  late UserCredential _result;
  late User _user;
  final authError = AuthenticationError();
  String _infoText = '';

  final TextEditingController _mailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void dispose() {
    _mailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

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
            editForm(_mailController, 'メールアドレス'),
            pWForm(_passwordController),
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
                    _result = await _auth.signInWithEmailAndPassword(
                      email: _mailController.text,
                      password: _passwordController.text,
                    );
                    _user = _result.user!;
                    if (_user.emailVerified) {
                    } else {
                      Nav.whiteNavi(
                        context,
                        EmailCheck(
                          mail: _mailController.text,
                          password: _passwordController.text,
                          from: 2,
                        ),
                      );
                    }
                  } on FirebaseAuthException catch (e) {
                    setState(() {
                      _infoText = authError.loginErrorMsg(e.code);
                    });
                  }
                },
                child: const Text(
                  'ログイン',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 18,
                  ),
                ),
              ),
            ),
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
                onPressed: () {
                  _auth.sendPasswordResetEmail(email: _mailController.text);
                },
              ),
            ),
          ],
        ),
      ),
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
