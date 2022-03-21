import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:thanxtory/model/constant.dart';
import 'package:thanxtory/pages/login/auth_error.dart';
import 'package:thanxtory/pages/login/email_checker.dart';

import '../../model/form_helper.dart';

class Registration extends StatefulWidget {
  const Registration({Key? key}) : super(key: key);

  @override
  _RegistrationState createState() => _RegistrationState();
}

class _RegistrationState extends State<Registration> {
  final _auth = FirebaseAuth.instance;
  final storage = FirebaseStorage.instance;
  final userProfiles = FirebaseFirestore.instance.collection('userProfiles');

  late User _user;
  late UserCredential _result;

  String _infoText = '';
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _mailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  final authError = AuthenticationError();

  Future<void> setUserProfiles(String uid, String mail, String name) {
    return userProfiles.doc(uid).set({
      'mail': mail,
      'name': name,
      'introduction': 'Thanxtory、始めました！',
      'todayThanks': 0,
      'servedCount': 0,
      'receivedCount': 0
    });
  }

  Future<File> getImageFileFromAssets() async {
    final byteData = await rootBundle.load('assets/default_image.jpeg');
    final directory = await getApplicationDocumentsDirectory();
    final directoryPath = directory.path;
    final file = File('$directoryPath/default_image.jpeg');
    await file.writeAsBytes(
      byteData.buffer.asUint8List(
        byteData.offsetInBytes,
        byteData.lengthInBytes,
      ),
    );

    return file;
  }

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
            editForm(_nameController, 'ユーザー名（変更可）', true),
            editForm(_mailController, 'メールアドレス', false),
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

                      final uid = _result.user!.uid;
                      await setUserProfiles(
                          uid, _mailController.text, _nameController.text);

                      final File f = await getImageFileFromAssets();

                      await storage.ref('$uid/default_image.jpeg').putFile(f);

                      Nav.whiteNavi(
                        context,
                        EmailCheck(
                          mail: _mailController.text,
                          password: _passwordController.text,
                          from: 1,
                        ),
                        600,
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
