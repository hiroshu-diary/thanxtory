import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:thanxtory/model/constant.dart';
import 'package:thanxtory/widgets/content_card.dart';

class ProfilePageTwo extends StatefulWidget {
  final String userId;

  const ProfilePageTwo({Key? key, required this.userId}) : super(key: key);

  @override
  _ProfilePageTwoState createState() => _ProfilePageTwoState();
}

//todo CloudFunctionsで連続投稿を管理

class _ProfilePageTwoState extends State<ProfilePageTwo>
    with TickerProviderStateMixin {
  late TabController _tabController;
  final storage = FirebaseStorage.instance;
  final _userProfiles = FirebaseFirestore.instance.collection('userProfiles');
  final _servedPosts = FirebaseFirestore.instance.collection('servedPosts');
  final _receivedPosts = FirebaseFirestore.instance.collection('receivedPosts');
  final _clappedPosts = FirebaseFirestore.instance.collection('clappedPosts');

  final ScrollController _serveController = ScrollController();
  final ScrollController _receiveController = ScrollController();
  final ScrollController _clapController = ScrollController();

  Future<String> getURL(String id) async {
    var ref = storage.ref('$id/default_image.jpeg');
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
    final String _uid = widget.userId;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        //todo 【質問】高さをレスポンシブに変える
        preferredSize: const Size(double.maxFinite, 200),
        child: SafeArea(
          child: Column(
            children: [
              Row(
                children: [
                  SizedBox(
                    width: MediaQuery.of(context).size.width / 4,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
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
                  SizedBox(
                    width: MediaQuery.of(context).size.width / 4 * 3,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Row(
                        children: [
                          buildCounters(_uid, 'rowCount', '連続'),
                          buildCounters(_uid, 'servedCount', 'サーブ'),
                          buildCounters(_uid, 'receivedCount', 'レシーブ'),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  const SizedBox(width: 20),
                  buildFutureBuilder(
                    _uid,
                    'name',
                    const TextStyle(
                      fontSize: 16.0,
                      fontFamily: 'NotoSansJP',
                      fontWeight: FontWeight.w600,
                      color: C.subColor,
                    ),
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  const SizedBox(width: 20.0),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: buildFutureBuilder(
                      _uid,
                      'introduction',
                      const TextStyle(
                        fontFamily: 'NotoSansJP',
                      ),
                    ),
                  ),
                ],
              ),
              TabBar(
                controller: _tabController,
                indicatorColor: C.subColor,
                labelColor: Colors.black,
                tabs: [
                  GestureDetector(
                    onLongPress: () => Scroller.scrollToTop(_serveController),
                    child: const Tab(text: 'サーブ'),
                  ),
                  GestureDetector(
                    onLongPress: () => Scroller.scrollToTop(_receiveController),
                    child: const Tab(text: 'レシーブ'),
                  ),
                  GestureDetector(
                    onLongPress: () => Scroller.scrollToTop(_clapController),
                    child: const Tab(text: '拍手'),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          buildRefresher(
            buildTab(_servedPosts, _uid, 'sPosts', _serveController),
          ),
          buildRefresher(
            buildTab(_receivedPosts, _uid, 'rPosts', _receiveController),
          ),
          //todo 自分のclappedPostをFutureBuilderで標示
          buildRefresher(Container()),
        ],
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.only(
          left: 32.0,
          right: 32.0,
          bottom: 39.0,
        ),
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(color: C.subColor),
            borderRadius: BorderRadius.circular(10),
          ),
          width: double.maxFinite,
          height: 72,
          child: CupertinoButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Center(
              child: Text(
                '戻る',
                style: TextStyle(
                  fontSize: 24,
                  fontFamily: 'NotoSansJP',
                  color: C.subColor,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  RefreshIndicator buildRefresher(Widget child) {
    return RefreshIndicator(
      backgroundColor: Colors.white,
      color: C.subColor,
      onRefresh: () async {
        setState(() {});
      },
      child: child,
    );
  }

  FutureBuilder<QuerySnapshot<Map<String, dynamic>>> buildTab(
    CollectionReference collection,
    String userId,
    String subCollection,
    ScrollController controller,
  ) {
    return FutureBuilder(
      future: collection.doc(userId).collection(subCollection).get(),
      builder: (
        BuildContext context,
        AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot,
      ) {
        if (snapshot.connectionState == ConnectionState.done) {
          return ListView.builder(
            controller: controller,
            padding: EdgeInsets.zero,
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, int index) {
              var _post = snapshot.data!.docs[index];
              String _postId = _post['postId'];
              String _serverId = _post['serverId'];
              String _receiverId = _post['receiverId'];
              int _clapCount = _post['clapCount'];
              String _content = _post['content'];
              Timestamp _createdStamp = _post['createdAt'];
              DateTime _createdAt = _createdStamp.toDate();
              return ContentCard(
                postId: _postId,
                serverId: _serverId,
                receiverId: _receiverId,
                clapCount: _clapCount,
                content: _content,
                createdAt: _createdAt,
              );
            },
          );
        }
        return const CircleAvatar(
          backgroundColor: Colors.transparent,
          child: CircularProgressIndicator(color: C.subColor),
        );
      },
    );
  }

  Expanded buildCounters(
    String userId,
    String count,
    String name,
  ) {
    return Expanded(
      flex: 1,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          buildFutureBuilder(
            userId,
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
    String userId,
    String count,
    TextStyle style,
  ) {
    return FutureBuilder(
      future: _userProfiles.doc(userId).get(),
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

        return Text('　', style: style);
      },
    );
  }
}
