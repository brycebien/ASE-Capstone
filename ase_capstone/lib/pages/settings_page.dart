import 'package:ase_capstone/components/textfield.dart';
import 'package:ase_capstone/utils/firebase_operations.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:ase_capstone/utils/utils.dart';

class SettingsPage extends StatefulWidget {
  final Function toggleTheme;
  final bool isDarkMode;

  const SettingsPage({
    super.key,
    required this.toggleTheme,
    required this.isDarkMode,
  });

  @override
  SettingsPageState createState() => SettingsPageState();
}

class SettingsPageState extends State<SettingsPage> {
  final FirestoreService firestoreService = FirestoreService();
  TextEditingController oldPasswordController = TextEditingController();
  TextEditingController newPasswordController = TextEditingController();
  TextEditingController confirmPasswordController = TextEditingController();
  final User? user = FirebaseAuth.instance.currentUser!;
  bool isDarkMode = false;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    isDarkMode = widget.isDarkMode;
  }

  // function to change dark mode (true/false)
  void toggleDarkMode(bool value) {
    setState(() {
      isDarkMode = value;
      widget.toggleTheme(isDarkMode);
    });
  }

  void _changeUserPassword() async {
    try {
      // reauthenticate user to change password (will throw error if password is incorrect)
      AuthCredential credential = EmailAuthProvider.credential(
        email: user!.email!,
        password: oldPasswordController.text,
      );

      // reauthenticate user
      await user!.reauthenticateWithCredential(credential);

      // check to ensure password and confirm password match
      if ((confirmPasswordController.text == newPasswordController.text) &&
          (confirmPasswordController.text.isNotEmpty &&
              newPasswordController.text.isNotEmpty)) {
        // update password
        await user!.updatePassword(newPasswordController.text);

        // send message to user that password has been changed
        _errorMessage = 'Password changed successfully';
      } else {
        // send error to user that passwords do not match
        _errorMessage = 'Passwords do not match';
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'invalid-credential') {
        // send error to user that password is incorrect
        _errorMessage = 'Invalid credentials';
      } else if (e.code == 'weak-password') {
        // send error to user that password is too weak
        _errorMessage = 'That password is too weak please try again.';
      } else {
        // send error to user that an unknown error occurred
        _errorMessage = 'An unknown error occurred';
      }
    }

    // display error/success message to user
    setState(() {
      Utils.displayMessage(context: context, message: _errorMessage);
    });
  }

  void changePasswordDialog() {
    // clear text fields
    oldPasswordController.clear();
    newPasswordController.clear();
    confirmPasswordController.clear();

    // Show dialog to change password
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Change Password'),
          content: SingleChildScrollView(
            child: Column(
              children: [
                MyTextField(
                  controller: oldPasswordController,
                  hintText: 'Enter your old password',
                  obscureText: true,
                ),
                SizedBox(height: 10),
                MyTextField(
                  controller: newPasswordController,
                  hintText: 'Enter your new password',
                  obscureText: true,
                ),
                SizedBox(height: 10),
                MyTextField(
                  controller: confirmPasswordController,
                  hintText: 'Confirm your new password',
                  obscureText: true,
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Change'),
              onPressed: () {
                _changeUserPassword();
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void deleteAccount() {}

  void changeUserIcon() {}

  void manageNotifications() {}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('General'),
      ),
      body: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          SwitchListTile(
            title: Text('Dark Mode'),
            value: isDarkMode,
            onChanged: toggleDarkMode,
            secondary: Icon(Icons.dark_mode),
          ),
          ListTile(
            leading: Icon(Icons.lock),
            title: Text('Change Password'),
            onTap: changePasswordDialog,
          ),
          ListTile(
            leading: Icon(Icons.delete),
            title: Text('Delete Account'),
            onTap: deleteAccount,
          ),
          ListTile(
            leading: Icon(Icons.notifications),
            title: Text('Notifications'),
            onTap: manageNotifications,
          ),
        ],
      ),
    );
  }
}
