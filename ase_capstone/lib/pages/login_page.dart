import 'package:ase_capstone/components/my_button.dart';
import 'package:ase_capstone/models/theme_notifier.dart';
import 'package:ase_capstone/utils/utils.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:ase_capstone/components/textfield.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class LoginPage extends StatefulWidget {
  final Function()? onTap;
  const LoginPage({super.key, required this.onTap});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  // text controllers
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();

  bool _isLoading = false;
  String _errorMessage = '';

  Future<bool> signUserIn() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: usernameController.text,
        password: passwordController.text,
      );
    } on FirebaseAuthException catch (e) {
      setState(() {
        _errorMessage = Utils.authErrorHandler(e: e);
        _isLoading = false;
        Utils.displayMessage(context: context, message: _errorMessage);
      });
      return false;
    }

    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
    return true;
  }

  void _downloadApp() async {
    if (kIsWeb) {
      final String apkDownloadUrl =
          'https://drive.google.com/uc?export=download&id=1J09EtEoYwCpF4KBNZTFVbcG-71sqRDUz';
      final Uri uri = Uri.parse(apkDownloadUrl);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      } else {
        if (mounted) {
          Utils.displayMessage(
            context: context,
            message: 'Could not launch the download link.',
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // page background color
      backgroundColor: Theme.of(context).colorScheme.surface,

      appBar: AppBar(
        title: Text('Login'),
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
                  SizedBox(height: 20),

                  // Username Text Field
                  MyTextField(
                    controller: usernameController,
                    hintText: 'Email',
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
                        GestureDetector(
                          onTap: () {
                            Navigator.pushNamed(context, '/forgot-password');
                          },
                          child: Text(
                            'Forgot Password?',
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.primary,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // sign in button
                  SizedBox(height: 20),
                  MyButton(
                    buttonText: 'Sign In',
                    onTap: () async {
                      final success = await signUserIn();
                      if (success) {
                        // send user to map page upon successful login
                        if (mounted) {
                          setState(() {
                            Provider.of<ThemeNotifier>(context, listen: false)
                                .setTheme();
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
                        'Not a member?',
                        style: TextStyle(
                            color: Theme.of(context).colorScheme.secondary,
                            fontSize: 14),
                      ),
                      SizedBox(width: 4),
                      GestureDetector(
                        onTap: widget.onTap,
                        child: Text(
                          'Register now',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.primary,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  if (kIsWeb)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Using an Android device?',
                          style: TextStyle(
                              color: Theme.of(context).colorScheme.secondary,
                              fontSize: 14),
                        ),
                        SizedBox(width: 4),
                        GestureDetector(
                          onTap: () {
                            Utils.displayMessage(
                                context: context,
                                message: 'Downloading the app...');
                            _downloadApp();
                          },
                          child: Text(
                            'Download the app',
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.primary,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
