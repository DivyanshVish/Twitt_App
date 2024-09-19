import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:twitt/services/database/database_service.dart';

class AuthServices {
  final _auth = FirebaseAuth.instance;

  User? getCurrentUser() => _auth.currentUser;

  String getCurrentUserUid() => _auth.currentUser!.uid;

  Future<UserCredential> loginEmailPassword(String email, password) async {
    try {
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential;
    } on FirebaseAuthException catch (e) {
      throw Exception(e.code);
    }
  }

  Future<UserCredential> registerEmailPassword(String email, password) async {
    try {
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential;
    } on FirebaseAuthException catch (e) {
      throw Exception(e.code);
    }
  }

  Future<void> logout(BuildContext context) async {
    await _auth.signOut();
  }

  Future<void> deleteAccount() async {
    User? user = getCurrentUser();
    if (user != null) {
      // delete user's date from firestore
      await DatabaseService().deleteUserInfoFromFirebase(user.uid);

      // delete user's auth record
      await user.delete();
    }
  }
}
