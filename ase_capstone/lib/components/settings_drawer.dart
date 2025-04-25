import 'package:ase_capstone/components/searchable_list.dart';
import 'package:ase_capstone/utils/firebase_operations.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class SettingsDrawer extends StatefulWidget {
  final User? user;
  const SettingsDrawer({super.key, required this.user});

  @override
  SettingsDrawerState createState() => SettingsDrawerState();
}

class SettingsDrawerState extends State<SettingsDrawer> {
  final FirestoreService _firestoreService = FirestoreService();

  @override
  void initState() {
    super.initState();
  }

  void _showUniversitySelectionDialog() async {
    List<Map<String, dynamic>> universities =
        await _firestoreService.getUniversities();
    if (mounted) {
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => Scaffold(
            appBar: AppBar(
              title: Text('Select a University'),
            ),
            body: SearchableList(
              items: universities,
              keys: ['name', 'abbreviation'],
            ),
          ),
        ),
      ).then((value) {
        if (value != null) {
          _firestoreService.updateUserUniversity(
            userId: widget.user!.uid,
            university: value,
          );
        }
      });
      return;
    } else {
      return; // Return nothing if the widget is not mounted
    }
  }

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
            onTap: () {
              _showUniversitySelectionDialog();
            },
          ),
          ListTile(
            leading: Icon(Icons.inbox),
            title: Text('Inbox'),
            onTap: () {
              Navigator.pushNamed(
                context,
                '/inbox',
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.add_alert),
            title: Text('Campus Event Reminders'),
            onTap: () {
              Navigator.pushNamed(
                context,
                '/reminders',
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.public),
            title: Text('Campus Events'),
            onTap: () {
              Navigator.pushNamed(
                context,
                '/events',
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.admin_panel_settings),
            title: Text('Map Development Page'),
            onTap: () {
              Navigator.pushNamed(
                context,
                '/development-page',
              );
            },
          ),
        ],
      ),
    );
  }
}
