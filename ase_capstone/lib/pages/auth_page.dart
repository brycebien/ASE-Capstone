import 'package:ase_capstone/pages/login_or_register_page.dart';
import 'package:ase_capstone/pages/map_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

/// AuthPage:
/// This page checks if the user is logged in or not
/// if no: display login page
/// if are: display map page

class AuthPage extends StatelessWidget {
  const AuthPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<User?>(
        // listens for if the user is signed in or not
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            // if user is signed in, navigate to map page
            return const MapPage();
          } else {
            // if user is not signed in, navigate to login page
            return LoginOrRegisterPage();
          }
        },
      ),
    );
  }
}
