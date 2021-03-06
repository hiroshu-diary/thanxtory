import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:thanxtory/model/constant.dart';
import 'package:thanxtory/widgets/bottom_navigation.dart';
import 'package:thanxtory/widgets/content_card.dart';

class ProfilePage extends StatefulWidget {
  final String userId;
  final bool isMe;
  const ProfilePage({
    Key? key,
    required this.userId,
    required this.isMe,
  }) : super(key: key);
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage>
    with TickerProviderStateMixin {
  late String _uid;
  late bool isMe;
  late TabController _tabController;
  final storage = FirebaseStorage.instance;
  final _userProfiles = FirebaseFirestore.instance.collection('userProfiles');
  final _servedPosts = FirebaseFirestore.instance.collection('servedPosts');
  final _receivedPosts = FirebaseFirestore.instance.collection('receivedPosts');
  final _clappedPosts = FirebaseFirestore.instance.collection('clappedPosts');

  final ScrollController _serveController = ScrollController();
  final ScrollController _receiveController = ScrollController();
  final ScrollController _clapController = ScrollController();

  Future<List<Map<String, dynamic>>> myClap() async {
    final snapshot = await _clappedPosts
        .doc(_uid)
        .collection('cPosts')
        .orderBy('clappedAt', descending: true)
        .get();
    final _senderPosts = await Future.wait(
      snapshot.docs.map(
        (document) async {
          final _postId = document.id;
          final _serverId = document.data()['serverId'];
          final _senderPostSnapshot = await _servedPosts
              .doc(_serverId)
              .collection('sPosts')
              .doc(_postId)
              .get();
          return _senderPostSnapshot.data()!;
        },
      ).toList(),
    );
    return _senderPosts;
  }

  Future<String> getURL(String id) async {
    var ref = storage.ref('$id/default_image.jpeg');
    String imageUrl = await ref.getDownloadURL();
    return imageUrl;
  }

  @override
  void initState() {
    _tabController = TabController(length: 3, vsync: this);
    isMe = widget.isMe;
    _uid = widget.isMe ? FirebaseAuth.instance.currentUser!.uid : widget.userId;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(
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
                          buildCounters('todayThanks', '??????'),
                          buildCounters('servedCount', '?????????'),
                          buildCounters('receivedCount', '????????????'),
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
                    TextStyle(
                      fontSize: 16.0,
                      color: isMe ? Colors.black : C.subColor,
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
                    child: const Tab(text: '?????????'),
                  ),
                  GestureDetector(
                    onLongPress: () => Scroller.scrollToTop(_receiveController),
                    child: const Tab(text: '????????????'),
                  ),
                  GestureDetector(
                    onLongPress: () => Scroller.scrollToTop(_clapController),
                    child: const Tab(text: '??????'),
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
          buildRefresher(_servedPosts, 'sPosts', _serveController),
          buildRefresher(_receivedPosts, 'rPosts', _receiveController),
          clapList(),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: isMe ? kBuildBottomNavigationBar(context, 2) : null,
      floatingActionButton: isMe
          ? null
          : Container(
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: C.subColor),
                borderRadius: BorderRadius.circular(10),
              ),
              width: 90,
              height: 60,
              child: CupertinoButton(
                padding: EdgeInsets.zero,
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Center(
                  child: Text(
                    '??????',
                    style: TextStyle(
                      fontSize: 24,
                      fontFamily: 'NotoSansJP',
                      color: C.subColor,
                    ),
                  ),
                ),
              ),
            ),
    );
  }

  RefreshIndicator buildRefresher(
    CollectionReference collection,
    String subCollection,
    ScrollController controller,
  ) {
    return RefreshIndicator(
      backgroundColor: Colors.white,
      color: C.subColor,
      onRefresh: () async {
        setState(() {});
      },
      child: FutureBuilder(
        future: collection
            .doc(_uid)
            .collection(subCollection)
            .orderBy('createdAt', descending: true)
            .get(),
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
                });
          }
          return const Center(
            child: CircleAvatar(
              backgroundColor: Colors.transparent,
              child: SizedBox(
                width: 240,
                height: 240,
                child: CircularProgressIndicator(
                  color: C.subColor,
                ),
              ),
            ),
          );
        },
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
              fontFamily: 'NotoSansJP',
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
        return Text('???', style: style);
      },
    );
  }

  RefreshIndicator clapList() {
    return RefreshIndicator(
      backgroundColor: Colors.white,
      color: C.subColor,
      onRefresh: () async {
        setState(() {});
      },
      child: FutureBuilder(
        future: myClap(),
        builder: (
          BuildContext context,
          AsyncSnapshot<List<Map<String, dynamic>>> snapshot,
        ) {
          if (snapshot.connectionState == ConnectionState.done) {
            return ListView.builder(
                controller: _clapController,
                padding: EdgeInsets.zero,
                itemCount: snapshot.data!.length,
                itemBuilder: (context, int index) {
                  var _post = snapshot.data![index];
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
                });
          }
          return const Center(
            child: CircleAvatar(
              backgroundColor: Colors.transparent,
              child: SizedBox(
                width: 240,
                height: 240,
                child: CircularProgressIndicator(
                  color: C.subColor,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
