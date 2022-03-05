import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:thanxtory/model/constant.dart';
import 'package:thanxtory/widgets/content_card.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);
  static const path = '/profile/';
  static const name = 'ProfilePage';

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

//todo CloudFunctionsで連続投稿を管理
class _ProfilePageState extends State<ProfilePage>
    with TickerProviderStateMixin {
  late TabController _tabController;
  final storage = FirebaseStorage.instance;
  final _uid = FirebaseAuth.instance.currentUser!.uid;
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
                          buildCounters('rowCount', '連続'),
                          buildCounters('servedCount', 'サーブ'),
                          buildCounters('receivedCount', 'レシーブ'),
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
                    'name',
                    const TextStyle(
                      fontSize: 16.0,
                      fontFamily: 'NotoSansJP',
                      fontWeight: FontWeight.w600,
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
            buildTab(_servedPosts, 'sPosts', _serveController),
          ),
          buildRefresher(
            buildTab(_receivedPosts, 'rPosts', _receiveController),
          ),
          //todo 自分のclappedPostをFutureBuilderで標示
          buildRefresher(
            Container(),
          ),
        ],
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
    String subCollection,
    ScrollController controller,
  ) {
    return FutureBuilder(
      future: collection.doc(_uid).collection(subCollection).get(),
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

        return Text('　', style: style);
      },
    );
  }
}
