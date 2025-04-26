import 'package:ase_capstone/components/searchable_list.dart';
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
  late List<Map<String, dynamic>> _events;
  List<Map<String, dynamic>>? _buildings;
  bool _loadingEvents = true;

  final TextEditingController _eventNameController = TextEditingController();
  final TextEditingController _eventDateController = TextEditingController();
  final TextEditingController _eventStartTimeController =
      TextEditingController();
  final TextEditingController _eventEndTimeController = TextEditingController();
  final TextEditingController _eventBuildingController =
      TextEditingController();
  Map<String, dynamic> _eventBuilding = {};

  @override
  void initState() {
    super.initState();
    _initEvents();
    _initBuildings();
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
      _loadingEvents = false;
    });
  }

  Future<void> _initBuildings() async {
    final List<dynamic> buildings =
        await _firestoreService.getBuildings(userId: user!.uid);
    setState(() {
      _buildings = buildings.cast<Map<String, dynamic>>();
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
                GestureDetector(
                  onTap: () async {
                    DateTime? pickedDate = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2100),
                    );
                    if (pickedDate != null) {
                      setState(() {
                        _eventDateController.text =
                            "${pickedDate.year}-${pickedDate.month}-${pickedDate.day}";
                      });
                    }
                  },
                  child: AbsorbPointer(
                    child: MyTextField(
                      controller: _eventDateController,
                      hintText: 'Select Event Date',
                      obscureText: false,
                    ),
                  ),
                ),
                const SizedBox(height: 10),

                // EVENT TIME (start)
                GestureDetector(
                  onTap: () async {
                    TimeOfDay? pickedTime = await showTimePicker(
                      context: context,
                      initialTime: TimeOfDay.now(),
                    );
                    if (pickedTime != null) {
                      setState(() {
                        _eventStartTimeController.text +=
                            " ${pickedTime.hour}:${pickedTime.minute}";
                      });
                    }
                  },
                  child: AbsorbPointer(
                    child: MyTextField(
                      controller: _eventStartTimeController,
                      hintText: 'Select Start Time',
                      obscureText: false,
                    ),
                  ),
                ),
                const SizedBox(height: 10),

                // EVENT TIME? (end)
                GestureDetector(
                  onTap: () async {
                    TimeOfDay? pickedTime = await showTimePicker(
                      context: context,
                      initialTime: TimeOfDay.now(),
                    );
                    if (pickedTime != null) {
                      setState(() {
                        _eventEndTimeController.text +=
                            " ${pickedTime.hour}:${pickedTime.minute}";
                      });
                    }
                  },
                  child: AbsorbPointer(
                    child: MyTextField(
                      controller: _eventEndTimeController,
                      hintText: 'Select End Time (optional)',
                      obscureText: false,
                    ),
                  ),
                ),
                const SizedBox(height: 10),

                // EVENT LOCATION (building)
                GestureDetector(
                  onTap: () async {
                    Map<String, dynamic>? pickedBuilding = await showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return Scaffold(
                            appBar: AppBar(
                              title: const Text('Select a Building'),
                            ),
                            body: SearchableList(
                              items: _buildings!,
                              keys: ['name', 'code'],
                              onSelected: (selectedBuilding) {
                                Navigator.of(context).pop(selectedBuilding);
                              },
                            ),
                          );
                        });
                    if (pickedBuilding != null) {
                      setState(() {
                        _eventBuilding = pickedBuilding;
                        _eventBuildingController.text =
                            "${pickedBuilding['name']} (${pickedBuilding['code']})";
                      });
                    }
                  },
                  child: AbsorbPointer(
                    child: MyTextField(
                      controller: _eventBuildingController,
                      hintText: 'Select a Building',
                      obscureText: false,
                    ),
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  setState(() {
                    _eventNameController.clear();
                    _eventDateController.clear();
                    _eventStartTimeController.clear();
                    _eventEndTimeController.clear();
                    _eventBuildingController.clear();
                    _eventBuilding = {};
                  });
                },
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  // TODO: add event to local list and firebase
                  setState(() {
                    _events.add({
                      'name': _eventNameController.text,
                      'date': _eventDateController.text,
                      'startTime': _eventStartTimeController.text,
                      'endTime': _eventEndTimeController.text,
                      'buildingName': _eventBuilding['name'],
                      'building': _eventBuilding,
                    });
                  });
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
        child: _buildings == null || _loadingEvents
            ? CircularProgressIndicator()
            : _events.isEmpty
                ? Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                        Text(
                          'No events found.\n\nTo add an event press the \'+\' button.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 18,
                          ),
                        )
                      ])
                : SearchableList(
                    items: _events,
                    keys: [
                      'name',
                      'date',
                      'startTime',
                      'endTime',
                      'buildingName',
                    ],
                    prependSubtitle: [
                      'Date: ',
                      'Start Time: ',
                      'End Time: ',
                      'Location: ',
                    ],
                    trailing: SizedBox(width: 0.0),
                  ),
      ),
      floatingActionButton: _buildings == null
          ? null
          : FloatingActionButton(
              onPressed: _addEventReminderDialog,
              backgroundColor: Theme.of(context).colorScheme.primary,
              foregroundColor: Theme.of(context).colorScheme.tertiary,
              child: const Icon(Icons.add),
            ),
    );
  }
}
