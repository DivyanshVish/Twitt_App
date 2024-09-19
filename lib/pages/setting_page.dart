import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:twitt/components/my_setting_list_tile.dart';
import 'package:twitt/helpers/navigator_page.dart';
import 'package:twitt/provider/theme_provider.dart';

class SettingPage extends StatelessWidget {
  const SettingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        foregroundColor: Theme.of(context).colorScheme.primary,
        centerTitle: true,
        title: const Text('S E T T I N G S'),
      ),
      body: Column(
        children: [
          MySettingListTile(
            title: 'Dark mode',
            action: CupertinoSwitch(
              value:
                  Provider.of<ThemeProvider>(context, listen: false).isDarkMode,
              onChanged: (value) =>
                  Provider.of<ThemeProvider>(context, listen: false)
                      .toggleTheme(),
            ),
          ),
          // Blocked Users tile
          MySettingListTile(
            title: "Blocked Users",
            action: IconButton(
              onPressed: () => gotoBlockedUsersPage(context),
              icon: Icon(
                Icons.arrow_forward_ios,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ),

          // Account Setting tile
          MySettingListTile(
            title: "Accounts Settings",
            action: IconButton(
              onPressed: () => gotoAccountSettingPage(context),
              icon: Icon(
                Icons.settings,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
