import 'package:flutter/material.dart';

class MyButton extends StatelessWidget {
  final String buttonText;

  const MyButton({
    super.key,
    required this.buttonText,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color.fromARGB(255, 248, 120, 81),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      onPressed: () {
        // !!add sign in functionality here!!
        // Navigate to the map page when the button is pressed
        Navigator.pushNamed(context, '/map');
      },
      child: Text(
        buttonText,
        style: TextStyle(color: Colors.black),
      ),
    );
  }
}
