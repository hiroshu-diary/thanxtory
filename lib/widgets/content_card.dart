import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:like_button/like_button.dart';
import 'package:intl/intl.dart';
import '../model/constant.dart';

//todo 各アカウントへの遷移もuserProfiles等及び、profile_pageのパクリでいく.
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

    String _postId = widget.postId;
    String _serverId = widget.serverId;
    String _receiverId = widget.receiverId;
    String _createdAt = fromAtNow(widget.createdAt);
    String _content = widget.content;
    int _clapCount = widget.clapCount;

    return GestureDetector(
      onLongPress: () {
        ///自分の投稿なら
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
                                    child: const Text('はい'),
                                    isDestructiveAction: true,
                                    onPressed: () async {
                                      todayThanks--;
                                      await _userProfiles.doc(_uid).update({
                                        'todayThanks': todayThanks,
                                        'servedCount': FieldValue.increment(-1),
                                      });
                                      await _servedPosts
                                          .doc(_uid)
                                          .collection('posts')
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
                                            .collection('posts')
                                            .doc(_postId)
                                            .delete();
                                      }
                                      //todo 自分のservedPostsだけを対象にする
                                      //todo 関連するclappedPostへの処理

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
        }
        //else↓
        //todo 投稿を報告するメソッド
      },
      child: ConstrainedBox(
        constraints: const BoxConstraints(minWidth: double.maxFinite),
        child: Card(
          elevation: 1.0,
          shadowColor: Colors.white,
          margin: const EdgeInsets.only(bottom: 0.5),
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
                          //todo アカウントのプロフィールへ
                        },
                        child: CircleAvatar(
                          backgroundColor: Colors.transparent,
                          radius: 30,
                          child: ClipOval(
                            child: FutureBuilder(
                              future: getURL(_uid),
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
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                flex: 3,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
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
                                  //todo アカウントのプロフィールへ
                                },
                                child: name(_uid),
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 8.0, right: 16.0),
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
                            fontFamily: 'NotoSansJP'),
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
                            //todo 自分がいいねした投稿をclapListに追加する
                            // countBuilder: ,
                            likeCount: _clapCount,
                            likeBuilder: (bool isLiked) {
                              return Image.asset(
                                'assets/images/c.png',
                                color: isLiked ? C.subColor : C.mainColor,
                              );
                            },
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
    );
  }
}
