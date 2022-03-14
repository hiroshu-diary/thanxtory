import 'dart:io';

import 'package:anim_search_bar/anim_search_bar.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

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
                        Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
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
                                      var controller = TextEditingController();
                                      Nav.whiteNavi(
                                        context,
                                        Scaffold(
                                          appBar: PreferredSize(
                                            preferredSize: const Size(
                                              400,
                                              44.0,
                                            ),
                                            child: SafeArea(
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 8.0),
                                                child: AnimSearchBar(
                                                  width: 400,
                                                  autoFocus: true,
                                                  textController: controller,
                                                  onSuffixTap: () {
                                                    setState(() {
                                                      controller.clear();
                                                    });
                                                  },
                                                ),
                                              ),
                                            ),
                                          ),
                                          body: FutureBuilder(
                                            future: FirebaseFirestore.instance
                                                .collection('userProfiles')
                                                .get(),
                                            builder: (
                                              BuildContext context,
                                              AsyncSnapshot<
                                                      QuerySnapshot<
                                                          Map<String, dynamic>>>
                                                  snapshot,
                                            ) {
                                              if (snapshot.connectionState ==
                                                      ConnectionState.waiting ||
                                                  !snapshot.hasData) {
                                                return const Center(
                                                  child: CircleAvatar(
                                                    backgroundColor:
                                                        Colors.transparent,
                                                    child: SizedBox(
                                                      width: 240,
                                                      height: 240,
                                                      child:
                                                          CircularProgressIndicator(
                                                        color: C.subColor,
                                                      ),
                                                    ),
                                                  ),
                                                );
                                              }
                                              if (snapshot.connectionState ==
                                                  ConnectionState.done) {
                                                return ListView.builder(
                                                  padding: EdgeInsets.zero,
                                                  itemCount: snapshot
                                                      .data!.docs.length,
                                                  itemBuilder:
                                                      (context, int index) {
                                                    var _profiles = snapshot
                                                        .data!.docs[index];
                                                    var _name =
                                                        _profiles['name'];
                                                    var _id = _profiles.id;
                                                    return ConstrainedBox(
                                                      constraints:
                                                          const BoxConstraints(
                                                              minWidth: double
                                                                  .maxFinite),
                                                      child: Card(
                                                        elevation: 1.0,
                                                        shadowColor:
                                                            C.mainColor,
                                                        margin: const EdgeInsets
                                                            .only(bottom: 0.5),
                                                        child: Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .all(8.0),
                                                          child: Row(
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .start,
                                                            children: [
                                                              Padding(
                                                                padding:
                                                                    const EdgeInsets
                                                                            .all(
                                                                        8.0),
                                                                child:
                                                                    CircleAvatar(
                                                                  backgroundColor:
                                                                      Colors
                                                                          .transparent,
                                                                  radius: 30,
                                                                  child:
                                                                      ClipOval(
                                                                    child:
                                                                        FutureBuilder(
                                                                      future:
                                                                          getURLs(
                                                                              _id),
                                                                      builder: (BuildContext
                                                                              context,
                                                                          AsyncSnapshot<String>
                                                                              snapshot) {
                                                                        if (snapshot.connectionState ==
                                                                                ConnectionState.done &&
                                                                            snapshot.hasData) {
                                                                          return CachedNetworkImage(
                                                                            fit:
                                                                                BoxFit.cover,
                                                                            imageUrl:
                                                                                snapshot.data!,
                                                                          );
                                                                        }
                                                                        return Container();
                                                                      },
                                                                    ),
                                                                  ),
                                                                ),
                                                              ),
                                                              Padding(
                                                                padding:
                                                                    const EdgeInsets
                                                                            .all(
                                                                        8.0),
                                                                child: Text(
                                                                  _name
                                                                      .toString(),
                                                                  style:
                                                                      const TextStyle(
                                                                    fontSize:
                                                                        18,
                                                                    fontFamily:
                                                                        'NotoSansJP',
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w600,
                                                                  ),
                                                                ),
                                                              ),
                                                              const Spacer(),
                                                              GestureDetector(
                                                                child:
                                                                    const Text(
                                                                  '贈る',
                                                                  style: TextStyle(
                                                                      color: C
                                                                          .accentColor),
                                                                ),
                                                                onTap: () {
                                                                  Navigator.pop(
                                                                      context);
                                                                  setState(() {
                                                                    destination =
                                                                        'someone';
                                                                    rName =
                                                                        _name;
                                                                    rId = _id;
                                                                  });
                                                                },
                                                              ),
                                                              const SizedBox(
                                                                  width: 39),
                                                              GestureDetector(
                                                                child:
                                                                    const Text(
                                                                  '詳しく見る',
                                                                  style: TextStyle(
                                                                      color: Colors
                                                                          .blueAccent),
                                                                ),
                                                                onTap: () {},
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                      ),
                                                    );
                                                    ;
                                                  },
                                                );
                                              }
                                              return Container();
                                            },
                                          ),
                                        ),
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
                                        destination = 'none';
                                      });
                                    },
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
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
}
