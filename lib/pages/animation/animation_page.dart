import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:thanxtory/model/scaffold_messenger_controller.dart';

import '../../model/constant.dart';
import '../home/home_page.dart';

class AnimationPage extends StatefulWidget {
  final int count;
  const AnimationPage({Key? key, required this.count}) : super(key: key);
  static const path = '/animation/';
  static const name = 'AnimationPage';

  @override
  _AnimationPageState createState() => _AnimationPageState();
}

class _AnimationPageState extends State<AnimationPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<Alignment> _alignment;
  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1390),
      lowerBound: -0.6,
      upperBound: 1.2,
    );
    _alignment = _animationController.drive(
      AlignmentTween(
        begin: Alignment.bottomLeft,
        end: Alignment.topRight,
      ),
    );
    returnNext();
  }

  Future<void> returnNext() async {
    await _animationController.forward();
    Nav.navigate(
      context,
      const HomePage(),
      const Offset(0, 0),
    );

    late String _text;
    if (widget.count == 0) {
      _text = '今日も素敵な感謝を\nありがとうございます！！';
    } else {
      _text = '素敵な一日でしたね！\n１日３投稿達成です！！';
    }

    if (mounted) {
      if (widget.count == 0 || widget.count == 2) {
        await context.read<SMController>().showAchievement(_text);
      }
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AlignTransition(
        alignment: _alignment,
        child: SizedBox(
          width: 100,
          height: 100,
          child: Image.asset('assets/images/didThanks.png'),
        ),
      ),
    );
  }
}
