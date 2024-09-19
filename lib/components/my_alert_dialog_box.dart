import 'package:flutter/material.dart';

class MyAlertDialogBox extends StatelessWidget {
  final TextEditingController textController;
  const MyAlertDialogBox(
      {super.key,
      required this.textController,
      required this.hintText,
      required this.onPressedText,
      this.onpressed});
  final String hintText;
  final String onPressedText;
  final void Function()? onpressed;
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(8)),
      ),
      backgroundColor: Theme.of(context).colorScheme.surface,
      content: TextField(
        maxLength: 140,
        maxLines: 3,
        decoration: InputDecoration(
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide:
                BorderSide(color: Theme.of(context).colorScheme.tertiary),
          ),
          hintText: hintText,
          hintStyle: TextStyle(color: Theme.of(context).colorScheme.primary),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide:
                BorderSide(color: Theme.of(context).colorScheme.primary),
          ),
          fillColor: Theme.of(context).colorScheme.secondary,
          filled: true,
          counterStyle: TextStyle(color: Theme.of(context).colorScheme.primary),
        ),
        controller: textController,
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
            textController.clear();
          },
          child: Text(
            "Cancel",
            style: TextStyle(color: Theme.of(context).colorScheme.primary),
          ),
        ),
        TextButton(
          onPressed: () {
            onpressed!();
            textController.clear();
            Navigator.pop(context);
          },
          child: Text(
            onPressedText,
            style: TextStyle(color: Theme.of(context).colorScheme.primary),
          ),
        ),
      ],
    );
  }
}
