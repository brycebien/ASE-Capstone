import 'package:flutter/material.dart';
import 'package:ase_capstone/components/textfield.dart';

class LoginPage extends StatelessWidget {
  LoginPage({super.key});

  // text controllers
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // page background color
      backgroundColor: const Color.fromARGB(255, 245, 184, 165),

      appBar: AppBar(
        title: const Text('Campus Compass'),
        // appbar background color
        backgroundColor: const Color.fromARGB(255, 248, 120, 81),
      ),

      // Safe area to avoid notches and status bar
      body: SafeArea(
        child: Center(
          child: Column(
            children: <Widget>[
              SizedBox(height: 100),

              // Campus Compass Logo
              Icon(
                Icons.account_circle,
                size: 100,
              ),

              // Welcome Text
              const Text(
                'Welcome to the Login Page!',
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

              // sign in button
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  // Navigate to the map page when the button is pressed
                  Navigator.pushNamed(context, '/map');
                },
                child: const Text('Sign In'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
