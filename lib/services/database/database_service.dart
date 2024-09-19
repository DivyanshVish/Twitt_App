import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:twitt/model/comment_model.dart';
import 'package:twitt/model/post_model.dart';
import 'package:twitt/model/user_model.dart';
import 'package:twitt/services/auth/auth_services.dart';

class DatabaseService {
  final _db = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  Future<void> saveUserInfoInFirebase({
    required String name,
    required String email,
  }) async {
    String uid = _auth.currentUser!.uid;
    try {
      String username = email.split('@')[0];

      UserProfile user = UserProfile(
        uid: uid,
        name: name,
        email: email,
        username: username,
        bio: '',
      );

      final userMap = user.toMap();

      await _db.collection("Users").doc(uid).set(userMap);
      log('User info saved successfully for UID: $uid');
    } catch (e) {
      log('Failed to save user info: $e');
    }
  }

  Future<UserProfile?> getUserFromFirebase(String uid) async {
    try {
      DocumentSnapshot userDoc = await _db.collection("Users").doc(uid).get();
      if (userDoc.exists) {
        return UserProfile.fromDocument(userDoc);
      }
      log('User document does not exist for UID: $uid');
      return null;
    } catch (e) {
      log('Failed to get user info: $e');
      return null;
    }
  }

  Future<void> updateUserBioInFirebase(String bio) async {
    String uid = AuthServices().getCurrentUserUid();
    try {
      await _db.collection("Users").doc(uid).update({'bio': bio});
      log('Bio updated successfully for UID: $uid');
    } catch (e) {
      log('Failed to update bio: $e');
    }
  }

  // Delete User Info
  Future<void> deleteUserInfoFromFirebase(String uid) async {
    WriteBatch batch = _db.batch();

    // delete user document
    DocumentReference userDoc = _db.collection("Users").doc(uid);
    batch.delete(userDoc);

    // delete user posts
    QuerySnapshot userPosts =
        await _db.collection("Posts").where('uid', isEqualTo: uid).get();
    for (var post in userPosts.docs) {
      batch.delete(post.reference);
    }

    // delete user comments
    QuerySnapshot userComments =
        await _db.collection("Comments").where('uid', isEqualTo: uid).get();
    for (var comments in userComments.docs) {
      batch.delete(comments.reference);
    }
    // delete user likes
    QuerySnapshot allPosts = await _db.collection("Posts").get();
    for (QueryDocumentSnapshot post in allPosts.docs) {
      Map<String, dynamic> postData = post.data() as Map<String, dynamic>;
      var likedBy = postData['likedBy'] as List<dynamic>? ?? [];
      if (likedBy.contains(uid)) {
        batch.update(post.reference, {
          'likedBy': FieldValue.arrayRemove([uid]),
          'likeCount': FieldValue.increment(-1),
        });
      }
    }

    // update followers and following records

    // Commit batch
    await batch.commit();
  }

  // Posts

  Future<void> postMessageToFirebase(String message) async {
    try {
      String uid = _auth.currentUser!.uid;
      UserProfile? user = await getUserFromFirebase(uid);

      Post newPost = Post(
        id: '',
        uid: uid,
        name: user!.name,
        username: user.username,
        message: message,
        timestamp: Timestamp.now(),
        likedBy: [],
        likeCount: 0,
      );
      Map<String, dynamic> newPostMap = newPost.toMap();
      await _db.collection("Posts").add(newPostMap);
    } catch (e) {
      log(e.toString());
    }
  }

  Future<List<Post>> getAllPostFromFirebase() async {
    try {
      QuerySnapshot snapshot = await _db
          .collection("Posts")
          .orderBy('timestamp', descending: true)
          .get();
      return snapshot.docs.map((doc) => Post.fromDocument(doc)).toList();
    } catch (e) {
      return [];
    }
  }

  Future<void> deletePostFromFirebase(String postId) async {
    try {
      await _db.collection("Posts").doc(postId).delete();
    } catch (e) {
      log('Failed to delete post: $e');
    }
  }

  Future<void> toggleLikeInFirebase(String postId) async {
    try {
      String uid = _auth.currentUser!.uid;
      DocumentReference postDoc = _db.collection("Posts").doc(postId);
      await _db.runTransaction(
        (transaction) async {
          DocumentSnapshot postSnapShot = await transaction.get(postDoc);
          List<String> likedBy =
              List<String>.from(postSnapShot['likedBy'] ?? []);
          int currentLikeCount = postSnapShot['likeCount'];
          if (!likedBy.contains(uid)) {
            likedBy.add(uid);
            currentLikeCount++;
          } else {
            likedBy.remove(uid);
            currentLikeCount--;
          }
          transaction.update(postDoc, {
            'likedBy': likedBy,
            'likeCount': currentLikeCount,
          });
        },
      );
    } catch (e) {
      log(e.toString());
    }
  }

  // Comments
  Future<void> addCommentToFirebase(String postId, message) async {
    try {
      String uid = _auth.currentUser!.uid;
      UserProfile? user = await getUserFromFirebase(uid);
      CommentModel newComment = CommentModel(
        id: '',
        postId: postId,
        uid: uid,
        name: user!.name,
        username: user.username,
        message: message,
        timestamp: Timestamp.now(),
      );
      Map<String, dynamic> newCommentMap = newComment.toMap();
      await _db.collection("Comments").add(newCommentMap);
    } catch (e) {
      log(e.toString());
    }
  }

  // Delete comment
  Future<void> deleteCommentFromFirebase(String commentId) async {
    try {
      await _db.collection("Comments").doc(commentId).delete();
    } catch (e) {
      log('Failed to delete comment: $e');
    }
  }

  // Get comments
  Future<List<CommentModel>> getCommentsFromFirebase(String postId) async {
    try {
      QuerySnapshot snapshot = await _db
          .collection("Comments")
          .where('postId', isEqualTo: postId)
          .get();
      return snapshot.docs
          .map((doc) => CommentModel.fromDocument(doc))
          .toList();
    } catch (e) {
      return [];
    }
  }

  // Report Post
  Future<void> reportPostInFirebase(String postId, userId) async {
    final currentUserId = _auth.currentUser!.uid;

    final report = {
      'reportedBy': currentUserId,
      'messageOwnerId': userId,
      'messageId': postId,
      'timestamp': FieldValue.serverTimestamp(),
    };

    await _db.collection('Reports').add(report);
  }

  // Block User
  Future<void> blockUserInFirebase(String userId) async {
    final currentUserId = _auth.currentUser!.uid;

    await _db
        .collection('Users')
        .doc(currentUserId)
        .collection('BlockedUsers')
        .doc(userId)
        .set({});
  }

  // UnBlock User
  Future<void> unblockUserInFirebase(String blockUserId) async {
    final currentUserId = _auth.currentUser!.uid;

    await _db
        .collection('Users')
        .doc(currentUserId)
        .collection('BlockedUsers')
        .doc(blockUserId)
        .delete();
  }

  // Get all blocked users
  Future<List<String>> getBlockedUserUidFromFirebase() async {
    final currentUserId = _auth.currentUser!.uid;
    final snapshot = await _db
        .collection('Users')
        .doc(currentUserId)
        .collection('BlockedUsers')
        .get();
    return snapshot.docs.map((doc) => doc.id).toList();
  }

  // Follow

  // Follow User
  Future<void> followUserInFirebase(String uid) async {
    final currentUserId = _auth.currentUser!.uid;

    await _db
        .collection('Users')
        .doc(currentUserId)
        .collection('Following')
        .doc(uid)
        .set({});

    await _db
        .collection('Users')
        .doc(uid)
        .collection('Followers')
        .doc(currentUserId)
        .set({});
  }

  // UnFollow User
  Future<void> unfollowUserInFirebase(String uid) async {
    final currentUserId = _auth.currentUser!.uid;

    await _db
        .collection('Users')
        .doc(currentUserId)
        .collection('Following')
        .doc(uid)
        .delete();

    await _db
        .collection('Users')
        .doc(uid)
        .collection('Followers')
        .doc(currentUserId)
        .delete();
  }

  // Get a user's followers: list of uid
  Future<List<String>> getFollowersUidFromFirebase(String uid) async {
    final snapshot =
        await _db.collection('Users').doc(uid).collection('Followers').get();
    return snapshot.docs.map((doc) => doc.id).toList();
  }

  // Get a user's following: list of uid
  Future<List<String>> getFollowingUidFromFirebase(String uid) async {
    final snapshot =
        await _db.collection('Users').doc(uid).collection('Following').get();
    return snapshot.docs.map((doc) => doc.id).toList();
  }

  // Search Users
  Future<List<UserProfile>> searchUsersInFirebase(String searchTerm) async {
    try {
      QuerySnapshot snapshot = await _db
          .collection("Users")
          .where('username', isGreaterThanOrEqualTo: searchTerm)
          .where('username', isLessThanOrEqualTo: '$searchTerm\uf8ff')
          .get();
      return snapshot.docs.map((doc) => UserProfile.fromDocument(doc)).toList();
    } catch (e) {
      return [];
    }
  }
}
