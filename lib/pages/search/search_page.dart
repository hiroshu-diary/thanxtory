import 'package:anim_search_bar/anim_search_bar.dart';
import 'package:flutter/material.dart';

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
  late TextEditingController _searchController;

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
    return Stack(
      children: [
        SafeArea(
          child: ListView(
            children: const [
              Card(child: Text('aaa')),
              Card(child: Text('aaa')),
              Card(child: Text('aaa')),
              Card(child: Text('aaa')),
              Card(child: Text('aaa')),
              Card(child: Text('aaa')),
              Card(child: Text('aaa')),
              SizedBox(height: 100),
              Card(child: Text('aaa')),
              Card(child: Text('aaa')),
              Card(child: Text('aaa')),
              Card(child: Text('aaa')),
              Card(child: Text('aaa')),
              Card(child: Text('aaa')),
              Card(child: Text('aaa')),
              Card(child: Text('aaa')),
              Card(child: Text('aaa')),
              Card(child: Text('aaa')),
              SizedBox(height: 100),
              Card(child: Text('aaa')),
              Card(child: Text('aaa')),
              Card(child: Text('aaa')),
              Card(child: Text('aaa')),
              Card(child: Text('aaa')),
              Card(child: Text('aaa')),
              Card(child: Text('aaa')),
              SizedBox(height: 100),
              Card(child: Text('aaa')),
              Card(child: Text('aaa')),
              Card(child: Text('aaa')),
              Card(child: Text('aaa')),
              Card(child: Text('aaa')),
              Card(child: Text('aaa')),
              Card(child: Text('aaa')),
              Card(child: Text('aaa')),
              Card(child: Text('aaa')),
              Card(child: Text('aaa')),
              SizedBox(height: 100),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 16.0,
            vertical: 32.0,
          ),
          child: AnimSearchBar(
            color: C.mainColor,
            autoFocus: true,
            width: MediaQuery.of(context).size.width,
            textController: _searchController,
            onSuffixTap: () {
              setState(() {
                _searchController.clear();
              });
            },
          ),
        ),
      ],
    );
  }
}
