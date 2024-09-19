import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:twitt/components/my_user_list_tile.dart';
import 'package:twitt/provider/database_provider.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final _searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final databaseProvider =
        Provider.of<DatabaseProvider>(context, listen: false);
    final listeningProvider = Provider.of<DatabaseProvider>(context);
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: TextField(
          controller: _searchController,
          decoration: InputDecoration(
            hintStyle: TextStyle(
              color: Theme.of(context).colorScheme.primary,
            ),
            hintText: 'Search users...',
            border: InputBorder.none,
          ),
          onChanged: (value) {
            // search user
            if (value.isNotEmpty) {
              databaseProvider.searchUsers(value);
            } else {
              databaseProvider.searchUsers("");
            }
          },
        ),
      ),
      body: listeningProvider.searchResults.isEmpty
          ? const Center(
              child: Text('No users found!!!'),
            )
          : ListView.builder(
              itemCount: listeningProvider.searchResults.length,
              itemBuilder: (context, index) {
                final user = listeningProvider.searchResults[index];
                return MyUserTile(user: user);
              },
            ),
    );
  }
}
