import 'package:ase_capstone/components/my_button.dart';
import 'package:ase_capstone/components/textfield.dart';
import 'package:ase_capstone/utils/utils.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ForgotPassword extends StatefulWidget {
  const ForgotPassword({super.key});

  @override
  State<ForgotPassword> createState() => _ForgotPasswordState();
}

class _ForgotPasswordState extends State<ForgotPassword> {
  final TextEditingController _emailController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> passwordReset() async {
    try {
      await FirebaseAuth.instance
          .sendPasswordResetEmail(email: _emailController.text.trim());
      setState(() {
        Utils.displayMessage(
          context: context,
          message:
              'A resent link has been sent to the email ${_emailController.text.trim()}',
        );
      });
    } on FirebaseAuthException catch (e) {
      setState(() {
        Utils.displayMessage(
          context: context,
          message: Utils.authErrorHandler(e: e),
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Forgot Password'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                'Enter your email here and we will send you a password reset link',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18),
              ),
              SizedBox(height: 20),
              MyTextField(
                hintText: 'Email',
                controller: _emailController,
                obscureText: false,
              ),
              SizedBox(height: 10),
              MyButton(
                buttonText: 'Send Reset Email',
                onTap: () {
                  passwordReset();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
