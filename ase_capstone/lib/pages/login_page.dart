import 'package:ase_capstone/components/my_button.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:ase_capstone/components/textfield.dart';

class LoginPage extends StatelessWidget {
  LoginPage({super.key});

  // text controllers
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();

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

    // check to ensure email and password are not empty
    if (usernameController.text.isEmpty || passwordController.text.isEmpty) {
      displayErrorMessage(
        context: context,
        message: 'Please enter the username and password for your account',
      );

      // close loading indicator
      Navigator.pop(context);
      return;
    }

    // sign user in
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: usernameController.text,
        password: passwordController.text,
      );
      // close loading indicator
      Navigator.pop(context);
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        // no user found with that email
        displayErrorMessage(
          context: context,
          message: 'User not found with that email address',
        );
      } else if (e.code == 'invalid-credential' || e.code == 'invalid-email') {
        // invalid email
        displayErrorMessage(
          context: context,
          message: 'Invalid username or password',
        );
      } else {
        // other errors
        displayErrorMessage(
          context: context,
          message: 'An unexpected error occurred',
        );
      }
      Navigator.pop(context);
      return;
    }

    // close loading indicator
    Navigator.pop(context);

    // Navigate to the map page when the button is pressed
    Navigator.pushNamed(context, '/map');
  }

  void displayErrorMessage({required context, required String message}) {
    ScaffoldMessenger.of(context).showSnackBar(
      // displays error message at bottom of screen
      SnackBar(
        content: Text(message),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // page background color
      backgroundColor: const Color.fromARGB(255, 245, 184, 165),

      appBar: AppBar(
        title: const Text('Login'),
        // appbar background color
        backgroundColor: const Color.fromARGB(255, 248, 120, 81),
      ),

      // Safe area to avoid notches and status bar
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                // Campus Compass Logo
                Icon(
                  Icons.account_circle,
                  size: 100,
                ),

                SizedBox(height: 30),

                // Welcome Text
                const Text(
                  'Welcome to the Campus Compass!',
                  style: TextStyle(
                    fontSize: 24,
                  ),
                ),
                SizedBox(height: 20),

                // Username Text Field
                MyTextField(
                  controller: usernameController,
                  hintText: 'Username',
                  obscureText: false,
                ),

                SizedBox(height: 10),

                // Password Text Field
                MyTextField(
                  controller: passwordController,
                  hintText: 'Password',
                  obscureText: true,
                ),

                // forgot password
                SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        'Forgot Password?',
                        style: TextStyle(color: Colors.grey[600], fontSize: 14),
                      ),
                    ],
                  ),
                ),

                // sign in button
                SizedBox(height: 20),
                MyButton(
                  buttonText: 'Sign In',
                  onTap: () => signUserIn(context: context),
                ),

                SizedBox(height: 20),
                Divider(thickness: 1, color: Colors.black),

                // Sign Up
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Not a member?',
                      style: TextStyle(color: Colors.grey[600], fontSize: 14),
                    ),
                    SizedBox(width: 4),
                    Text(
                      'Register now',
                      style: TextStyle(
                        color: Color.fromARGB(255, 248, 120, 81),
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
