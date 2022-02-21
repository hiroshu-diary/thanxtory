import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:thanxtory/model/constant.dart';

import '../../model/list.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);
  static const path = '/profile/';
  static const name = 'ProfilePage';

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage>
    with TickerProviderStateMixin {
  String myName = '常角洋';

  String introduction = 'Thanxtoryを運営している人。';
  late TabController _tabController;
  @override
  void initState() {
    _tabController = TabController(length: 3, vsync: this);
    int today = int.parse(DateFormat('yyyyMMdd').format(DateTime.now()));
    if (today > lastPostDay) {
      todayThanks == 0;
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final double profileHeight = MediaQuery.of(context).size.height / 3.9;

    //todo リストタブより上を隠すNestedSca...に変える
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize: Size(double.maxFinite, profileHeight),
        child: SafeArea(
          child: Column(
            children: [
              Expanded(
                flex: 16,
                child: Row(
                  children: [
                    ///アイコン
                    const Expanded(
                      flex: 2,
                      child: Padding(
                        padding: EdgeInsets.all(16.0),
                        child: CircleAvatar(
                          backgroundColor: Colors.transparent,
                          minRadius: 26,
                          maxRadius: 34,
                          backgroundImage: NetworkImage(
                            'https://assets.media-platform.com/bi/dist/images/2021/03/19/black-w960.jpeg',
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 5,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Row(
                          children: [
                            ///連続日数
                            buildCounters(consecutiveNum, '連続'),
                            buildCounters(servedCount, 'サーブ'),
                            buildCounters(receivedCount, 'レシーブ'),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                flex: 9,
                child: Row(
                  children: [
                    ///名前
                    Expanded(
                      flex: 2,
                      child: Column(
                        children: [
                          Text(
                            myName,
                            style: const TextStyle(
                              fontSize: 16.0,
                              fontFamily: 'NotoSansJP',
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),

                    ///自己紹介
                    Expanded(
                      flex: 5,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          introduction,
                          style: const TextStyle(
                            fontFamily: 'NotoSansJP',
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                flex: 5,
                child: TabBar(
                  controller: _tabController,
                  indicatorColor: C.subColor,
                  labelColor: Colors.black,
                  tabs: const [
                    Tab(text: 'サーブ'),
                    Tab(text: 'レシーブ'),
                    Tab(text: '拍手'),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          ListView.builder(
            padding: EdgeInsets.zero,
            itemCount: serveList.length,
            itemBuilder: (BuildContext context, int index) {
              return serveList.reversed.toList()[index];
            },
          ),
          ListView.builder(
            padding: EdgeInsets.zero,
            itemCount: receiveList.length,
            itemBuilder: (BuildContext context, int index) {
              return receiveList.reversed.toList()[index];
            },
          ),
          ListView.builder(
            padding: EdgeInsets.zero,
            itemCount: receiveList.length,
            itemBuilder: (BuildContext context, int index) {
              return clapList.reversed.toList()[index];
            },
          ),
        ],
      ),
    );
  }

  Expanded buildCounters(int count, String name) {
    return Expanded(
      flex: 1,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            count.toString(),
            style: const TextStyle(
              fontSize: 17.0,
              fontWeight: FontWeight.w600,
            ),
          ),
          Text(name),
        ],
      ),
    );
  }
}
