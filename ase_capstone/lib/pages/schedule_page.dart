import 'package:ase_capstone/components/course_card.dart';
import 'package:ase_capstone/components/my_button.dart';
import 'package:ase_capstone/components/searchable_list.dart';
import 'package:ase_capstone/components/textfield.dart';
import 'package:ase_capstone/components/week_calendar.dart';
import 'package:ase_capstone/utils/utils.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:ase_capstone/utils/firebase_operations.dart';

class SchedulePage extends StatefulWidget {
  const SchedulePage({super.key});

  @override
  State<SchedulePage> createState() => _SchedulePageState();
}

class _SchedulePageState extends State<SchedulePage> {
  bool _isLoading = false;
  FirestoreService firestoreService = FirestoreService();
  User? currentUser = FirebaseAuth.instance.currentUser;

  late List<Map<String, dynamic>> buildings;
  TimeOfDay? startTime;
  TimeOfDay? endTime;
  String? building;
  String? buildingCode;
  final TextEditingController _classNameController = TextEditingController();
  final TextEditingController _roomController = TextEditingController();

  List<String> selectedDays = [];
  List<dynamic> classes = [
    // {'name': 'Math', 'time': '8:00 AM', 'building': 'MP', 'room': '101'},
    // {'name': 'Science', 'time': '9:00 AM', 'building': 'SC', 'room': '202'}
  ];

  // select screen
  bool isCalendar = false;

  @override
  void initState() {
    _getClassSchedule();
    _getBuildings();
    super.initState();
  }

  Future<void> _getClassSchedule() async {
    _isLoading = true;
    Map<String, dynamic> userClasses =
        await firestoreService.getClassesFromDatabase(userId: currentUser!.uid);
    setState(() {
      classes = userClasses['classes'] ?? [];
    });
    _isLoading = false;
  }

  final List<String> _days = [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday'
  ];

  Future<void> _getBuildings() async {
    try {
      List<dynamic> result =
          await firestoreService.getBuildings(userId: currentUser!.uid);
      setState(() {
        buildings = result.cast<Map<String, dynamic>>();
      });
    } catch (e) {
      setState(() {
        Utils.displayMessage(
          context: context,
          message:
              'An unexpected error occured.\nPlease try again later, or try changing your university in settings.',
        );
      });
    }
  }

  // function to select start and end time
  Future<TimeOfDay?> _selectTime(BuildContext context) async {
    final TimeOfDay? newTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    return newTime;
  }

  void _createClass() {
    if (_classNameController.text.isNotEmpty &&
        startTime != null &&
        endTime != null &&
        building != null &&
        _roomController.text.isNotEmpty &&
        selectedDays.isNotEmpty) {
      Map<String, dynamic> userClass = {
        'name': _classNameController.text,
        'startTime': startTime!.format(context),
        'endTime': endTime!.format(context),
        'building': building,
        'address': buildings
            .firstWhere((element) => element['name'] == building)['address'],
        'code': buildingCode,
        'room': _roomController.text,
        'days': selectedDays,
      };
      // add class to list (front end)
      setState(() {
        // add class to database
        firestoreService.addClassToDatabase(
            userId: currentUser!.uid, userClass: userClass);

        // add class to list
        _getClassSchedule();

        // clear text fields
        _classNameController.clear();
        _roomController.clear();
        building = null;
        buildingCode = null;
        startTime = null;
        endTime = null;
        selectedDays.clear();
      });
      Navigator.of(context).pop();
    } else {
      Navigator.of(context).pop();
      Utils.displayMessage(
        context: context,
        message: 'Error creating class. Please fill all fields.',
      );
    }
  }

  void _deleteClass(index) {
    firestoreService.deleteClassFromDatabase(
      userId: currentUser!.uid,
      userClass: classes[index],
    );

    // remove class from schedule (front end)
    setState(() {
      classes.removeAt(index);
    });
  }

  Future<String?> _buildingsMenu() async {
    String? selectedBuilding;
    if (mounted) {
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => Scaffold(
            appBar: AppBar(
              title: Text('Select a Building'),
            ),
            body: SearchableList(
              items: buildings,
              keys: ['name', 'code'],
            ),
          ),
        ),
      ).then((value) {
        setState(() {
          selectedBuilding = value;
        });
      });
    } else {
      return null; // Return nothing if the widget is not mounted
    }

    return selectedBuilding;
  }

  void _addClass() {
    // add class to schedule
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text('Add Class'),
              content: SingleChildScrollView(
                child: Column(
                  children: [
                    MyTextField(
                        controller: _classNameController,
                        hintText: 'Class Title',
                        obscureText: false),
                    SizedBox(height: 10),
                    Padding(
                      // start time
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: GestureDetector(
                        onTap: () async {
                          final TimeOfDay? newTime = await _selectTime(context);
                          if (newTime != null) {
                            setState(() {
                              startTime = newTime;
                            });
                          }
                        },
                        child: Row(children: [
                          Text(
                            'Start Time: ',
                            style: TextStyle(fontSize: 16),
                          ),
                          SizedBox(width: 10),
                          startTime == null
                              ? Icon(Icons.access_time, size: 20)
                              : Text(
                                  startTime!.format(context),
                                  style: TextStyle(fontSize: 16),
                                ),
                          SizedBox(width: 10),
                        ]),
                      ),
                    ),
                    SizedBox(height: 10),
                    Padding(
                      // end time
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: GestureDetector(
                        onTap: () async {
                          final TimeOfDay? newTime = await _selectTime(context);
                          if (newTime != null) {
                            setState(() {
                              endTime = newTime;
                            });
                          }
                        },
                        child: Row(children: [
                          Text(
                            'End Time: ',
                            style: TextStyle(fontSize: 16),
                          ),
                          SizedBox(width: 10),
                          endTime == null
                              ? Icon(Icons.access_time, size: 20)
                              : Text(
                                  endTime!.format(context),
                                  style: TextStyle(fontSize: 16),
                                ),
                          SizedBox(width: 10),
                        ]),
                      ),
                    ),
                    SizedBox(height: 10),
                    Padding(
                      // building
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: Row(
                        children: [
                          Text(
                            'Building: ',
                            style: TextStyle(fontSize: 16),
                          ),
                          SizedBox(width: 10),
                          GestureDetector(
                            onTap: () async {
                              final String? selectedBuilding =
                                  await _buildingsMenu();
                              setState(() {
                                building = selectedBuilding;
                                if (building != null) {
                                  buildingCode = buildings.firstWhere(
                                      (element) =>
                                          element['name'] == building)['code'];
                                }
                              });
                            },
                            child: (building == null)
                                ? Icon(Icons.location_on, size: 20)
                                : Text(
                                    buildingCode!,
                                    style: TextStyle(
                                      fontSize: 16,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 10),
                    // Room
                    MyTextField(
                      controller: _roomController,
                      hintText: 'Room',
                      obscureText: false,
                      isNumber: true,
                    ),
                    SizedBox(height: 10),
                    // Days
                    Wrap(
                      spacing: 8.0,
                      children: _days.map(
                        (day) {
                          return ChoiceChip(
                            label: Text(day),
                            selected: selectedDays.contains(day),
                            onSelected: (selected) {
                              setState(() {
                                if (selected) {
                                  selectedDays.add(day);
                                } else {
                                  selectedDays.remove(day);
                                }
                              });
                            },
                          );
                        },
                      ).toList(),
                    ),
                  ],
                ),
              ),
              actions: <Widget>[
                TextButton(
                  onPressed: () {
                    setState(() {
                      _classNameController.clear();
                      startTime = null;
                      endTime = null;
                      building = null;
                      buildingCode = null;
                      selectedDays = [];
                      _roomController.clear();
                    });
                  },
                  child: Text('Clear'),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    setState(() {
                      _classNameController.clear();
                      startTime = null;
                      endTime = null;
                    });
                  },
                  child: Text('Cancel'),
                ),
                TextButton(
                  onPressed: () {
                    _createClass();
                  },
                  child: Text('Add'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Classes'),
      ),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(),
            )
          : Padding(
              padding: EdgeInsets.all(20),
              child: Column(
                // crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      MyButton(
                        buttonText: 'List View',
                        onTap: () {
                          setState(() {
                            isCalendar = false;
                          });
                        },
                        color: !isCalendar
                            ? Theme.of(context).colorScheme.primary
                            : Theme.of(context).colorScheme.secondary,
                      ),
                      MyButton(
                        buttonText: 'Calendar View',
                        onTap: () {
                          setState(() {
                            isCalendar = true;
                          });
                        },
                        color: isCalendar
                            ? Theme.of(context).colorScheme.primary
                            : Theme.of(context).colorScheme.secondary,
                      ),
                    ],
                  ),
                  SizedBox(height: 10),
                  classes.isEmpty
                      ? Center(
                          child: Text(
                            textAlign: TextAlign.center,
                            'No classes scheduled.\nPress the + button to add a class.',
                            style: TextStyle(fontSize: 20),
                          ),
                        )
                      : isCalendar
                          ? WeekCalendar(
                              classes: classes,
                              onDeleteClass: _deleteClass,
                            )
                          : Expanded(
                              child: SingleChildScrollView(
                                child: Padding(
                                  padding: kIsWeb
                                      ? EdgeInsets.symmetric(
                                          horizontal: MediaQuery.of(context)
                                                      .size
                                                      .width >
                                                  800
                                              ? MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                  .3
                                              : 20,
                                        )
                                      : EdgeInsets.all(8),
                                  child: Column(
                                    children: classes.map((e) {
                                      return CourseCard(
                                        course: e,
                                        courseList: classes,
                                        onDeleteClass: _deleteClass,
                                      );
                                    }).toList(),
                                  ),
                                ),
                              ),
                            ),
                ],
              ),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addClass,
        child: Icon(Icons.add),
      ),
    );
  }
}
