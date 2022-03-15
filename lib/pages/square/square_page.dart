import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';

import '../../model/constant.dart';
import '../../widgets/content_card.dart';

class SquarePage extends StatefulWidget {
  const SquarePage({Key? key}) : super(key: key);
  static const path = '/square/';
  static const name = 'SquarePage';

  @override
  _SquarePageState createState() => _SquarePageState();
}

final ScrollController squareController = ScrollController();

class _SquarePageState extends State<SquarePage> {
  final storage = FirebaseStorage.instance;
  Future<String> getURL(String id) async {
    var ref = storage.ref('$id/default_image.jpeg');
    String imageUrl = await ref.getDownloadURL();
    return imageUrl;
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      backgroundColor: Colors.white,
      color: C.subColor,
      onRefresh: () async {
        setState(() {});
      },
      child: FutureBuilder(
        future: timeSequence == true
            ? FirebaseFirestore.instance
                .collectionGroup('sPosts')
                .orderBy('createdAt', descending: true)
                .get()
            : FirebaseFirestore.instance
                .collectionGroup('sPosts')
                .orderBy('postId', descending: true)
                .get(),
        builder: (
          BuildContext context,
          AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot,
        ) {
          if (snapshot.connectionState == ConnectionState.waiting ||
              !snapshot.hasData) {
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
          }
          if (snapshot.connectionState == ConnectionState.done) {
            return ListView.builder(
              controller: squareController,
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
          return Container();
        },
      ),
    );
  }
}
