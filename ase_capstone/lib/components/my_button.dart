import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class MyButton extends StatefulWidget {
  final String buttonText;
  final TextEditingController emailController;
  final TextEditingController passwordController;

  const MyButton({
    super.key,
    required this.buttonText,
    required this.emailController,
    required this.passwordController,
  });

  @override
  State<MyButton> createState() => _MyButtonState();
}

class _MyButtonState extends State<MyButton> {
  void signUserIn({required context}) async {
    // loading indicator
    showDialog(
      context: context,
      builder: (context) {
        return const Center(
          child: CircularProgressIndicator(),
        );
      },
    );

    // sign in user
    await FirebaseAuth.instance.signInWithEmailAndPassword(
      email: widget.emailController.text,
      password: widget.passwordController.text,
    );

    // Navigate to the map page when the button is pressed
    Navigator.pushNamed(context, '/map');
  }

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
        signUserIn(context: context);
      },
      child: Text(
        widget.buttonText,
        style: TextStyle(color: Colors.black),
      ),
    );
  }
}
