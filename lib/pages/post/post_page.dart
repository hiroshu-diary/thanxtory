import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:thanxtory/pages/profile/profile_page_two.dart';

import '../../model/constant.dart';
import '../animation/animation_page.dart';
import '../home/home_page.dart';

class PostPage extends StatefulWidget {
  const PostPage({Key? key}) : super(key: key);

  static const path = '/post/';
  static const name = 'PostPage';

  @override
  _PostPageState createState() => _PostPageState();
}

class _PostPageState extends State<PostPage> {
  final _formKey = GlobalKey<FormState>();
  final _userProfiles = FirebaseFirestore.instance.collection('userProfiles');
  final _servedPosts = FirebaseFirestore.instance.collection('servedPosts');
  final _receivedPosts = FirebaseFirestore.instance.collection('receivedPosts');
  final _uid = FirebaseAuth.instance.currentUser!.uid;
  final _storage = FirebaseStorage.instance;
  final searchController = TextEditingController();
  //todo Map
  var nameList = [];
  var idList = [];
  Map<String, String> map = {};

  String _receiverId = '';
  String destination = '';
  String rName = '';
  String rId = '';

  late TextEditingController _textEditingController;
  final storage = FirebaseStorage.instance;
  Future<String> getURLs(String id) async {
    var ref = storage.ref('$id/default_image.jpeg');
    String imageUrl = await ref.getDownloadURL();
    return imageUrl;
  }

  Future<String> getURL() async {
    var ref = _storage.ref('$_uid/default_image.jpeg');
    String imageUrl = await ref.getDownloadURL();
    return imageUrl;
  }

  Future getCount() async {
    final snapshot = await _userProfiles.doc(_uid).get();
    Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;
    final _count = data['todayThanks'];

    setState(() {
      todayThanks = _count;
    });
  }

  @override
  void initState() {
    getCount();
    super.initState();
    _textEditingController = TextEditingController();
    destination = '';
  }

  @override
  void dispose() {
    _textEditingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return todayThanks < 3
        ? Form(
            key: _formKey,
            child: Scaffold(
              resizeToAvoidBottomInset: false,
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
                    Nav.navigate(
                      context,
                      const HomePage(),
                      const Offset(0, 0),
                    );
                  },
                ),
                actions: [
                  CupertinoButton(
                    child: const Text(
                      '投稿する',
                      style: TextStyle(color: C.accentColor),
                    ),
                    onPressed: () async {
                      if (_formKey.currentState!.validate()) {
                        if (destination == 'someone') {
                          _receiverId = rId;
                        } else if (destination == 'me') {
                          _receiverId = _uid;
                        } else {
                          _receiverId = '';
                        }

                        final newPostDoc =
                            _servedPosts.doc(_uid).collection('sPosts').doc();
                        var _postId = newPostDoc.id;
                        await newPostDoc.set({
                          'postId': _postId,
                          'serverId': _uid,
                          'receiverId': _receiverId,
                          'createdAt': Timestamp.fromDate(DateTime.now()),
                          'content': _textEditingController.text,
                          'clapCount': 0,
                        });
                        final _count = todayThanks;

                        await _userProfiles.doc(_uid).update({
                          'todayThanks': FieldValue.increment(1),
                          'servedCount': FieldValue.increment(1),
                        });

                        if (destination != 'none') {
                          await _receivedPosts
                              .doc(_receiverId)
                              .collection('rPosts')
                              .doc(_postId)
                              .set({
                            'postId': _postId,
                            'serverId': _uid,
                            'receiverId': _receiverId,
                            'createdAt': Timestamp.fromDate(DateTime.now()),
                            'content': _textEditingController.text,
                            'clapCount': 0,
                          });
                          await _userProfiles.doc(_uid).update({
                            'receivedCount': FieldValue.increment(1),
                          });
                        }

                        Nav.navigate(
                          context,
                          AnimationPage(count: _count),
                          const Offset(0, -0.5),
                        );
                      }
                    },
                  ),
                ],
              ),
              body: TextFormField(
                autofocus: true,
                controller: _textEditingController,
                validator: (value) {
                  if (_textEditingController.text.length < 5) {
                    return '５字以上入れてください';
                  } else if (_textEditingController.text.length > 139) {
                    return '139字以内にしてください';
                  } else {
                    return null;
                  }
                },
                decoration: InputDecoration(
                  icon: Padding(
                    padding: EdgeInsets.only(
                      left: 16,
                      top: Platform.isIOS ? 16 : 64,
                    ),
                    child: Column(
                      children: [
                        CircleAvatar(
                          backgroundColor: Colors.transparent,
                          radius: 30,
                          child: ClipOval(
                            child: FutureBuilder(
                              future: getURL(),
                              builder: (BuildContext context,
                                  AsyncSnapshot<String> snapshot) {
                                if (snapshot.connectionState ==
                                        ConnectionState.done &&
                                    snapshot.hasData) {
                                  return CachedNetworkImage(
                                    fit: BoxFit.cover,
                                    imageUrl: snapshot.data!,
                                  );
                                }
                                if (snapshot.connectionState ==
                                        ConnectionState.waiting ||
                                    !snapshot.hasData) {
                                  return const CircularProgressIndicator(
                                    color: C.subColor,
                                  );
                                }
                                return Container();
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  border: InputBorder.none,
                  contentPadding:
                      const EdgeInsets.only(left: 4, right: 16, top: 8),
                ),
                maxLines: 10,
                maxLength: 139,
                maxLengthEnforced: false,
                style: const TextStyle(
                  fontSize: 16,
                  fontFamily: 'NotoSansJP',
                  fontWeight: FontWeight.w500,
                ),
              ),
              bottomNavigationBar: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 12,
                ),
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: C.subColor),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  width: double.maxFinite,
                  height: 60,
                  child: CupertinoButton(
                    child: Center(
                      child: Text(
                        destination == '' ? 'Thanxtoryアカウントに贈る' : '$rNameに贈る',
                        style: const TextStyle(
                          color: C.subColor,
                          fontSize: 18,
                          fontFamily: 'NotoSansJP',
                        ),
                      ),
                    ),
                    onPressed: () {
                      Nav.whiteNavi(
                        context,
                        buildSelectPage(context),
                      );
                    },
                  ),
                ),
              ),
            ),
          )
        : Padding(
            padding: const EdgeInsets.all(64.0),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: const [
                  CircleAvatar(
                    maxRadius: 100,
                    backgroundColor: Colors.transparent,
                    backgroundImage: AssetImage('assets/images/max.png'),
                  ),
                  Text(
                    '今日の感謝の最大数を達成しました！\n　\n続きはまた明日。',
                    style: TextStyle(
                      fontSize: 24,
                      color: C.accentColor,
                      fontFamily: 'NotoSansJP',
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
          );
  }

  Center buildSelectPage(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          //List<Map<String,String>>
          //List.where
          //FutureBuilderはいらない→既存から絞り込む
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 32,
              vertical: 24,
            ),
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(color: C.subColor),
                borderRadius: BorderRadius.circular(10),
              ),
              child: CupertinoButton(
                child: const Center(
                  child: Text(
                    'Thanxtoryアカウントを探す',
                    style: TextStyle(
                      color: C.subColor,
                      fontSize: 20,
                      fontFamily: 'NotoSansJP',
                    ),
                  ),
                ),
                onPressed: () {
                  Navigator.pop(context);
                  var _controller = TextEditingController();
                  Nav.whiteNavi(
                    context,
                    buildSearchPage(_controller, context),
                  );
                },
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 32,
              vertical: 24,
            ),
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(color: C.subColor),
                borderRadius: BorderRadius.circular(10),
              ),
              child: CupertinoButton(
                child: const Center(
                  child: Text(
                    '自分に贈る',
                    style: TextStyle(
                      color: C.subColor,
                      fontSize: 20,
                      fontFamily: 'NotoSansJP',
                    ),
                  ),
                ),
                onPressed: () {
                  Navigator.pop(context);
                  setState(() {
                    destination = 'me';
                    rName = '自分';
                    rId = _uid;
                  });
                },
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 32,
              vertical: 24,
            ),
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.black54),
                borderRadius: BorderRadius.circular(10),
              ),
              child: CupertinoButton(
                child: const Center(
                  child: Text(
                    '宛先を指定しない',
                    style: TextStyle(
                      color: Colors.black54,
                      fontSize: 20,
                      fontFamily: 'NotoSansJP',
                    ),
                  ),
                ),
                onPressed: () {
                  Navigator.pop(context);
                  setState(() {
                    destination = '';
                  });
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Scaffold buildSearchPage(
    TextEditingController controller,
    BuildContext context,
  ) {
    return Scaffold(
      body: FutureBuilder(
        future: FirebaseFirestore.instance.collection('userProfiles').get(),
        builder: (
          BuildContext context,
          AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot,
        ) {
          if (snapshot.connectionState == ConnectionState.waiting ||
              !snapshot.hasData) {
            return const Center(
              child: CircleAvatar(
                backgroundColor: Colors.transparent,
                child: SizedBox(
                  width: 240,
                  height: 240,
                  child: CircularProgressIndicator(
                    color: C.subColor,
                  ),
                ),
              ),
            );
          }
          if (snapshot.connectionState == ConnectionState.done) {
            return ListView.builder(
              padding: const EdgeInsets.only(top: 66),
              itemCount: snapshot.data!.docs.length,
              itemBuilder: (context, int index) {
                var _profiles = snapshot.data!.docs[index];
                var _name = _profiles['name'];
                var _id = _profiles.id;
                //todo Map?
                idList.add(_id);
                nameList.add(_name);
                var map = {_id, _name};
                map.addAll(map);
                return GestureDetector(
                  onTap: () => FocusScope.of(context).unfocus(),
                  child: ConstrainedBox(
                    constraints:
                        const BoxConstraints(minWidth: double.maxFinite),
                    child: Card(
                      elevation: 1.0,
                      shadowColor: C.mainColor,
                      margin: const EdgeInsets.only(bottom: 0.5),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: CircleAvatar(
                                backgroundColor: Colors.transparent,
                                radius: 30,
                                child: ClipOval(
                                  child: FutureBuilder(
                                    future: getURLs(_id),
                                    builder: (BuildContext context,
                                        AsyncSnapshot<String> snapshot) {
                                      if (snapshot.connectionState ==
                                              ConnectionState.done &&
                                          snapshot.hasData) {
                                        return CachedNetworkImage(
                                          fit: BoxFit.cover,
                                          imageUrl: snapshot.data!,
                                        );
                                      }
                                      return Container();
                                    },
                                  ),
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                _name.toString(),
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontFamily: 'NotoSansJP',
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            const Spacer(),
                            GestureDetector(
                              child: const Text(
                                '贈る',
                                style: TextStyle(
                                  fontFamily: 'NotoSansJP',
                                  fontSize: 16,
                                  color: C.accentColor,
                                ),
                              ),
                              onTap: () {
                                Navigator.pop(context);
                                setState(() {
                                  destination = 'someone';
                                  rName = _name;
                                  rId = _id;
                                });
                              },
                            ),
                            const SizedBox(width: 36),
                            GestureDetector(
                              child: const Text(
                                '詳しく見る',
                                style: TextStyle(
                                  fontFamily: 'NotoSansJP',
                                  fontSize: 16,
                                  color: Colors.blueAccent,
                                ),
                              ),
                              onTap: () {
                                Nav.whiteNavi(
                                  context,
                                  ProfilePageTwo(userId: _id),
                                );
                              },
                            ),
                            const SizedBox(width: 16),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            );
          }
          return Container();
        },
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.only(
          bottom: 20.0,
          right: 4.0,
          left: 4.0,
          top: 8.0,
        ),
        child: Row(
          children: [
            Expanded(
              flex: 1,
              child: GestureDetector(
                onTap: () => Navigator.pop(context),
                child: const SizedBox(
                  height: 40,
                  child: Center(
                    child: Text(
                      '＜ 戻る',
                      style: TextStyle(
                        color: Colors.black54,
                        fontSize: 16,
                        fontFamily: 'NotoSansJP',
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Expanded(
              flex: 6,
              child: SizedBox(
                height: 50,
                child: ListTile(
                  title: TextFormField(
                    cursorColor: C.accentColor,
                    onFieldSubmitted: (String text) {
                      for (var name in nameList) {
                        if (text.contains(name)) {}
                      }
                    },
                    controller: searchController,
                    textInputAction: TextInputAction.search,
                    decoration: InputDecoration(
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: const BorderSide(
                          color: C.subColor,
                          width: 1.0,
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: const BorderSide(
                          color: Colors.black54,
                          width: 1.0,
                        ),
                      ),
                      hintText: '誰を探す？',
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

///検索値.containsでtrueなら別のリストにidを保存する。→このリストでFutureBuilderをstackでtopに標示する
