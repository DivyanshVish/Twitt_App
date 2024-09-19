// ignore_for_file: unused_local_variable

import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:twitt/model/comment_model.dart';
import 'package:twitt/model/post_model.dart';

import '../model/user_model.dart';
import '../services/auth/auth_services.dart';
import '../services/database/database_service.dart';

class DatabaseProvider extends ChangeNotifier {
  final _auth = AuthServices();
  final _db = DatabaseService();

  Future<UserProfile?> userProfile(String uid) => _db.getUserFromFirebase(uid);

  Future<void> updateUserBio(String bio) => _db.updateUserBioInFirebase(bio);

  List<Post> _allPosts = [];
  List<Post> _followingPosts = [];

  List<Post> get allPosts => _allPosts;
  List<Post> get followingPosts => _followingPosts;

  Future<void> postMessage(String message) async {
    await _db.postMessageToFirebase(message);
    await loadAllPosts();
    notifyListeners();
  }

  Future<void> loadAllPosts() async {
    final allPosts = await _db.getAllPostFromFirebase();
    _allPosts = allPosts;
    final blockedUserIds = await _db.getBlockedUserUidFromFirebase();

    _allPosts =
        allPosts.where((post) => !blockedUserIds.contains(post.uid)).toList();

    // Filter out the Following Posts
    loadFollowingPosts();

    initialLikeMap();
    notifyListeners();
  }

  List<Post> filterUserPosts(String uid) {
    return _allPosts.where((post) => post.uid == uid).toList();
  }

  Future<void> loadFollowingPosts() async {
    String currentUid = _auth.getCurrentUserUid();
    final followingUids = await _db.getFollowingUidFromFirebase(currentUid);

    _followingPosts =
        _allPosts.where((post) => followingUids.contains(post.uid)).toList();

    notifyListeners();
  }

  Future<void> deletePost(String postId) async {
    await _db.deletePostFromFirebase(postId);
    await loadAllPosts();
    notifyListeners();
  }

  Map<String, int> _likeCounts = {};
  List<String> _likedPosts = [];

  bool isPostLikedByCurrentUser(String postId) => _likedPosts.contains(postId);
  int getLikedCount(String postId) => _likeCounts[postId] ?? 0;

  void initialLikeMap() {
    final currentUserId = _auth.getCurrentUserUid();
    _likedPosts.clear();
    for (var post in _allPosts) {
      _likeCounts[post.id] = post.likeCount;
      if (post.likedBy.contains(currentUserId)) {
        _likedPosts.add(post.id);
      }
    }
  }

  Future<void> toggleLike(String postId) async {
    final likedPostOriginal = _likedPosts;
    final likeCountOriginal = _likeCounts;
    if (_likedPosts.contains(postId)) {
      _likedPosts.remove(postId);
      _likeCounts[postId] = (_likeCounts[postId] ?? 0) - 1;
    } else {
      _likedPosts.add(postId);
      _likeCounts[postId] = (_likeCounts[postId] ?? 0) + 1;
    }
    notifyListeners();

    try {
      await _db.toggleLikeInFirebase(postId);
    } catch (e) {
      _likedPosts = likedPostOriginal;
      _likeCounts = likeCountOriginal;
      notifyListeners();
    }
  }

  // Comments
  final Map<String, List<CommentModel>> _comments = {};

  List<CommentModel> getComments(String postId) {
    return _comments[postId] ?? [];
  }

  Future<void> loadComments(String postId) async {
    final comments = await _db.getCommentsFromFirebase(postId);
    _comments[postId] = comments;
    notifyListeners();
  }

  Future<void> addComment(String postId, String message) async {
    await _db.addCommentToFirebase(postId, message);
    await loadComments(postId);
    notifyListeners();
  }

  Future<void> deleteComment(String commentId, postId) async {
    await _db.deleteCommentFromFirebase(commentId);
    await loadComments(postId);
    notifyListeners();
  }

  // Report

  List<UserProfile> _blockUsers = [];
  List<UserProfile> get blockUsers => _blockUsers;

  Future<void> loadBlockUser() async {
    final blockUserId = await _db.getBlockedUserUidFromFirebase();
    final blockedUserData =
        await Future.wait(blockUserId.map((id) => _db.getUserFromFirebase(id)));
    _blockUsers = blockedUserData.whereType<UserProfile>().toList();
    notifyListeners();
  }

  Future<void> blockUser(String userId) async {
    await _db.blockUserInFirebase(userId);
    await loadBlockUser();
    await loadAllPosts();
    notifyListeners();
  }

  Future<void> unblockUser(String blockUserId) async {
    await _db.unblockUserInFirebase(blockUserId);
    await loadBlockUser();
    await loadAllPosts();
    notifyListeners();
  }

  Future<void> reportUser(String postId, userId) async {
    await _db.reportPostInFirebase(postId, userId);
  }

  // Follow
  // Update the types of _followingCount and _followersCount to store integers
  final Map<String, int> _followingCount = {};
  final Map<String, int> _followersCount = {};
  final Map<String, List<String>> _following = {};
  final Map<String, List<String>> _followers = {};

// Get the count of followers & following
  int getFollowingCount(String uid) => _followingCount[uid] ?? 0;
  int getFollowersCount(String uid) => _followersCount[uid] ?? 0;

// Load followers & following
  Future<void> loadFollowers(String uid) async {
    final listOfFollowers = await _db.getFollowersUidFromFirebase(uid);

    _followers[uid] = listOfFollowers;
    _followersCount[uid] = listOfFollowers.length; // Store the count as int

    notifyListeners();
  }

  Future<void> loadFollowing(String uid) async {
    final listOfFollowing = await _db.getFollowingUidFromFirebase(uid);

    _following[uid] = listOfFollowing;
    _followingCount[uid] = listOfFollowing.length; // Store the count as int

    notifyListeners();
  }

// Follow & Unfollow
  Future<void> followUser(String targetUserId) async {
    final currentUserId = _auth.getCurrentUserUid();

    _followers.putIfAbsent(currentUserId, () => []);
    _following.putIfAbsent(currentUserId, () => []);

    if (!_followers[targetUserId]!.contains(currentUserId)) {
      _followers[targetUserId]?.add(currentUserId);
      _followersCount[targetUserId] =
          (_followersCount[targetUserId] ?? 0) + 1; // Increment the count

      _following[currentUserId]?.add(targetUserId);
      _followingCount[currentUserId] =
          (_followingCount[currentUserId] ?? 0) + 1; // Increment the count
    }

    notifyListeners();

    try {
      await _db.followUserInFirebase(targetUserId);
      await loadFollowing(currentUserId);
      await loadFollowers(currentUserId);
    } catch (e) {
      // Rollback changes in case of error
      _followers[targetUserId]?.remove(currentUserId);
      _followersCount[targetUserId] =
          (_followersCount[targetUserId] ?? 0) - 1; // Decrement the count

      _following[currentUserId]?.remove(targetUserId);
      _followingCount[currentUserId] =
          (_followingCount[currentUserId] ?? 0) - 1; // Decrement the count

      notifyListeners();
    }
  }

// Unfollow User
  Future<void> unfollowUser(String targetUserId) async {
    final currentUserId = _auth.getCurrentUserUid();

    _followers.putIfAbsent(currentUserId, () => []);
    _following.putIfAbsent(currentUserId, () => []);

    if (_followers[targetUserId]!.contains(currentUserId)) {
      _followers[targetUserId]?.remove(currentUserId);
      _followersCount[targetUserId] =
          (_followersCount[targetUserId] ?? 1) - 1; // Decrement the count

      _following[currentUserId]?.remove(targetUserId);
      _followingCount[currentUserId] =
          (_followingCount[currentUserId] ?? 1) - 1; // Decrement the count
    }

    notifyListeners();

    try {
      await _db.unfollowUserInFirebase(targetUserId);
      await loadFollowing(currentUserId);
      await loadFollowers(currentUserId);
    } catch (e) {
      // Rollback changes in case of error
      _followers[targetUserId]?.add(currentUserId);
      _followersCount[targetUserId] =
          (_followersCount[targetUserId] ?? 0) + 1; // Increment the count

      _following[currentUserId]?.add(targetUserId);
      _followingCount[currentUserId] =
          (_followingCount[currentUserId] ?? 0) + 1; // Increment the count

      notifyListeners();
    }
  }

// Check if the current user is following the target user
  bool isFollowing(String uid) {
    final currentUserId = _auth.getCurrentUserUid();
    return _followers[uid]?.contains(currentUserId) ?? false;
  }

  // Map of profiles
  final Map<String, List<UserProfile>> _followersProfile = {};
  final Map<String, List<UserProfile>> _followingProfile = {};

  List<UserProfile> getListOfFollowersProfile(String uid) =>
      _followersProfile[uid] ?? [];

  List<UserProfile> getListOfFollowingProfile(String uid) =>
      _followingProfile[uid] ?? [];

  Future<void> loadUserFollowersProfiles(String uid) async {
    try {
      final followersIds = await _db.getFollowersUidFromFirebase(uid);

      List<UserProfile> followersProfiles = [];

      for (String followerId in followersIds) {
        UserProfile? followerProfile =
            await _db.getUserFromFirebase(followerId);
        if (followerProfile != null) {
          followersProfiles.add(followerProfile);
        }
        _followersProfile[uid] = followersProfiles;
        notifyListeners();
      }
    } catch (e) {
      log(e.toString());
    }
  }

  // Following
  Future<void> loadUserFollowingProfiles(String uid) async {
    try {
      final followingIds = await _db.getFollowingUidFromFirebase(uid);

      List<UserProfile> followingProfiles = [];

      for (String followingId in followingIds) {
        UserProfile? followerProfile =
            await _db.getUserFromFirebase(followingId);
        if (followerProfile != null) {
          followingProfiles.add(followerProfile);
        }
        _followingProfile[uid] = followingProfiles;
        notifyListeners();
      }
    } catch (e) {
      log(e.toString());
    }
  }

  // Search
  List<UserProfile> _searchResults = [];

  List<UserProfile> get searchResults => _searchResults;

  Future<void> searchUsers(String searchTerm) async {
    try {
      final results = await _db.searchUsersInFirebase(searchTerm);
      _searchResults = results;
      notifyListeners();
    } catch (e) {
      log(e.toString());
    }
  }
}
