import 'package:flutter/material.dart';

class CustomLoadingIndicator {
  CustomLoadingIndicator._();

  static void showLoadingCircle(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const AlertDialog(
        backgroundColor: Colors.transparent,
        elevation: 0,
        content: Center(
          child: CircularProgressIndicator(),
        ),
      ),
    );
  }

  static void hideLoadingCircle(BuildContext context) {
    Navigator.of(context).pop();
  }
}
