import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:thanxtory/model/constant.dart';
import 'package:thanxtory/pages/login/auth_error.dart';
import 'package:thanxtory/pages/login/email_checker.dart';

import 'form_helper.dart';

class Registration extends StatefulWidget {
  const Registration({Key? key}) : super(key: key);

  @override
  _RegistrationState createState() => _RegistrationState();
}

class _RegistrationState extends State<Registration> {
  final _auth = FirebaseAuth.instance;
  late UserCredential _result;
  late User _user;

  String _infoText = '';
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _mailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  final authError = AuthenticationError();

  @override
  void dispose() {
    _nameController.dispose();
    _mailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

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
            editForm(_nameController, 'ユーザー名（変更可）'),
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
                child: const Text(
                  '登録',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: Colors.white,
                  ),
                ),
                color: C.subColor,
                onPressed: () async {
                  if (_passwordController.text.length >= 8) {
                    try {
                      _result = await _auth.createUserWithEmailAndPassword(
                        email: _mailController.text,
                        password: _passwordController.text,
                      );

                      _user = _result.user!;
                      _user.sendEmailVerification();
                      Nav.whiteNavi(
                        context,
                        EmailCheck(
                          name: _nameController.text,
                          mail: _mailController.text,
                          password: _passwordController.text,
                          from: 1,
                        ),
                      );
                    } on FirebaseAuthException catch (e) {
                      setState(() {
                        _infoText = authError.registerErrorMsg(e.code);
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
