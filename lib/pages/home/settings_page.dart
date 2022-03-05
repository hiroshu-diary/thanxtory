import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../model/constant.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final _storage = FirebaseStorage.instance;
  final String _uid = FirebaseAuth.instance.currentUser!.uid;
  final _userProfiles = FirebaseFirestore.instance.collection('userProfiles');
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _introController = TextEditingController();

  Padding _settingForm(
    int maxLines,
    int maxLength,
    TextEditingController controller,
    String label,
  ) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(25.0, 0, 25.0, 0),
      child: TextFormField(
        maxLines: maxLines,
        maxLength: maxLength,
        maxLengthEnforced: false,
        controller: controller,
        cursorColor: C.accentColor,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: C.subColor),
          enabledBorder: const UnderlineInputBorder(
            borderSide: BorderSide(
              color: C.mainColor,
            ),
          ),
          focusedBorder: const UnderlineInputBorder(
            borderSide: BorderSide(color: C.subColor),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        shadowColor: C.accentColor,
        foregroundColor: C.accentColor,
        title: const Text(
          '設定',
          style: TextStyle(
            fontFamily: 'NotoSansJP',
            color: C.accentColor,
            fontSize: 22.0,
            fontWeight: FontWeight.w400,
          ),
        ),
        elevation: 0.0,
        backgroundColor: Colors.white,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _settingForm(1, 10, _nameController, 'ユーザー名'),
            _settingForm(1, 39, _introController, '自己紹介'),
            const SizedBox(height: 200),
          ],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Container(
              width: 140,
              height: 80,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.black54),
                borderRadius: BorderRadius.circular(10),
              ),
              child: CupertinoButton(
                onPressed: () async {
                  Navigator.pop(context);
                },
                child: const Center(
                  child: Text(
                    'キャンセル',
                    style: TextStyle(
                      fontFamily: 'NotoSansJP',
                      color: Colors.black54,
                      fontSize: 20.0,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 16.0),
            child: Container(
              width: 140,
              height: 80,
              decoration: BoxDecoration(
                border: Border.all(color: C.accentColor),
                borderRadius: BorderRadius.circular(10),
              ),
              child: CupertinoButton(
                onPressed: () async {
                  await _userProfiles.doc(_uid).update({
                    'name': _nameController.text,
                    'introduction': _introController.text,
                  });
                  // await _storage
                  //     .ref('$_uid/default_image.jpeg')
                  //     .putFile(_selectedImageFile);
                  Navigator.pop(context);
                },
                child: const Center(
                  child: Text(
                    '更新する',
                    style: TextStyle(
                      fontFamily: 'NotoSansJP',
                      color: C.accentColor,
                      fontSize: 20.0,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
