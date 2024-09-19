import 'package:flutter/material.dart';

class MyTextField extends StatelessWidget {
  final int maxLength;
  final String hintText;
  final TextEditingController controller;
  final bool obscureText;
  final bool enabled;
  const MyTextField({
    super.key,
    this.enabled = true,
    required this.hintText,
    required this.controller,
    required this.obscureText, required this.maxLength,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      maxLength: maxLength,
      enabled: enabled,
      obscureText: obscureText,
      controller: controller,
      decoration: InputDecoration(
        counterText: '',
        hintText: hintText,
        hintStyle: TextStyle(
          color: Theme.of(context).colorScheme.primary,
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Theme.of(context).colorScheme.tertiary),
          borderRadius: BorderRadius.circular(12),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Theme.of(context).colorScheme.primary),
          borderRadius: BorderRadius.circular(12),
        ),
        fillColor: Theme.of(context).colorScheme.secondary,
        filled: true,
      ),
    );
  }
}
