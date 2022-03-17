import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

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

  @override
  Widget build(BuildContext context) {
    if (_buttonNum == 0) {
      widget.from == 1
          ? _stateText = '${widget.mail}\nに確認メールを送信しました。'
          : 'まだメール確認が完了していません。\n確認メール内のリンクをクリックしてください。';
    }

    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
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

                    if (_result.user!.emailVerified) {
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
