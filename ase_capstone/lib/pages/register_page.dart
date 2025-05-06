import 'package:ase_capstone/components/my_button.dart';
import 'package:ase_capstone/utils/firebase_operations.dart';
import 'package:ase_capstone/utils/utils.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:ase_capstone/components/textfield.dart';

class RegisterPage extends StatefulWidget {
  final Function()? onTap;
  const RegisterPage({super.key, required this.onTap});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  // firebase operations
  final FirestoreService firestoreService = FirestoreService();

  // text controllers
  final emailController = TextEditingController();
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  bool _isLoading = false;
  String _errorMessage = '';
  late UserCredential user;

  Future<bool> signUserUp() async {
    // create the user
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = '';
      });

      // check to ensure email and password are not empty
      if (emailController.text.isEmpty ||
          usernameController.text.isEmpty ||
          passwordController.text.isEmpty ||
          confirmPasswordController.text.isEmpty) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Please fill out all of the fields to continue';
          Utils.displayMessage(context: context, message: _errorMessage);
        });
        return false;
      }

      // check to ensure password and confirm password match
      if (passwordController.text != confirmPasswordController.text) {
        Utils.displayMessage(
          context: context,
          message: 'Passwords do not match',
        );
        setState(() {
          _isLoading = false;
        });
        return false;
      } else if (await firestoreService.checkUsernameExists(
          username: usernameController.text)) {
        // check to make sure there isnt a user with the same username
        setState(() {
          Utils.displayMessage(
            context: context,
            message: 'Username already exists',
          );
          _isLoading = false;
        });
        return false;
      } else {
        // create the user
        user = await FirebaseAuth.instance
            .createUserWithEmailAndPassword(
          email: emailController.text,
          password: passwordController.text,
        )
            // add user to database
            .then((userCredential) {
          firestoreService.addUserToDatabase(
            uid: userCredential.user!.uid,
            email: emailController.text,
            username: usernameController.text,
          );
          return userCredential;
        });
        return true;
      }
    } on FirebaseAuthException catch (e) {
      setState(() {
        _errorMessage = Utils.authErrorHandler(e: e);
        _isLoading = false;
        Utils.displayMessage(context: context, message: _errorMessage);
      });
      setState(() {
        _isLoading = false;
      });
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // page background color
      backgroundColor: Theme.of(context).colorScheme.surface,

      appBar: AppBar(
        title: Text('Create an Account'),
      ),

      // Safe area to avoid notches and status bar
      body: SafeArea(
        child: Center(
          // allows scrolling if keyboard is open
          child: SingleChildScrollView(
            child: Padding(
              padding: MediaQuery.of(context).size.width > 600
                  ? EdgeInsets.symmetric(
                      horizontal: MediaQuery.of(context).size.width * 0.3)
                  : EdgeInsets.symmetric(horizontal: 8.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  if (_isLoading)
                    Column(
                      children: [
                        const CircularProgressIndicator(),
                      ],
                    ),
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

                  // Email Text Field
                  MyTextField(
                    controller: emailController,
                    hintText: 'Email',
                    obscureText: false,
                  ),

                  SizedBox(height: 10),

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

                  // sign up button
                  SizedBox(height: 20),
                  MyButton(
                    buttonText: 'Sign Up',
                    onTap: () async {
                      final success = await signUserUp();
                      if (success) {
                        if (mounted) {
                          // Navigate to the map page when the button is pressed
                          setState(() {
                            Navigator.pushNamed(context, '/map');
                          });
                        }
                      }
                    },
                  ),

                  SizedBox(height: 20),
                  Divider(
                      thickness: 1,
                      color: const Color.fromARGB(255, 75, 75, 75)),

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
                        onTap: widget.onTap,
                        child: Text(
                          'Log In',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.primary,
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
      ),
    );
  }
}
