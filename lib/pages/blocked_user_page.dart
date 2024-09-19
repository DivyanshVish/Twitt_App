import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:twitt/provider/database_provider.dart';

class BlockedUsersPage extends StatefulWidget {
  const BlockedUsersPage({super.key});

  @override
  State<BlockedUsersPage> createState() => _BlockedUsersPageState();
}

class _BlockedUsersPageState extends State<BlockedUsersPage> {
  late final listeningProvider = Provider.of<DatabaseProvider>(context);
  late final datebaseProvider =
      Provider.of<DatabaseProvider>(context, listen: false);

  // on Startup

  @override
  void initState() {
    super.initState();
    // Load Blocked Users
    loadBlockedUsers();
  }

  Future<void> loadBlockedUsers() async {
    await datebaseProvider.loadBlockUser();
  }

  void _showUnblockBox(String userId) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Unblock User'),
          content: const Text('Are you sure you want to unblock this user?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                // Unblock User
                await datebaseProvider.unblockUser(userId);

                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('User Unblocked!!!')));
              },
              child: const Text('Unblock'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // Listens to Blocked Users
    final blockedUsers = listeningProvider.blockUsers;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        foregroundColor: Theme.of(context).colorScheme.primary,
        centerTitle: true,
        title: const Text('Blocked Users'),
      ),
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: blockedUsers.isEmpty
          ? const Center(
              child: Text("No Blocked Users..."),
            )
          : ListView.builder(
              itemCount: blockedUsers.length,
              itemBuilder: (context, index) {
                final user = blockedUsers[index];
                return ListTile(
                  title: Text(user.name),
                  subtitle: Text('@${user.username}'),
                  trailing: IconButton(
                    icon: const Icon(Icons.block_rounded),
                    onPressed: () => _showUnblockBox(user.uid),
                  ),
                );
              },
            ),
    );
  }
}
