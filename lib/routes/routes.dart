import 'package:flutter/material.dart';
import 'package:thanxtory/pages/post/post_page.dart';
import 'package:thanxtory/pages/square/square_page.dart';

import '../pages/home/home_page.dart';

final routeBuilder = <String, Widget Function(BuildContext context)>{
  HomePage.path: (context) => const HomePage(
        key: ValueKey(HomePage.name),
      ),
  SquarePage.path: (context) => const SquarePage(
        key: ValueKey(SquarePage.name),
      ),
  PostPage.path: (context) => const PostPage(
        key: ValueKey(PostPage.name),
      ),
};
