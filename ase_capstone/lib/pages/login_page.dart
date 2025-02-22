import 'package:flutter/material.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'Welcome to the Login Page!',
            ),
            ElevatedButton(
              onPressed: () {
                // Navigate to the map page when the button is pressed
                Navigator.pushNamed(context, '/map');
              },
              child: const Text('Go to Map Page'),
            ),
          ],
        ),
      ),
    );
  }
}
