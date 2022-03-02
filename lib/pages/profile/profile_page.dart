import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
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
  late TabController _tabController;
  final storage = FirebaseStorage.instance;
  final _uid = FirebaseAuth.instance.currentUser!.uid;
  final _userProfiles = FirebaseFirestore.instance.collection('userProfiles');
  final _servedPosts = FirebaseFirestore.instance.collection('servedPosts');
  final _receivedPosts = FirebaseFirestore.instance.collection('receivedPosts');
  final _clappedPosts = FirebaseFirestore.instance.collection('clappedPosts');
  Future<String> getURL() async {
    var ref = storage.ref('3aQhAPXLD1W43WABs2CsId6ERK12/default_image.jpeg');
    String imageUrl = await ref.getDownloadURL();
    return imageUrl;
  }

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
                    Expanded(
                      flex: 2,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: CircleAvatar(
                          backgroundColor: Colors.transparent,
                          radius: 32,
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
                      ),
                    ),
                    Expanded(
                      flex: 5,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Row(
                          children: [
                            buildCounters('rowCount', '連続'),
                            buildCounters('servedCount', 'サーブ'),
                            buildCounters('receivedCount', 'レシーブ'),
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
                          buildFutureBuilder(
                            'name',
                            const TextStyle(
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
                        child: buildFutureBuilder(
                          'introduction',
                          const TextStyle(
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
          //todo 自分のservedPostをstreamBuilderで標示
          ListView.builder(
            padding: EdgeInsets.zero,
            itemCount: serveList.length,
            itemBuilder: (BuildContext context, int index) {
              return serveList.reversed.toList()[index];
            },
          ),
          //todo 自分のreceivedPostをstreamBuilderで標示
          ListView.builder(
            padding: EdgeInsets.zero,
            itemCount: receiveList.length,
            itemBuilder: (BuildContext context, int index) {
              return receiveList.reversed.toList()[index];
            },
          ),
          //todo 自分のclappedPostをstreamBuilderで標示
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

  Expanded buildCounters(String count, String name) {
    return Expanded(
      flex: 1,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          buildFutureBuilder(
            count,
            const TextStyle(
              fontSize: 17.0,
              fontWeight: FontWeight.w600,
            ),
          ),
          Text(name),
        ],
      ),
    );
  }

  FutureBuilder<DocumentSnapshot<Map<String, dynamic>>> buildFutureBuilder(
    String count,
    TextStyle style,
  ) {
    return FutureBuilder(
      future: _userProfiles.doc(_uid).get(),
      builder: (
        BuildContext context,
        AsyncSnapshot<DocumentSnapshot> snapshot,
      ) {
        if (snapshot.hasData) {
          Map<String, dynamic> data =
              snapshot.data!.data() as Map<String, dynamic>;

          return Text(
            data[count].toString(),
            style: style,
          );
        }

        return Text(
          '　',
          style: style,
        );
      },
    );
  }
}
