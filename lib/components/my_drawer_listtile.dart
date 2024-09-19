import 'package:flutter/material.dart';

class MyDrawerListTile extends StatelessWidget {
  final String title;
  final IconData icon;
  final void Function()? ontap;

  const MyDrawerListTile(
      {super.key,
      required this.title,
      required this.icon,
      required this.ontap});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon,color: Theme.of(context).colorScheme.primary,),

      title: Text(
        title,
        style: TextStyle(
          color: Theme.of(context).colorScheme.inversePrimary,
        ),
      ),
      onTap: ontap,
    );
  }
}
