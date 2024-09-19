import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:twitt/components/my_drawer_listtile.dart';
import 'package:twitt/pages/Search_page.dart';
import 'package:twitt/pages/profile_page.dart';
import 'package:twitt/services/auth/auth_services.dart';

import '../pages/setting_page.dart';

class MyDrawers extends StatelessWidget {
  MyDrawers({super.key});

  final _auth = AuthServices();

  void logout(BuildContext context) async {
    try {
      await _auth.logout(context);
    } catch (e) {
      log(e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Theme.of(context).colorScheme.surface,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 25.0),
          child: Column(
            children: [
              // App Logo
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 50.0),
                child: Icon(
                  Icons.person,
                  size: 72,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              Divider(
                color: Theme.of(context).colorScheme.primary,
              ),

              const SizedBox(
                height: 15,
              ),
              // Home list
              MyDrawerListTile(
                title: 'H O M E',
                icon: Icons.home,
                ontap: () {
                  Navigator.pop(context);
                },
              ),
              // User Profile
              MyDrawerListTile(
                title: 'P R O F I L E',
                icon: Icons.person,
                ontap: () {
                  Navigator.pop(context);
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) =>
                              ProfilePage(uid: _auth.getCurrentUserUid())));
                },
              ),
              // Search list
              MyDrawerListTile(
                title: 'S E A R C H',
                icon: Icons.search,
                ontap: () {
                  Navigator.pop(context);

                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const SearchPage()));
                },
              ),

              // setting list
              MyDrawerListTile(
                title: 'S E T T I N G S',
                icon: Icons.settings_rounded,
                ontap: () {
                  Navigator.pop(context);

                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const SettingPage()));
                },
              ),

              const Spacer(),
              // Logout
              MyDrawerListTile(
                title: 'L O G O U T',
                icon: Icons.logout,
                ontap: () => logout(context),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
