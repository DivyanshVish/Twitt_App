
import 'package:flutter/material.dart';

class MySettingListTile extends StatelessWidget {
  final String title;
  final Widget action;
  const MySettingListTile(
      {super.key, required this.title, required this.action});

  @override
  Widget build(BuildContext context) {
    return Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.secondary,
          borderRadius: BorderRadius.circular(12),
        ),
        margin: const EdgeInsets.only(top: 10, right: 25, left: 25),
        padding: const EdgeInsets.all(25),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            action,
          ],
        ));
  }
}
