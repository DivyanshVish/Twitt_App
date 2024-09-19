import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:twitt/components/my_alert_dialog_box.dart';
import 'package:twitt/components/my_bio_box.dart';
import 'package:twitt/components/my_follow_btn.dart';
import 'package:twitt/components/my_post_tile.dart';
import 'package:twitt/components/my_profile_state.dart';
import 'package:twitt/helpers/navigator_page.dart';
import 'package:twitt/model/user_model.dart';
import 'package:twitt/pages/follow_list_page.dart';
import 'package:twitt/provider/database_provider.dart';
import 'package:twitt/services/auth/auth_services.dart';

class ProfilePage extends StatefulWidget {
  final String uid;
  const ProfilePage({super.key, required this.uid});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late final listeningProvider = Provider.of<DatabaseProvider>(context);
  late final databaseProvider =
      Provider.of<DatabaseProvider>(context, listen: false);

  UserProfile? user;
  String currentUserId = AuthServices().getCurrentUserUid();
  final bioController = TextEditingController();

  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    loadUser();
  }

  Future<void> loadUser() async {
    user = await databaseProvider.userProfile(widget.uid);

    await databaseProvider.loadFollowers(widget.uid);
    await databaseProvider.loadFollowing(widget.uid);

    _isFollowing = databaseProvider.isFollowing(widget.uid);
    setState(() {
      _isLoading = false;
    });
  }

  void _editBioBox() {
    showDialog(
      context: context,
      builder: (context) => MyAlertDialogBox(
        textController: bioController,
        hintText: "Edit Bio...",
        onPressedText: 'Save',
        onpressed: saveBio,
      ),
    );
  }

  Future<void> saveBio() async {
    setState(() {
      _isLoading = true;
    });
    await databaseProvider.updateUserBio(bioController.text);
    await loadUser();

    setState(() {
      _isLoading = false;
    });
  }

  bool _isFollowing = false;

  // Future<void> toggleFollow() async {
  //   setState(() {
  //     _isLoading = true;
  //   });
  //   if (_isFollowing) {
  //     showDialog(
  //       context: context,
  //       builder: (context) => AlertDialog(
  //         title: const Text('Unfollow'),
  //         content: const Text('Are you sure you want to unfollow this user?'),
  //         actions: [
  //           TextButton(
  //             onPressed: () {
  //               Navigator.pop(context);
  //             },
  //             child: const Text('Cancel'),
  //           ),
  //           TextButton(
  //             onPressed: () async {
  //               Navigator.pop(context);
  //               await databaseProvider.unfollowUser(widget.uid);
  //               loadUser();
  //               setState(() {
  //                 _isLoading = false;
  //               });
  //             },
  //             child: const Text('Yes'),
  //           ),
  //         ],
  //       ),
  //     );
  //   } else {
  //     await databaseProvider.followUser(widget.uid);
  //   }
  //   // await loadUser();
  //   setState(() {
  //     _isFollowing = !_isFollowing;
  //   });
  // }
  Future<void> toggleFollow() async {
    setState(() {
      _isLoading = true;
    });

    if (_isFollowing) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Unfollow'),
          content: const Text('Are you sure you want to unfollow this user?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close dialog on cancel
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.pop(context); // Close dialog after confirming

                // Unfollow user
                await databaseProvider.unfollowUser(widget.uid);

                // Reload user data and followers/following status
                await loadUser();

                // Reset loading state
                setState(() {
                  _isLoading = false;
                });
              },
              child: const Text('Yes'),
            ),
          ],
        ),
      );
    } else {
      // Follow user
      await databaseProvider.followUser(widget.uid);

      // Reload user data and followers/following status
      await loadUser();

      // Reset loading state and update follow status
      setState(() {
        _isLoading = false;
        _isFollowing = true; // User is now following
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final followersCount = listeningProvider.getFollowersCount(widget.uid);
    final followingCount = listeningProvider.getFollowingCount(widget.uid);
    final allUserPosts = listeningProvider.filterUserPosts(widget.uid);

    _isFollowing = listeningProvider.isFollowing(widget.uid);

    // get user Posts
    final allUserPost = listeningProvider.filterUserPosts(widget.uid);
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      // AppBar
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new),
          onPressed: () => goHomePage(context),
        ),
        foregroundColor: Theme.of(context).colorScheme.primary,
        title: _isLoading
            ? const Text("Loading...")
            : Text(user != null ? user!.name : "Profile"),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              children: [
                Center(
                  child: Text(
                    _isLoading ? "Loading..." : "@${user!.username}",
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ),
                const SizedBox(height: 25),
                Center(
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(25),
                      color: Theme.of(context).colorScheme.secondary,
                    ),
                    padding: const EdgeInsets.all(25),
                    child: Icon(
                      Icons.person,
                      size: 72,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ),
                const SizedBox(height: 25),

                // Profile Stats
                MyProfileState(
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => FollowListPage(
                        uid: widget.uid,
                      ),
                    ),
                  ),
                  postCount: allUserPosts.length,
                  followerCount: followersCount,
                  followingCount: followingCount,
                ),
                const SizedBox(height: 25),

                // Follow/Unfollow Btn
                if (user != null && user!.uid != currentUserId)
                  MyFollowBtn(
                    onPressed: toggleFollow,
                    isFollowing: _isFollowing,
                  ),

                // Edit Bio Button
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 25.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "BIO",
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                      if (user != null && user!.uid == currentUserId)
                        GestureDetector(
                          onTap: _editBioBox,
                          child: Icon(
                            Icons.settings,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        )
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                // Bio Box
                MyBioBox(text: _isLoading ? "Loading..." : user!.bio),
                Padding(
                  padding:
                      const EdgeInsets.only(top: 25.0, left: 25, bottom: 10),
                  child: Text('Posts',
                      style: TextStyle(
                          color: Theme.of(context).colorScheme.primary)),
                ),
                //list of posts by user
                allUserPost.isEmpty
                    ? const Center(child: Text('No Posts Yet...!'))
                    : ListView.builder(
                        physics: const NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        itemCount: allUserPost.length,
                        itemBuilder: (context, index) {
                          final post = allUserPost[index];
                          return MyPostTile(
                            post: post,
                            onUserTap: () {},
                            onPostTap: () => gotoPostPage(context, post),
                          );
                        }),
              ],
            ),
    );
  }
}
