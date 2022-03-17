import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:line_icons/line_icons.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:thanxtory/pages/home/settings_page.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../model/constant.dart';
import '../post/post_page.dart';
import '../profile/profile_page.dart';
import '../square/square_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  static const path = '/';
  static const name = 'HomePage';

  @override
  _HomePageState createState() => _HomePageState();
}

int todayThanks = 0;

class _HomePageState extends State<HomePage> {
  int currentIndex = 0;

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final _userProfiles = FirebaseFirestore.instance.collection('userProfiles');
  late String _uid;

  List viewList = [
    const SquarePage(),
    const PostPage(),
    const ProfilePage(userId: '', isMe: true),
  ];

  void _launchURL(url) async {
    if (!await launch(url)) throw 'Could not launch $url';
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
    _uid = _auth.currentUser!.uid;
    getCount();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: currentIndex == 0 || currentIndex == 2
          ? Drawer(
              child: Padding(
                padding: const EdgeInsets.only(top: 60.0),
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: 36.0,
                        horizontal: 24.0,
                      ),
                      child: Center(
                        child: FutureBuilder(
                          future: _userProfiles.doc(_uid).get(),
                          builder: (
                            BuildContext context,
                            AsyncSnapshot<DocumentSnapshot> snapshot,
                          ) {
                            if (snapshot.connectionState ==
                                    ConnectionState.done &&
                                snapshot.hasData) {
                              Map<String, dynamic> data =
                                  snapshot.data!.data() as Map<String, dynamic>;

                              return Text(
                                '今日の感謝数：${data['todayThanks'].toString()}',
                                style: Style.countStyle(),
                              );
                            }
                            if (snapshot.connectionState ==
                                    ConnectionState.waiting ||
                                !snapshot.hasData) {
                              return const CircularProgressIndicator(
                                color: C.subColor,
                              );
                            }

                            return Text(
                              '今日の感謝数：　',
                              style: Style.countStyle(),
                            );
                          },
                        ),
                      ),
                    ),
                    const Divider(height: 2.0, color: C.subColor),
                    Tile.buildTile(
                      const Icon(
                        CupertinoIcons.settings,
                        color: Colors.black87,
                        size: 26,
                      ),
                      'プロフィール設定',
                      () {
                        Navigator.pop(context);
                        Nav.navigate360(
                          context,
                          const Offset(-1, 0),
                          const SettingsPage(),
                        );
                      },
                    ),
                    Tile.buildTile(
                      Icon(
                        Platform.isIOS
                            ? FontAwesomeIcons.appStore
                            : LineIcons.googlePlay,
                        color: Colors.black87,
                        size: 26,
                      ),
                      'アプリを評価',
                      () {
                        String _storeURL = Platform.isIOS
                            ? 'https://apps.apple.com/jp/app/thanxtory/id1613315043'
                            : 'https://play.google.com/store/apps/details?id=com.hiroshu.diary.thanxtory';
                        _launchURL(_storeURL);
                      },
                    ),
                    Tile.buildTile(
                      const Icon(
                        CupertinoIcons.doc,
                        color: Colors.black87,
                        size: 26,
                      ),
                      'アンケート',
                      () {
                        const _formURL = 'https://forms.gle/yZBojmdRHM4khcSD9';
                        _launchURL(_formURL);
                      },
                    ),
                    Tile.buildTile(
                      const Icon(
                        Icons.logout_outlined,
                        color: Colors.black87,
                        size: 26,
                      ),
                      'サインアウト',
                      () {
                        Navigator.pop(context);
                        showDialog(
                            context: context,
                            builder: (context) {
                              return CupertinoAlertDialog(
                                title: const Text('サインアウトの確認'),
                                content: const Text('サインアウトしても良いですか？'),
                                actions: <CupertinoDialogAction>[
                                  CupertinoDialogAction(
                                    child: const Text('キャンセル'),
                                    onPressed: () {
                                      Navigator.pop(context);
                                    },
                                  ),
                                  CupertinoDialogAction(
                                    child: const Text('はい'),
                                    isDestructiveAction: true,
                                    onPressed: () async {
                                      Navigator.pop(context);
                                      await _auth.signOut();
                                    },
                                  )
                                ],
                              );
                            });
                      },
                    ),
                  ],
                ),
              ),
            )
          : null,
      body: currentIndex == 0
          ? NestedScrollView(
              floatHeaderSlivers: true,
              headerSliverBuilder:
                  (BuildContext context, bool innerBoxIsScrolled) {
                return [
                  PreferredSize(
                    preferredSize: Size(
                      double.maxFinite,
                      Platform.isIOS ? 39.0 : 56.0,
                    ),
                    child: SliverAppBar(
                      backgroundColor: Colors.white,
                      floating: true,
                      centerTitle: true,
                      title: GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () {
                          Scroller.scrollToTop(squareController);
                        },
                        child: const Text(
                          'Thanxtory',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 24.0,
                          ),
                        ),
                      ),
                      actions: [
                        GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: () {
                            showCupertinoModalBottomSheet(
                              context: context,
                              barrierColor: Colors.black54,
                              bounce: true,
                              duration: const Duration(milliseconds: 400),
                              builder: (context) => Container(
                                height: MediaQuery.of(context).size.height / 2,
                                width: double.maxFinite,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 24,
                                  horizontal: 8.0,
                                ),
                                child: Column(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 24.0,
                                      ),
                                      child: Column(
                                        children: [
                                          Icon(
                                            timeSequence == true
                                                ? CupertinoIcons.time
                                                : CupertinoIcons.shuffle,
                                            size: 40,
                                            color: C.accentColor,
                                          ),
                                          const SizedBox(height: 16.0),
                                          Text(
                                            timeSequence == true
                                                ? 'スクエアが「時間順」に設定されています'
                                                : 'スクエアが「ランダム」に設定されています',
                                            style: const TextStyle(
                                              fontSize: 24,
                                              color: Colors.black,
                                              fontWeight: FontWeight.w800,
                                              decoration: TextDecoration.none,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Column(
                                      mainAxisSize: MainAxisSize.min,
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Card(
                                          elevation: 0.0,
                                          margin: EdgeInsets.zero,
                                          child: InkWell(
                                            splashColor: C.mainColor,
                                            onTap: () {
                                              timeSequence = !timeSequence;
                                              setState(() {});
                                              Navigator.pop(context);
                                            },
                                            child: ListTile(
                                              leading: Padding(
                                                padding: const EdgeInsets.only(
                                                  left: 8.0,
                                                ),
                                                child: Icon(
                                                  timeSequence == true
                                                      ? CupertinoIcons.shuffle
                                                      : CupertinoIcons.time,
                                                ),
                                              ),
                                              title: Text(
                                                timeSequence == true
                                                    ? 'ランダム表示に切り替え'
                                                    : '時間表示に切り替え',
                                                style: const TextStyle(
                                                  fontSize: 20,
                                                  color: Colors.black,
                                                  fontWeight: FontWeight.w700,
                                                  decoration:
                                                      TextDecoration.none,
                                                ),
                                              ),
                                              subtitle: Text(
                                                timeSequence == true
                                                    ? 'スクエアの標示がランダムになります'
                                                    : 'スクエアの標示が時間順になります',
                                              ),
                                            ),
                                          ),
                                        ),
                                        Card(
                                          color: Colors.transparent,
                                          elevation: 0.0,
                                          margin: EdgeInsets.zero,
                                          child: InkWell(
                                            splashColor: Colors.black12,
                                            onTap: () {
                                              Navigator.pop(context);
                                            },
                                            child: const ListTile(
                                              title: Text(
                                                'キャンセル',
                                                textAlign: TextAlign.center,
                                                style: TextStyle(
                                                  fontSize: 20,
                                                  color: Colors.black,
                                                  fontWeight: FontWeight.w700,
                                                  decoration:
                                                      TextDecoration.none,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                          child: const Padding(
                            padding: EdgeInsets.only(right: 8.0, left: 16.0),
                            child: Icon(
                              CupertinoIcons.arrow_up_arrow_down,
                              color: Colors.black54,
                              size: 24.0,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ];
              },
              body: viewList[0],
            )
          : viewList[currentIndex],
      resizeToAvoidBottomInset: true,
      bottomNavigationBar: currentIndex != 1 || todayThanks == 3
          ? BottomNavigationBar(
              elevation: 0,
              currentIndex: currentIndex,
              selectedItemColor: C.subColor,
              unselectedItemColor: C.mainColor,
              type: BottomNavigationBarType.fixed,
              onTap: (index) {
                setState(() {
                  currentIndex = index;
                });
              },
              items: [
                const BottomNavigationBarItem(
                  label: 'スクエア',
                  tooltip: '',
                  icon: Icon(CupertinoIcons.square_on_square),
                  activeIcon: Icon(CupertinoIcons.square_fill_on_square_fill),
                ),
                BottomNavigationBarItem(
                  label: '伝える',
                  icon: todayThanks < 3
                      ? const Icon(FontAwesomeIcons.paperPlane)
                      : const CircleAvatar(
                          maxRadius: 16,
                          backgroundColor: Colors.transparent,
                          backgroundImage: AssetImage('assets/images/max.png'),
                        ),
                  activeIcon: todayThanks < 3
                      ? const Icon(FontAwesomeIcons.solidPaperPlane)
                      : const CircleAvatar(
                          maxRadius: 16,
                          backgroundColor: Colors.transparent,
                          backgroundImage: AssetImage('assets/images/max.png'),
                        ),
                ),
                const BottomNavigationBarItem(
                  label: 'あなた',
                  tooltip: '',
                  icon: Icon(CupertinoIcons.person),
                  activeIcon: Icon(CupertinoIcons.person_fill),
                ),
              ],
            )
          : null,
    );
  }
}
