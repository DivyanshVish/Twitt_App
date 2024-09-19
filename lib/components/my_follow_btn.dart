import 'package:flutter/material.dart';

class MyFollowBtn extends StatelessWidget {
  final void Function()? onPressed;
  final bool isFollowing;
  const MyFollowBtn(
      {super.key, required this.onPressed, required this.isFollowing});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(25),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: MaterialButton(
          onPressed: onPressed,
          color:
              isFollowing ? Theme.of(context).colorScheme.primary : Colors.blue,
          padding: const EdgeInsets.all(25),
          child: Text(
            isFollowing ? "Unfollow" : 'Follow',
            style: TextStyle(
              color: Theme.of(context).colorScheme.tertiary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}
