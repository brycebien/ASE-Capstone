import 'package:ase_capstone/components/textfield.dart';
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
  TextEditingController oldPasswordController = TextEditingController();
  TextEditingController newPasswordController = TextEditingController();
  TextEditingController confirmPasswordController = TextEditingController();
  final User? user = FirebaseAuth.instance.currentUser!;
  bool isDarkMode = false;

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

  void _updatePassword({required String message}) async {
    setState(() {
      Utils.displayMessage(context: context, message: message);
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
        _updatePassword(message: 'Password changed successfully');
      } else {
        // send error to user that passwords do not match
        _updatePassword(message: 'Passwords do not match');
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'invalid-credential') {
        // send error to user that password is incorrect
        _updatePassword(message: 'Invalid credentials');
      } else if (e.code == 'weak-password') {
        // send error to user that password is too weak
        _updatePassword(message: 'That password is too weak please try again.');
      } else {
        // send error to user that an unknown error occurred
        _updatePassword(message: 'An unknown error occurred');
      }
    }
  }

  void changePasswordDialog() {
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
        title: Text('Settings'),
        backgroundColor: const Color.fromARGB(255, 248, 120, 81),
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
            leading: Icon(Icons.account_circle),
            title: Text('Change User Icon'),
            onTap: changeUserIcon,
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
