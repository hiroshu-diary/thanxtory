import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:thanxtory/model/scaffold_messenger_controller.dart';
import '../../model/constant.dart';
import '../home/home_page.dart';

class AnimationPage extends StatefulWidget {
  const AnimationPage({Key? key}) : super(key: key);
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
    // Navigator.popUntil(context, (Route<dynamic> route) => route.isFirst);

    late String _text;
    if (todayThanks == 1) {
      _text = '今日も素敵な感謝を、\nありがとうございます！！';
    } else if (todayThanks == 2) {
      _text = '調子が良いですね！\nその勢いです！！';
    } else {
      _text = '素敵な一日でしたね！\n１日３投稿達成です！！';
    }

    if (mounted) {
      await context.read<ScaffoldMessengerController>().showAchievement(_text);
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
