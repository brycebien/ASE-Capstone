import 'package:ase_capstone/utils/firebase_operations.dart';
import 'package:ase_capstone/utils/utils.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class SettingsDrawer extends StatefulWidget {
  final User? user;
  const SettingsDrawer({super.key, required this.user});

  @override
  SettingsDrawerState createState() => SettingsDrawerState();
}

class SettingsDrawerState extends State<SettingsDrawer> {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          DrawerHeader(
            decoration:
                BoxDecoration(color: Theme.of(context).colorScheme.primary),
            child: Text('Settings',
                style: TextStyle(
                    color: Theme.of(context).colorScheme.tertiary,
                    fontSize: 24)),
          ),
          ListTile(
            leading: Icon(Icons.account_circle),
            title: Text('Profile'),
            onTap: () {
              Navigator.pushNamed(
                context,
                '/profile',
                arguments: widget.user,
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.settings),
            title: Text('General'),
            onTap: () {
              Navigator.pushNamed(
                context,
                '/settings',
                arguments: widget.user,
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.calendar_today),
            title: Text('Class Schedule'),
            onTap: () {
              Navigator.pushNamed(
                context,
                '/schedule',
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.school),
            title: Text('Choose Your University'),
            onTap: () async {
              final String? result = await Utils.showUniversityDialog(
                  context: context, firesotreService: FirestoreService());
              print("RESULT:::::::: $result");
            },
          )
        ],
      ),
    );
  }
}
