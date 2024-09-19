import 'package:flutter/material.dart';
import 'package:twitt/components/button_loading_indicator.dart';

class MyButtons extends StatelessWidget {
  const MyButtons({
    super.key,
    this.onTap,
    required this.text,
    this.isLoading = false,
  });

  final String text;
  final bool isLoading;
  final void Function()? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(25),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.secondary,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: (isLoading)
              ? const ButtonLoadingIndicator()
              : Text(
                  text,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.primary,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
        ),
      ),
    );
  }
}
