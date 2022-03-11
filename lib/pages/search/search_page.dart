import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:material_floating_search_bar/material_floating_search_bar.dart';

import '../../model/constant.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({
    Key? key,
  }) : super(key: key);
  static const path = '/search/';
  static const name = 'SearchPage';
  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final _controller = FloatingSearchBarController();
  final _userProfiles = FirebaseFirestore.instance.collection('userProfiles');
  late TextEditingController _searchController;
  final _storage = FirebaseStorage.instance;
  Future<String> getURL(String id) async {
    var ref = _storage.ref('$id/default_image.jpeg');
    String imageUrl = await ref.getDownloadURL();
    return imageUrl;
  }

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Stack(
        fit: StackFit.expand,
        children: [
          buildFloatingSearchBar(),
        ],
      ),
    );
  }

  Widget buildFloatingSearchBar() {
    final isPortrait =
        MediaQuery.of(context).orientation == Orientation.portrait;

    return FloatingSearchBar(
      controller: _controller,
      hint: '誰をさがす？',
      scrollPadding: const EdgeInsets.only(top: 16, bottom: 56),
      transitionDuration: const Duration(milliseconds: 800),
      transitionCurve: Curves.easeInOut,
      physics: const BouncingScrollPhysics(),
      axisAlignment: isPortrait ? 0.0 : -1.0,
      openAxisAlignment: 0.0,
      width: isPortrait ? 600 : 500,
      debounceDelay: const Duration(milliseconds: 500),
      onQueryChanged: (String text) {},
      onSubmitted: (String text) {},
      transition: CircularFloatingSearchBarTransition(),
      actions: [
        FloatingSearchBarAction(
          showIfOpened: false,
          child: CircularButton(
            icon: const Icon(CupertinoIcons.person),
            onPressed: () {},
          ),
        ),
        FloatingSearchBarAction.searchToClear(
          showIfClosed: false,
        ),
      ],
      builder: (context, transition) {
        return FutureBuilder<QuerySnapshot>(
          future: _userProfiles.get(),
          builder: (
            BuildContext context,
            AsyncSnapshot<QuerySnapshot> snapshot,
          ) {
            List<String> returnList = [];
            _userProfiles.get().then((QuerySnapshot snapshot) {
              snapshot.docs.forEach((doc) async {
                String _name = await doc.get('name') as String;
                if (_controller.query.contains(_name)) {
                  returnList.add(doc.id);
                }
              });
            });
            if (snapshot.hasError) {
              return const Text('ヒット件数が０件でした。');
            }

            if (snapshot.connectionState == ConnectionState.waiting) {
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

            return ListView.builder(
              padding: EdgeInsets.zero,
              itemCount: returnList.length,
              itemBuilder: (context, int index) {
                return ConstrainedBox(
                  constraints: const BoxConstraints(minWidth: double.maxFinite),
                  child: Card(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: CircleAvatar(
                            backgroundColor: Colors.transparent,
                            radius: 33,
                            child: ClipOval(
                              child: FutureBuilder(
                                future: getURL(returnList[index]),
                                builder: (BuildContext context,
                                    AsyncSnapshot<String> snapshot) {
                                  if (snapshot.connectionState ==
                                          ConnectionState.waiting ||
                                      !snapshot.hasData) {
                                    return CachedNetworkImage(
                                      fit: BoxFit.cover,
                                      imageUrl: snapshot.data!,
                                    );
                                  }
                                  return Container();
                                },
                              ),
                            ),
                          ),
                        ),
                        FutureBuilder(
                          future: _userProfiles.doc(returnList[index]).get(),
                          builder: (
                            BuildContext context,
                            AsyncSnapshot<DocumentSnapshot> snapshot,
                          ) {
                            if (snapshot.hasData) {
                              Map<String, dynamic> data =
                                  snapshot.data!.data() as Map<String, dynamic>;

                              return Text(
                                data['name'].toString(),
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontFamily: 'NotoSansJP',
                                  fontWeight: FontWeight.w600,
                                ),
                              );
                            }
                            return const Text('　　');
                          },
                        ),
                        const Spacer(),
                        GestureDetector(
                          child: const Text('この人に贈る'),
                          onTap: () {},
                        ),
                        GestureDetector(
                          child: const Text('詳しく見る'),
                          onTap: () {},
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}
