import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../model/constant.dart';
import '../../model/list.dart';

class SquarePage extends StatefulWidget {
  const SquarePage({Key? key}) : super(key: key);
  static const path = '/square/';
  static const name = 'SquarePage';

  @override
  _SquarePageState createState() => _SquarePageState();
}

class _SquarePageState extends State<SquarePage> {
  @override
  void initState() {
    int today = int.parse(DateFormat('yyyyMMdd').format(DateTime.now()));
    if (today > lastPostDay) {
      todayThanks = 0;
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    //todo 引っ張って更新できるようにする
    //todo servedPostsの各uidのドキュメントをでCollectionGroup等で取得し、時系列順でstreamBuilderで標示
    //更新時はCupertinoActivityIndicator
    return ListView.builder(
      padding: EdgeInsets.zero,
      itemCount: allList.length,
      itemBuilder: (BuildContext context, int index) {
        if (timeSequence == true) {
          allList.shuffle();
        }
        return allList.reversed.toList()[index];
      },
    );
  }
}
