import 'package:flutter/material.dart';

class Utils {
  static void displayMessage({required context, required String message}) {
    ScaffoldMessenger.of(context).showSnackBar(
      // displays error message at bottom of screen
      SnackBar(
        content: Text(message),
      ),
    );
  }
}
