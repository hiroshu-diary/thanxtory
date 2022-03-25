import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';

import '../../model/constant.dart';
import '../../widgets/lazy_future_builder.dart';

class SettingsPage extends StatefulWidget {
  final String userName;
  final String userIntro;
  const SettingsPage({
    Key? key,
    required this.userName,
    required this.userIntro,
  }) : super(key: key);

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

enum AppState {
  free,
  picked,
  cropped,
}

class _SettingsPageState extends State<SettingsPage> {
  final _storage = FirebaseStorage.instance;
  final String _uid = FirebaseAuth.instance.currentUser!.uid;
  final _userProfiles = FirebaseFirestore.instance.collection('userProfiles');
  late TextEditingController _nameController;
  late TextEditingController _introController;

  late AppState state;
  File? imageFile;

  Padding _settingForm(
    int maxLines,
    int maxLength,
    TextEditingController controller,
    String label,
  ) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(25.0, 0, 25.0, 0),
      child: TextFormField(
        onEditingComplete: () => FocusScope.of(context).unfocus(),
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

  Widget _buildButton() {
    if (state == AppState.free) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          Icon(
            Icons.add,
            color: C.accentColor,
          ),
          Text(
            ' 画像を選ぶ',
            style: TextStyle(color: C.accentColor),
          )
        ],
      );
    } else if (state == AppState.picked) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          Icon(
            Icons.crop,
            color: C.accentColor,
          ),
          Text(
            ' 画像を切り抜く',
            style: TextStyle(color: C.accentColor),
          )
        ],
      );
    } else if (state == AppState.cropped) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          Icon(
            Icons.clear,
            color: C.accentColor,
          ),
          Text(
            ' 画像を削除する',
            style: TextStyle(color: C.accentColor),
          ),
        ],
      );
    } else {
      return Container();
    }
  }

  Future<void> _pickImage() async {
    final pickedImage = await ImagePicker().pickImage(
      source: ImageSource.gallery,
    );

    imageFile = pickedImage != null ? File(pickedImage.path) : null;
    if (imageFile != null) {
      setState(() {
        state = AppState.picked;
      });
    }
  }

  Future<void> _cropImage() async {
    File? croppedFile = await ImageCropper().cropImage(
      sourcePath: imageFile!.path,
      aspectRatioPresets: Platform.isAndroid
          ? [
              CropAspectRatioPreset.square,
              CropAspectRatioPreset.original,
            ]
          : [
              CropAspectRatioPreset.square,
              CropAspectRatioPreset.original,
            ],
      uiSettings: [
        AndroidUiSettings(
          toolbarTitle: 'Cropper',
          toolbarColor: Colors.deepOrange,
          toolbarWidgetColor: Colors.white,
          initAspectRatio: CropAspectRatioPreset.original,
          lockAspectRatio: false,
        ),
        IOSUiSettings(
          title: 'Cropper',
        ),
      ],
    );
    if (croppedFile != null) {
      imageFile = croppedFile;
      setState(() {
        state = AppState.cropped;
      });
    }
  }

  void _clearImage() {
    imageFile = null;
    setState(() {
      state = AppState.free;
    });
  }

  @override
  void initState() {
    state = AppState.free;
    _nameController = TextEditingController(text: widget.userName);
    _introController = TextEditingController(text: widget.userIntro);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0.0,
        backgroundColor: Colors.transparent,
        leadingWidth: double.maxFinite,
        leading: CupertinoButton(
          child: const Text(
            'キャンセル',
            style: TextStyle(color: Colors.black87),
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        actions: [
          LazyFutureBuilder(
            futureBuilder: () async {
              if (_nameController.text.length > 1 &&
                  _introController.text.isNotEmpty) {
                await _userProfiles.doc(_uid).update({
                  'name': _nameController.text,
                  'introduction': _introController.text,
                });
              }
              if (imageFile != null) {
                await _storage
                    .ref('$_uid/default_image.jpeg')
                    .putFile(imageFile!);
              }
              Navigator.pop(context);
            },
            builder: (context, futureBuilder, isFutureBuilding) {
              return CupertinoButton(
                onPressed: isFutureBuilding ? null : futureBuilder,
                child: AnimatedCrossFade(
                  layoutBuilder: (first, _, second, __) => IntrinsicWidth(
                    child: IntrinsicHeight(
                      child: Stack(
                        alignment: Alignment.center,
                        children: <Widget>[
                          first,
                          second,
                        ],
                      ),
                    ),
                  ),
                  firstChild: const Text(
                    '更新する',
                    style: TextStyle(color: C.accentColor),
                  ),
                  secondChild: const SpinKitThreeBounce(
                    color: C.accentColor,
                    size: 16,
                  ),
                  crossFadeState: isFutureBuilding
                      ? CrossFadeState.showSecond
                      : CrossFadeState.showFirst,
                  duration: const Duration(milliseconds: 200),
                ),
              );
            },
          ),
        ],
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: SingleChildScrollView(
          child: Center(
            child: Column(
              children: [
                Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: SizedBox(
                      width: 200,
                      height: 200,
                      child: imageFile != null
                          ? Image.file(imageFile!)
                          : Container(),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  child: SizedBox(
                    width: 160,
                    child: CupertinoButton(
                      padding: EdgeInsets.zero,
                      color: C.mainColor,
                      onPressed: () {
                        if (state == AppState.free) {
                          _pickImage();
                        } else if (state == AppState.picked) {
                          _cropImage();
                        } else if (state == AppState.cropped) {
                          _clearImage();
                        }
                      },
                      child: Center(child: _buildButton()),
                    ),
                  ),
                ),
                _settingForm(1, 10, _nameController, 'ユーザー名'),
                _settingForm(1, 21, _introController, '自己紹介'),
                SizedBox(height: MediaQuery.of(context).viewInsets.bottom),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
