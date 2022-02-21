import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:thanxtory/model/message.dart';
import 'package:thanxtory/pages/post/selection_page.dart';
import 'package:thanxtory/widgets/content_card.dart';
import '../../model/constant.dart';
import '../../model/list.dart';
import '../animation/animation_page.dart';
import '../home/home_page.dart';

class PostPage extends StatefulWidget {
  const PostPage({Key? key}) : super(key: key);

  static const path = '/post/';
  static const name = 'PostPage';

  @override
  _PostPageState createState() => _PostPageState();
}

enum receiver {
  someone,
  me,
  none,
}
//todo receiver...でBottomNavigationBarをコントロールする

class _PostPageState extends State<PostPage> {
  late SharedPreferences _prefs;

  var destination = receiver.none;

  Future<void> setInstance() async {
    _prefs = await SharedPreferences.getInstance();
    getDay();
    setState(() {});
  }

  void setDay(int lastPostDay) {
    _prefs.setInt('lastPostDay', lastPostDay);
    getDay();
  }

  void getDay() {
    lastPostDay = _prefs.getInt('lastPostDay') ?? 20220214;
    //todo リリース前に20220309に変える
  }

  final _formKey = GlobalKey<FormState>();
  late TextEditingController _textEditingController;

  @override
  void initState() {
    super.initState();
    _textEditingController = TextEditingController();
    setInstance();
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
                  //この遷移はColoRichのメソッドで下移動でいく
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
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        todayThanks++;
                        servedCount++;
                        print(lastPostDay);
                        int _lastPostDay = int.parse(
                          DateFormat('yyyyMMdd').format(DateTime.now()),
                        );
                        setDay(_lastPostDay);
                        print(lastPostDay);
                        serveList.add(
                          ContentCard(
                            message: Message(
                              address: 'hiroshu.diary',
                              name: '常角洋',
                              message: _textEditingController.text,
                              createdTime: DateTime.now(),
                            ),
                          ),
                        );

                        //ここでAnimation
                        Nav.navigate(
                          context,
                          const AnimationPage(),
                          const Offset(0, -0.5),
                        );
                      }
                    },
                  ),
                ],
              ),
              body: TextFormField(
                onChanged: (value) => setState(() {}),
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
                    padding: const EdgeInsets.only(left: 16, top: 16),
                    child: Column(
                      children: const [
                        CircleAvatar(
                          backgroundColor: Colors.transparent,
                          minRadius: 26,
                          maxRadius: 34,
                          backgroundImage: AssetImage('assets/images/pon.png'),
                          // backgroundImage: NetworkImage(
                          //   'https://assets.media-platform.com/bi/dist/images/2021/03/19/black-w960.jpeg',
                          // ),
                        ),
                      ],
                    ),
                  ),
                  border: InputBorder.none,
                  contentPadding:
                      const EdgeInsets.only(left: 4, right: 16, top: 8),
                  hintText: '何を伝える？',
                  counterText: '${_textEditingController.text.length} / 139',
                  counterStyle: TextStyle(
                    color: _textEditingController.text.length > 139
                        ? Colors.red
                        : Colors.black87,
                  ),
                ),
                maxLines: 39,
                // maxLength: 139,
                style: const TextStyle(
                  fontSize: 16,
                  fontFamily: 'NotoSansJP',
                  fontWeight: FontWeight.w500,
                ),
              ),

              ///送り先の選択
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
                    child: const Center(
                      child: Text(
                        'Thanxtoryアカウントに贈る',
                        style: TextStyle(
                          color: C.subColor,
                          fontSize: 18,
                          fontFamily: 'NotoSansJP',
                        ),
                      ),
                    ),
                    onPressed: () {
                      Navigator.push(context,
                          MaterialPageRoute(builder: (context) {
                        return selectionPage(context);
                      }));
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
