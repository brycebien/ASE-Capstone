import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool isDarkMode = false;

  void toggleDarkMode(bool value) {
    setState(() {
      isDarkMode = value;
    });
  }

  void changePassword() {
    showDialog(
      context: context,
      builder: (context) {
        final TextEditingController passwordController =
            TextEditingController();
        return AlertDialog(
          title: Text('Change Password'),
          content: TextField(
            controller: passwordController,
            decoration: InputDecoration(hintText: 'Enter new password'),
            obscureText: true,
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                String newPassword = passwordController.text;
                if (newPassword.isNotEmpty) {
                  try {
                    User? user = FirebaseAuth.instance.currentUser;
                    await user?.updatePassword(newPassword);
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Password changed successfully')),
                    );
                  } catch (e) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Failed to change password: $e')),
                    );
                  }
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Password cannot be empty')),
                  );
                }
              },
              child: Text('Change'),
            ),
          ],
        );
      },
    );
  }

  void deleteAccount() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Delete Account'),
          content: Text(
              'Are you sure you want to delete your account? This action cannot be undone.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                try {
                  User? user = FirebaseAuth.instance.currentUser;
                  await user?.delete();
                  Navigator.pop(context);
                  Navigator.pushNamedAndRemoveUntil(
                      context, '/', (route) => false);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Account deleted successfully')),
                  );
                } catch (e) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Failed to delete account: $e')),
                  );
                }
              },
              child: Text('Delete'),
            ),
          ],
        );
      },
    );
  }

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
            onTap: changePassword,
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
