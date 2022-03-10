import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:like_button/like_button.dart';

import '../model/constant.dart';
import '../pages/profile/profile_page_two.dart';

class ContentCard extends StatefulWidget {
  final String postId;
  final String serverId;
  final String receiverId;
  final int clapCount;
  final String content;
  final DateTime createdAt;

  const ContentCard({
    Key? key,
    required this.postId,
    required this.serverId,
    required this.receiverId,
    required this.clapCount,
    required this.content,
    required this.createdAt,
  }) : super(key: key);

  @override
  _ContentCardState createState() => _ContentCardState();
}

class _ContentCardState extends State<ContentCard> {
  final _storage = FirebaseStorage.instance;
  final _uid = FirebaseAuth.instance.currentUser!.uid;
  final _userProfiles = FirebaseFirestore.instance.collection('userProfiles');
  final _servedPosts = FirebaseFirestore.instance.collection('servedPosts');
  final _receivedPosts = FirebaseFirestore.instance.collection('receivedPosts');
  final _clappedPosts = FirebaseFirestore.instance.collection('clappedPosts');

  late String _postId;
  late String _serverId;
  late String _receiverId;
  late String _createdAt;
  late String _content;
  late int _clapCount;
  bool isClapped = false;
  Future getBoolean() async {
    try {
      final snapshot =
          await _clappedPosts.doc(_uid).collection('cPosts').doc(_postId).get();
      Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;
      setState(() {
        isClapped = true;
      });
    } catch (e) {
      isClapped = false;
    }
  }

  @override
  void initState() {
    super.initState();
    _postId = widget.postId;
    getBoolean();
    _serverId = widget.serverId;
    _receiverId = widget.receiverId;
    _createdAt = fromAtNow(widget.createdAt);
    _content = widget.content;
    _clapCount = widget.clapCount;
  }

  Future<bool> _onLikeButtonTapped(bool isLiked) async {
    if (isLiked == false) {
      await _clappedPosts.doc(_uid).collection('cPosts').doc(_postId).set({
        'postId': _postId,
        'serverId': _serverId,
        'clappedAt': Timestamp.fromDate(DateTime.now()),
      });
      await _servedPosts
          .doc(_serverId)
          .collection('sPosts')
          .doc(_postId)
          .update({
        'clapCount': FieldValue.increment(1),
      });
      await _servedPosts
          .doc(_serverId)
          .collection('sPosts')
          .doc(_postId)
          .collection('clappedByUsers')
          .doc(_uid)
          .set({
        'userId': _uid,
        'createdAt': Timestamp.fromDate(DateTime.now()),
      });
      if (_receiverId != '') {
        await _receivedPosts
            .doc(_receiverId)
            .collection('rPosts')
            .doc(_postId)
            .update({
          'clapCount': FieldValue.increment(1),
        });
        await _receivedPosts
            .doc(_receiverId)
            .collection('rPosts')
            .doc(_postId)
            .collection('clappedByUsers')
            .doc(_uid)
            .set({
          'userId': _uid,
          'createdAt': Timestamp.fromDate(DateTime.now()),
        });
      }
      return !isLiked;
    } else {
      await _clappedPosts.doc(_uid).collection('cPosts').doc(_postId).delete();
      await _servedPosts
          .doc(_serverId)
          .collection('sPosts')
          .doc(_postId)
          .update({
        'clapCount': FieldValue.increment(-1),
      });
      await _servedPosts
          .doc(_serverId)
          .collection('sPosts')
          .doc(_postId)
          .collection('clappedByUsers')
          .doc(_uid)
          .delete();
      if (_receiverId != '') {
        await _receivedPosts
            .doc(_receiverId)
            .collection('rPosts')
            .doc(_postId)
            .update({
          'clapCount': FieldValue.increment(-1),
        });
        await _receivedPosts
            .doc(_receiverId)
            .collection('rPosts')
            .doc(_postId)
            .collection('clappedByUsers')
            .doc(_uid)
            .delete();
      }
      return !isLiked;
    }
  }

  Future<String> getURL(String id) async {
    var ref = _storage.ref('$id/default_image.jpeg');
    String imageUrl = await ref.getDownloadURL();
    return imageUrl;
  }

  String fromAtNow(DateTime date) {
    final Duration difference = DateTime.now().difference(date);

    final int sec = difference.inSeconds;
    if (sec >= 60 * 60 * 24 * 30 * 12) {
      initializeDateFormatting('ja');
      return DateFormat.yMEd('ja').add_Hm().format(date);
    } else if (sec >= 60 * 60 * 24 * 30) {
      return '${difference.inDays ~/ 30}ヶ月前';
    } else if (sec >= 60 * 60 * 24) {
      return '${difference.inDays}日前';
    } else if (sec >= 60 * 60) {
      return '${difference.inHours}時間前';
    } else if (sec >= 60) {
      return '${difference.inMinutes}分前';
    } else {
      return '$sec秒前';
    }
  }

  @override
  Widget build(BuildContext context) {
    FutureBuilder<DocumentSnapshot<Map<String, dynamic>>> name(String id) {
      return FutureBuilder(
        future: _userProfiles.doc(id).get(),
        builder: (
          BuildContext context,
          AsyncSnapshot<DocumentSnapshot> snapshot,
        ) {
          if (snapshot.hasData) {
            Map<String, dynamic> data =
                snapshot.data!.data() as Map<String, dynamic>;
            return Text(
              data['name'],
              style: const TextStyle(
                fontSize: 18,
                fontFamily: 'NotoSansJP',
                fontWeight: FontWeight.w600,
              ),
            );
          }
          return const Text('  ');
        },
      );
    }

    return GestureDetector(
      onLongPress: () {
        if (_serverId == _uid) {
          showDialog(
              context: context,
              builder: (BuildContext context) {
                return CupertinoAlertDialog(
                  title: const Text('Thanxtoryを削除'),
                  content: const Text(
                    'この投稿を削除しますか？',
                    style: TextStyle(
                      fontSize: 16,
                    ),
                  ),
                  actions: <CupertinoDialogAction>[
                    CupertinoDialogAction(
                      child: const Text('いいえ'),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                    ),
                    CupertinoDialogAction(
                      child: const Text('はい'),
                      isDestructiveAction: true,
                      onPressed: () {
                        Navigator.pop(context);
                        showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return CupertinoAlertDialog(
                                content: const Text(
                                  '本当に削除していいですか？',
                                  style: TextStyle(
                                    color: Colors.red,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                actions: <CupertinoDialogAction>[
                                  CupertinoDialogAction(
                                    child: const Text('いいえ'),
                                    onPressed: () {
                                      Navigator.pop(context);
                                    },
                                  ),
                                  CupertinoDialogAction(
                                    child: const Text('削除'),
                                    isDestructiveAction: true,
                                    onPressed: () async {
                                      await _userProfiles.doc(_uid).update({
                                        'servedCount': FieldValue.increment(-1),
                                      });
                                      await _servedPosts
                                          .doc(_uid)
                                          .collection('sPosts')
                                          .doc(_postId)
                                          .delete();
                                      if (_receiverId != '') {
                                        await _userProfiles
                                            .doc(_receiverId)
                                            .update({
                                          'receivedCount':
                                              FieldValue.increment(-1),
                                        });
                                        await _receivedPosts
                                            .doc(_receiverId)
                                            .collection('rPosts')
                                            .doc(_postId)
                                            .delete();
                                      }
                                      await _clappedPosts
                                          .doc()
                                          .collection('cPosts')
                                          .doc(_postId)
                                          .delete();

                                      Navigator.pop(context);
                                    },
                                  ),
                                ],
                              );
                            });
                        // Do something destructive.
                      },
                    ),
                  ],
                );
              });
        } else {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return CupertinoAlertDialog(
                title: const Text('好ましくない投稿'),
                content: const Text(
                  'この投稿を報告しますか？',
                  style: TextStyle(
                    fontSize: 16,
                  ),
                ),
                actions: <CupertinoDialogAction>[
                  CupertinoDialogAction(
                    child: const Text('いいえ'),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                  CupertinoDialogAction(
                    child: const Text('はい'),
                    isDestructiveAction: true,
                    onPressed: () async {
                      await FirebaseFirestore.instance
                          .collection('harmfulPosts')
                          .add({
                        'postId': _postId,
                        'serverId': _serverId,
                        'content': _content,
                        'createdAt': Timestamp.fromDate(widget.createdAt),
                        'clapCount': _clapCount,
                        'reportedAt': Timestamp.fromDate(DateTime.now()),
                        'reporterId': _uid,
                      });
                      Navigator.pop(context);
                      showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return const CupertinoAlertDialog(
                              content: Text('問題のある投稿として報告しました。'),
                            );
                          });
                    },
                  ),
                ],
              );
            },
          );
        }
      },
      child: ConstrainedBox(
        constraints: const BoxConstraints(minWidth: double.maxFinite),
        child: Card(
          elevation: 1.0,
          shadowColor: Colors.white,
          margin: const EdgeInsets.only(bottom: 0.5),
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 1,
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 14.0),
                        child: GestureDetector(
                          onTap: () {
                            if (_serverId != _uid) {
                              Navigator.push(context, MaterialPageRoute(
                                  builder: (BuildContext context) {
                                return ProfilePageTwo(userId: _serverId);
                              }));
                            }
                          },
                          child: CircleAvatar(
                            backgroundColor: Colors.transparent,
                            radius: 30,
                            child: ClipOval(
                              child: FutureBuilder(
                                future: getURL(_serverId),
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
                      ),
                      _receiverId == ''
                          ? const SizedBox(width: 0, height: 0)
                          : Padding(
                              padding:
                                  const EdgeInsets.only(top: 14.0, right: 12.0),
                              child: GestureDetector(
                                onTap: () {
                                  if (_receiverId != _uid) {
                                    Navigator.push(context, MaterialPageRoute(
                                        builder: (BuildContext context) {
                                      return ProfilePageTwo(
                                          userId: _receiverId);
                                    }));
                                  }
                                },
                                child: CircleAvatar(
                                  backgroundColor: Colors.transparent,
                                  radius: 20,
                                  child: ClipOval(
                                    child: FutureBuilder(
                                      future: getURL(_receiverId),
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
                            ),
                      const SizedBox(height: 4.0),
                    ],
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Column(
                              children: [
                                GestureDetector(
                                  onTap: () {
                                    if (_serverId != _uid) {
                                      Navigator.push(context, MaterialPageRoute(
                                          builder: (BuildContext context) {
                                        return ProfilePageTwo(
                                            userId: _serverId);
                                      }));
                                    }
                                  },
                                  child: name(_serverId),
                                ),
                              ],
                            ),
                          ),
                          Padding(
                            padding:
                                const EdgeInsets.only(top: 8.0, right: 16.0),
                            child: Text(
                              _createdAt,
                              style: const TextStyle(
                                fontFamily: 'NotoSansJP',
                              ),
                            ),
                          ),
                        ],
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0, right: 12.0),
                        child: Text(
                          _content,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w400,
                            fontFamily: 'NotoSansJP',
                          ),
                          maxLines: 39,
                          softWrap: true,
                          overflow: TextOverflow.visible,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(
                          top: 4.0,
                          right: 24,
                          bottom: 8.0,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            LikeButton(
                              isLiked: isClapped,
                              likeCount: _clapCount,
                              likeBuilder: (bool isLiked) {
                                return Image.asset(
                                  'assets/images/c.png',
                                  color: isLiked ? C.subColor : C.mainColor,
                                );
                              },
                              onTap: _onLikeButtonTapped,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
