import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:twitt/model/comment_model.dart';
import 'package:twitt/provider/database_provider.dart';

import '../services/auth/auth_services.dart';

class MyCommentTile extends StatelessWidget {
  final CommentModel comment;
  final void Function()? onUserTap;

  const MyCommentTile({
    super.key,
    required this.comment,
    required this.onUserTap,
  });

  // Show options for the post
  void _showOptions(BuildContext context) {
    String currentUid = AuthServices().getCurrentUserUid();
    final bool isOwnComment = comment.uid == currentUid;

    showModalBottomSheet(
        context: context,
        builder: (context) {
          return SafeArea(
            child: Wrap(
              children: [
                if (isOwnComment)
                  ListTile(
                    leading: const Icon(Icons.delete),
                    title: const Text('Delete'),
                    onTap: () async {
                      Navigator.pop(context);
                      await Provider.of<DatabaseProvider>(context,
                              listen: false)
                          .deleteComment(comment.id, comment.postId);
                    },
                  )
                else ...[
                  ListTile(
                    leading: const Icon(Icons.flag),
                    title: const Text('Report'),
                    onTap: () {},
                  ),
                  ListTile(
                    leading: const Icon(Icons.block),
                    title: const Text('Block User'),
                    onTap: () {},
                  ),
                ],
                ListTile(
                  leading: const Icon(Icons.cancel_outlined),
                  title: const Text('Cancel'),
                  onTap: () => Navigator.pop(context),
                )
              ],
            ),
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      //padding inside the container
      margin: const EdgeInsets.symmetric(horizontal: 25, vertical: 5),
      //Padding outside the container
      padding: const EdgeInsets.all(20),

      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.tertiary,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: onUserTap,
            child: Row(
              children: [
                Icon(
                  Icons.person,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 10),
                Text(
                  comment.name,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                const SizedBox(width: 5),
                Text(
                  '@${comment.username}',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                const Spacer(),
                GestureDetector(
                    onTap: () => _showOptions(context),
                    child: Icon(
                      Icons.more_horiz,
                      color: Theme.of(context).colorScheme.primary,
                    ))
              ],
            ),
          ),
          const SizedBox(height: 20),
          Text(
            comment.message,
            style: TextStyle(
              color: Theme.of(context).colorScheme.inversePrimary,
            ),
          ),
        ],
      ),
    );
  }
}
