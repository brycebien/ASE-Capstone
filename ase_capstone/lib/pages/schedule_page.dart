import 'package:ase_capstone/components/textfield.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:ase_capstone/utils/firebase_operations.dart';

class SchedulePage extends StatefulWidget {
  const SchedulePage({super.key});

  @override
  State<SchedulePage> createState() => _SchedulePageState();
}

class _SchedulePageState extends State<SchedulePage> {
  FirestoreService firestoreService = FirestoreService();
  User? currentUser = FirebaseAuth.instance.currentUser;
  @override
  void initState() {
    // TODO: get classes from database (back end)
    super.initState();
  }

  List classes = [
    // {'name': 'Math', 'time': '8:00 AM', 'building': 'MP', 'room': '101'},
    // {'name': 'Science', 'time': '9:00 AM', 'building': 'SC', 'room': '202'}
  ];

  List buildings = [
    {'name': 'Lucas Administrative Center', 'code': 'AC'},
    {'name': 'Business Academic Center', 'code': 'BC'},
    {'name': 'Campbell Hall', 'code': 'CA'},
    {'name': 'Callahan Hall', 'code': 'CH '},
    {'name': 'Ceramics & Sculpture Studio', 'code': 'CS'},
    {'name': 'Commonwealth Hall ', 'code': 'CW'},
    {'name': 'Fine Arts Center ', 'code': 'FA'},
    {'name': 'Founders Hall', 'code': 'FH'},
    {'name': 'Griffin Hall', 'code': 'GH'},
    {'name': 'Albright Health Center', 'code': 'HC'},
    {'name': 'Health Innovation Center', 'code': 'HE'},
    {'name': 'New Residence Hall', 'code': 'HJ'},
    {'name': 'Intramural Field Complex', 'code': 'IM'},
    {'name': 'Kenton Garage', 'code': 'KG'},
    {'name': 'Kentucky Hall', 'code': 'KY'},
    {'name': 'Landrum Academic Center', 'code': 'LA'},
    {'name': 'Maintenance Building', 'code': 'MB'},
    {'name': 'Mathematics Education Psychology Center', 'code': 'MP'},
    {'name': 'Norse Commons', 'code': 'NC'},
    {'name': 'Nunn Hall', 'code': 'NH'},
    {'name': 'Norse Hall', 'code': 'NO'},
    {'name': 'Northern Terrace', 'code': 'NT'},
    {'name': 'Outdoor Space', 'code': 'OD'},
    {'name': 'Opportunity House ', 'code': 'OH'},
    {'name': 'Central Power Plant', 'code': 'PP'},
    {'name': 'Regents Hall', 'code': 'RH'},
    {'name': 'Dorothy W. Herrmann Natural Science Center', 'code': 'SC'},
    {'name': 'Steely Library', 'code': 'SL'},
    {'name': 'Soccer Stadium', 'code': 'SS'},
    {'name': 'Votruba Student Union', 'code': 'SU'},
    {'name': 'Truist Arena', 'code': 'TR'},
    {'name': 'University Center', 'code': 'UC'},
    {'name': 'University Garage', 'code': 'UG'},
    {'name': 'University Police', 'code': 'UP'},
    {'name': 'University Suites', 'code': 'US'},
    {'name': 'Welcome Center', 'code': 'WC'},
    {'name': 'Welcome Center Garage', 'code': 'WG'}
  ];

  TimeOfDay? startTime;
  TimeOfDay? endTime;
  String? building;
  String? buildingCode;
  final TextEditingController _classNameController = TextEditingController();
  final TextEditingController _roomController = TextEditingController();

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
        _roomController.text.isNotEmpty) {
      Map<String, dynamic> userClass = {
        'name': _classNameController.text,
        'startTime': startTime!.format(context),
        'endTime': endTime!.format(context),
        'building': building,
        'code': buildingCode,
        'room': _roomController.text
      };
      // add class to list (front end)
      setState(() {
        classes.add(userClass);
        firestoreService.addClassToDatabase(
            userId: currentUser!.uid, userClass: userClass);

        // clear text fields
        _classNameController.clear();
        _roomController.clear();
        building = null;
        buildingCode = null;
        startTime = null;
        endTime = null;
      });
      Navigator.of(context).pop();
    }
  }

  void _deleteClass(index) {
    // TODO: remove the class from the database (back end)

    // remove class from schedule (front end)
    setState(() {
      classes.removeAt(index);
    });
  }

  Future<String?> _buildingsMenu() async {
    String? selectedBuilding;
    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Select a Building'),
          content: SingleChildScrollView(
            child: Column(
              children: buildings.map((e) {
                return ListTile(
                  title: Text(e['name']),
                  onTap: () {
                    selectedBuilding = e['name'];
                    Navigator.of(context).pop();
                  },
                );
              }).toList(),
            ),
          ),
        );
      },
    );
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
                              final selectedBuilding = await _buildingsMenu();
                              setState(() {
                                building = selectedBuilding;
                                buildingCode = buildings.firstWhere((element) =>
                                    element['name'] == building)['code'];
                              });
                            },
                            child: (buildingCode?.isEmpty ?? true)
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
                    MyTextField(
                      controller: _roomController,
                      hintText: 'Room',
                      obscureText: false,
                      isNumber: true,
                    ),
                  ],
                ),
              ),
              actions: <Widget>[
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
        title: Text('Campus Compass'),
      ),
      body: Padding(
          padding: EdgeInsets.fromLTRB(20, 0, 20, 20),
          child: Stack(
            children: [
              classes.isEmpty
                  ? Center(
                      child: Text(
                        textAlign: TextAlign.center,
                        'No classes scheduled.\nPress the + button to add a class.',
                        style: TextStyle(fontSize: 20),
                      ),
                    )
                  : Column(
                      children: classes.map((e) {
                        return Card(
                          child: ListTile(
                            title: Text(
                              e['name'],
                              style: TextStyle(fontSize: 20),
                            ),
                            subtitle: Text(
                                '${e['startTime']} - ${e['endTime']}\n${e['building']} - ${e['code']}\nRoom: ${e['room']}'),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: Icon(Icons.directions_walk),
                                  style: ButtonStyle(
                                    foregroundColor:
                                        WidgetStateProperty.all(Colors.blue),
                                  ),
                                  onPressed: () {
                                    // TODO: implement Navigation functionality
                                  },
                                ),
                                IconButton(
                                  icon: Icon(Icons.delete),
                                  style: ButtonStyle(
                                    foregroundColor:
                                        WidgetStateProperty.all(Colors.red),
                                  ),
                                  onPressed: () {
                                    _deleteClass(classes.indexOf(e));
                                  },
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ),
              Container(
                alignment: Alignment.bottomRight,
                child: FloatingActionButton(
                  onPressed: _addClass,
                  child: Icon(Icons.add),
                ),
              )
            ],
          )),
    );
  }
}
