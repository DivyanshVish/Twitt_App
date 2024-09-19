import 'package:cloud_firestore/cloud_firestore.dart';

class CommentModel {
  final String id;
  final String postId;
  final String uid;
  final String name;
  final String message;
  final String username;
  final Timestamp timestamp;

  CommentModel({
    required this.uid,
    required this.name,
    required this.message,
    required this.username,
    required this.timestamp,
    required this.id,
    required this.postId,
  });

  factory CommentModel.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return CommentModel(
      uid: data['uid'],
      name: data['name'],
      message: data['message'],
      username: data['username'],
      timestamp: data['timestamp'],
      id: doc.id,
      postId: data['postId'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'name': name,
      'message': message,
      'username': username,
      'timestamp': timestamp,
      'postId': postId,
    };
  }
}
