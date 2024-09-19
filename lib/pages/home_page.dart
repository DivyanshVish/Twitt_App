import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:twitt/components/my_alert_dialog_box.dart';
import 'package:twitt/components/my_drawers.dart';
import 'package:twitt/components/my_post_tile.dart';
import 'package:twitt/helpers/navigator_page.dart';
import 'package:twitt/model/post_model.dart';
import 'package:twitt/provider/database_provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late final databaseProvider =
      Provider.of<DatabaseProvider>(context, listen: false);
  late final listeningProvider = Provider.of<DatabaseProvider>(context);
  TextEditingController postController = TextEditingController();

  // On StartUp
  @override
  void initState() {
    super.initState();
    loadAllPosts();
  }

  void loadAllPosts() async {
    await databaseProvider.loadAllPosts();
  }

  void _openPostMessageBox() {
    showDialog(
      context: context,
      builder: (context) => MyAlertDialogBox(
        textController: postController,
        onPressedText: 'Post',
        hintText: "What's on your mind....?",
        onpressed: () async {
          await postMessage(postController.text);
        },
      ),
    );
  }

  Future<void> postMessage(String message) async {
    await databaseProvider.postMessage(message);
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
          appBar: AppBar(
            foregroundColor: Theme.of(context).colorScheme.primary,
            centerTitle: true,
            title: const Text('H O M E'),
            bottom: TabBar(
              dividerColor: Colors.transparent,
              labelColor: Theme.of(context).colorScheme.inversePrimary,
              unselectedLabelColor: Theme.of(context).colorScheme.primary,
              indicatorColor: Theme.of(context).colorScheme.secondary,
              tabs: const [
                Tab(text: 'For You'),
                Tab(text: 'Following'),
              ],
            ),
          ),
          drawer: MyDrawers(),
          backgroundColor: Theme.of(context).colorScheme.surface,
          floatingActionButton: FloatingActionButton(
            onPressed: _openPostMessageBox,
            child: const Icon(Icons.add),
          ),
          body: TabBarView(children: [
            _buildPostList(listeningProvider.allPosts),
            _buildPostList(listeningProvider.followingPosts),
          ])),
    );
  }

  // build List UI given a list of Posts
  Widget _buildPostList(List<Post> posts) {
    return posts.isEmpty
        ? const Center(child: Text('No Posts Yet!'))
        : ListView.builder(
            itemCount: posts.length,
            itemBuilder: (context, index) {
              final post = posts[index];
              return MyPostTile(
                post: post,
                onUserTap: () => goToUserPage(context, post.uid),
                onPostTap: () => gotoPostPage(context, post),
              );
            },
          );
  }
}
