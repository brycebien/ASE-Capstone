import 'package:ase_capstone/components/textfield.dart';
import 'package:ase_capstone/utils/firebase_operations.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class EventRemindersPage extends StatefulWidget {
  const EventRemindersPage({super.key});

  @override
  State<EventRemindersPage> createState() => _EventRemindersPageState();
}

class _EventRemindersPageState extends State<EventRemindersPage> {
  final User? user = FirebaseAuth.instance.currentUser;
  final FirestoreService _firestoreService = FirestoreService();
  bool _isLoading = true;
  late List<Map<String, dynamic>> _events;

  final TextEditingController _eventNameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _initEvents();
  }

  Future<void> _initEvents() async {
    final Map<String, dynamic> userData =
        await _firestoreService.getUser(userId: user!.uid);
    final List<Map<String, dynamic>> events = userData['reminders'] ?? [];

    if (events.isNotEmpty) {
      setState(() {
        _events = events;
      });
    } else {
      setState(() {
        _events = [];
      });
    }
    setState(() {
      _isLoading = false;
    });
  }

  void _addEventReminderDialog() async {
    await showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Add Event Reminder'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // TODO: add event date and time pockers, add building picker
                // EVENT NAME
                MyTextField(
                    controller: _eventNameController,
                    hintText: 'Event Name',
                    obscureText: false),
                const SizedBox(height: 10),

                // EVENT DATE

                // EVENT TIME (start)

                // EVENT TIME? (end)

                // EVENT LOCATION (building)
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  // TODO: add event to local list and firebase
                },
                child: const Text('Confirm'),
              ),
            ],
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Event Reminders'),
      ),
      body: Center(
        child: _isLoading
            ? CircularProgressIndicator()
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: _events.isEmpty
                    ? [
                        Text(
                          'No events found.\n\nTo add an event press the \'+\' button.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 18,
                          ),
                        )
                      ]
                    : [
                        // TODO: add list of user's reminders
                      ],
              ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addEventReminderDialog,
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.tertiary,
        child: const Icon(Icons.add),
      ),
    );
  }
}
