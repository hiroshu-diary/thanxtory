import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:like_button/like_button.dart';
import 'package:intl/intl.dart';
import 'package:thanxtory/model/message.dart';
import '../model/constant.dart';

class ContentCard extends StatefulWidget {
  final Message message;

  const ContentCard({Key? key, required this.message}) : super(key: key);

  @override
  _ContentCardState createState() => _ContentCardState();
}

class _ContentCardState extends State<ContentCard> {
  ImageProvider myImage = const AssetImage('assets/images/pon.png');
  final DateTime now = DateTime.now();

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

  //
  int likeCount = 0;
  @override
  Widget build(BuildContext context) {
    String myName = widget.message.name;
    String thanksMessage = widget.message.message;
    String postedTime = fromAtNow(widget.message.createdTime);

    return GestureDetector(
      onLongPress: () {
        ///自分の投稿なら
        if (true) {
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
                                    onPressed: () {
                                      //todo 投稿を削除するメソッド
                                      todayThanks--;
                                      servedCount--;
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
                          //アカウントのプロフィールへ
                        },
                        child: CircleAvatar(
                          backgroundImage: myImage,
                          minRadius: 32,
                          maxRadius: 32,
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
                    ///名前、時間

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        //名前
                        Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Column(
                            children: [
                              GestureDetector(
                                onTap: () {
                                  //アカウントのプロフィールへ
                                },
                                child: Text(
                                  myName,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontFamily: 'NotoSansJP',
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 8.0, right: 16.0),
                          child: Text(
                            postedTime,
                            style: const TextStyle(
                              fontFamily: 'NotoSansJP',
                            ),
                          ),
                        ),
                      ],
                    ),

                    ///感謝メッセージ

                    Padding(
                      padding: const EdgeInsets.only(top: 8.0, right: 8.0),
                      child: Text(
                        thanksMessage,
                        maxLines: 10,
                        softWrap: true,
                        overflow: TextOverflow.visible,
                      ),
                    ),

                    ///拍手ボタン

                    Padding(
                      padding: const EdgeInsets.only(
                        top: 4.0,
                        right: 24,
                        bottom: 8.0,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          ///自分がいいねした投稿をclapListに追加する
                          LikeButton(
                            likeCount: likeCount,
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
