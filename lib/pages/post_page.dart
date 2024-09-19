import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:twitt/components/my_comment_tile.dart';
import 'package:twitt/components/my_post_tile.dart';
import 'package:twitt/helpers/navigator_page.dart';
import 'package:twitt/provider/database_provider.dart';

import '../model/post_model.dart';

class PostPage extends StatefulWidget {
  final Post post;
  const PostPage({super.key, required this.post});

  @override
  State<PostPage> createState() => _PostPageState();
}

class _PostPageState extends State<PostPage> {
  late final listeningProvider = Provider.of<DatabaseProvider>(context);
  late final databaseProvider =
      Provider.of<DatabaseProvider>(context, listen: false);

  @override
  Widget build(BuildContext context) {
    final allComments = listeningProvider.getComments(widget.post.id);

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
      ),
      body: ListView(
        children: [
          MyPostTile(
            post: widget.post,
            onUserTap: () => goToUserPage(
              context,
              widget.post.uid,
            ),
            onPostTap: () {},
          ),
          allComments.isEmpty
              ? const Center(child: Text('No comments yet'))
              : ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: allComments.length,
                  itemBuilder: (context, index) {
                    final comment = allComments[index];
                    return MyCommentTile(
                      comment: comment,
                      onUserTap: () => goToUserPage(context, comment.uid),
                    );
                  },
                ),
        ],
      ),
    );
  }
}
