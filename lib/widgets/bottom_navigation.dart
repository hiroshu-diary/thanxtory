import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../model/constant.dart';
import '../pages/home/home_page.dart';
import '../pages/post/post_page.dart';
import '../pages/profile/profile_page.dart';

BottomNavigationBar kBuildBottomNavigationBar(
  BuildContext context,
  int currentIndex,
) {
  return BottomNavigationBar(
    elevation: 0,
    currentIndex: currentIndex,
    selectedItemColor: C.subColor,
    unselectedItemColor: C.mainColor,
    type: BottomNavigationBarType.fixed,
    onTap: (index) {
      if (index == 0 && currentIndex != 0) {
        Navigator.pop(context);
      }
      if (index == 1) {
        if (todayThanks < 3) {
          Nav.navigate360(
            context,
            const Offset(0, 1),
            const PostPage(),
          );
        } else {
          Nav.whiteNavi(
            context,
            const PostPage(),
            10,
          );
        }
      }
      if (index == 2 && currentIndex != 2) {
        Nav.whiteNavi(
          context,
          const ProfilePage(userId: '', isMe: true),
          10,
        );
      }
    },
    items: [
      const BottomNavigationBarItem(
        label: 'スクエア',
        tooltip: '',
        icon: Icon(CupertinoIcons.square_on_square),
        activeIcon: Icon(CupertinoIcons.square_fill_on_square_fill),
      ),
      BottomNavigationBarItem(
        label: '伝える',
        icon: todayThanks < 3
            ? const Icon(FontAwesomeIcons.paperPlane)
            : const CircleAvatar(
                maxRadius: 16,
                backgroundColor: Colors.transparent,
                backgroundImage: AssetImage('assets/images/max.png'),
              ),
        activeIcon: todayThanks < 3
            ? const Icon(FontAwesomeIcons.solidPaperPlane)
            : const CircleAvatar(
                maxRadius: 16,
                backgroundColor: Colors.transparent,
                backgroundImage: AssetImage('assets/images/max.png'),
              ),
      ),
      const BottomNavigationBarItem(
        label: 'あなた',
        tooltip: '',
        icon: Icon(CupertinoIcons.person),
        activeIcon: Icon(CupertinoIcons.person_fill),
      ),
    ],
  );
}
