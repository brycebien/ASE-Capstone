import 'package:ase_capstone/components/my_button.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:ase_capstone/components/textfield.dart';

class RegisterPage extends StatelessWidget {
  final Function()? onTap;
  RegisterPage({super.key, required this.onTap});

  // text controllers
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  void signUserUp({required context}) async {
    // loading indicator
    showDialog(
      context: context,
      builder: (context) {
        return const Center(
          child: CircularProgressIndicator(),
        );
      },
    );

    // create the user
    try {
      // check to ensure email and password are not empty
      if (usernameController.text.isEmpty ||
          passwordController.text.isEmpty ||
          confirmPasswordController.text.isEmpty) {
        displayErrorMessage(
          context: context,
          message: 'Please fill out all of the fields to continue',
        );

        // close loading indicator
        Navigator.pop(context);
        return;
      }

      // check to ensure password and confirm password match
      if (passwordController.text != confirmPasswordController.text) {
        displayErrorMessage(
          context: context,
          message: 'Passwords do not match',
        );

        // close loading indicator
        Navigator.pop(context);
        return;
      } else {
        await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: usernameController.text,
          password: passwordController.text,
        );
      }
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
        title: const Text('Create an Account'),
        // appbar background color
        backgroundColor: const Color.fromARGB(255, 248, 120, 81),
      ),

      // Safe area to avoid notches and status bar
      body: SafeArea(
        child: Center(
          // allows scrolling if keyboard is open
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
                  'Welcome to Campus Compass!',
                  style: TextStyle(
                    fontSize: 24,
                  ),
                ),
                const Text(
                  'Let\'s create an account!',
                  style: TextStyle(
                    fontSize: 20,
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

                SizedBox(height: 10),

                // Password Text Field
                MyTextField(
                  controller: confirmPasswordController,
                  hintText: 'Confirm Password',
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

                // sign up button
                SizedBox(height: 20),
                MyButton(
                  buttonText: 'Sign Up',
                  onTap: () => signUserUp(context: context),
                ),

                SizedBox(height: 20),
                Divider(thickness: 1, color: Colors.black),

                // Sign Up
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Already a member?',
                      style: TextStyle(color: Colors.grey[600], fontSize: 14),
                    ),
                    SizedBox(width: 4),
                    GestureDetector(
                      onTap: onTap,
                      child: Text(
                        'Log In',
                        style: TextStyle(
                          color: Color.fromARGB(255, 248, 120, 81),
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
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
