import 'package:flutter/material.dart';
import 'package:twitt/model/post_model.dart';
import 'package:twitt/pages/account_setting_page.dart';
import 'package:twitt/pages/blocked_user_page.dart';
import 'package:twitt/pages/home_page.dart';
import 'package:twitt/pages/profile_page.dart';

import '../pages/post_page.dart';

void goToUserPage(BuildContext context, String uid) {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => ProfilePage(uid: uid),
    ),
  );
}

void gotoPostPage(BuildContext context, Post post) {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => PostPage(post: post),
    ),
  );
}

void gotoBlockedUsersPage(BuildContext context) {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => const BlockedUsersPage(),
    ),
  );
}

void gotoAccountSettingPage(BuildContext context) {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => const AccountSettingPage(),
    ),
  );
}

void goHomePage(BuildContext context) {
  Navigator.pushAndRemoveUntil(
    context,
    MaterialPageRoute(
      builder: (context) => const HomePage(),
    ),
    (route) => route.isFirst,
  );
}
