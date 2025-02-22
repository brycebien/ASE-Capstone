import 'package:flutter/material.dart';

class MyButton extends StatelessWidget {
  const MyButton({super.key});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        // Navigate to the map page when the button is pressed
        Navigator.pushNamed(context, '/map');
      },
      child: const Text('Sign In'),
    );
  }
}
