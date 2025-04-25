import 'package:ase_capstone/components/course_card.dart';
import 'package:ase_capstone/utils/firebase_operations.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class WeekCalendar extends StatefulWidget {
  final List<dynamic> classes;
  final Function onDeleteClass;

  const WeekCalendar({
    super.key,
    required this.classes,
    required this.onDeleteClass,
  });

  @override
  State<WeekCalendar> createState() => _WeekCalendarState();
}

class _WeekCalendarState extends State<WeekCalendar> {
  User? currentUser = FirebaseAuth.instance.currentUser;
  FirestoreService firestoreService = FirestoreService();
  final day = DateTime.now().weekday;
  Map<String, dynamic> schedule = {
    'monday': [],
    'tuesday': [],
    'wednesday': [],
    'thursday': [],
    'friday': [],
  };
  @override
  void initState() {
    super.initState();
    _initializeClasses();
  }

  void _initializeClasses() {
    schedule = {
      'monday': [],
      'tuesday': [],
      'wednesday': [],
      'thursday': [],
      'friday': [],
    };
    for (var course in widget.classes) {
      setState(() {
        String courseDay = course['days'].toString().toLowerCase();

        if (courseDay.contains('monday')) {
          schedule['monday'].add(course);
        }

        if (courseDay.contains('tuesday')) {
          schedule['tuesday'].add(course);
        }

        if (courseDay.contains('wednesday')) {
          schedule['wednesday'].add(course);
        }

        if (courseDay.contains('thursday')) {
          schedule['thursday'].add(course);
        }

        if (courseDay.contains('friday')) {
          schedule['friday'].add(course);
        }
      });
    }
    // TODO: sort classes by start time
  }

  void _deleteClass(index) {
    firestoreService.deleteClassFromDatabase(
      userId: currentUser!.uid,
      userClass: widget.classes[index],
    );

    // remove class from schedule (front end)
    setState(() {
      widget.classes.removeAt(index);
      _initializeClasses();
    });
  }

  List<Widget> _getCourses({required day}) {
    List<dynamic> courses = schedule[day];
    List<Widget> courseWidgets = [];
    for (var course in courses) {
      courseWidgets.add(CourseCard(
        course: course,
        courseList: widget.classes,
        onDeleteClass: _deleteClass,
        omitDays: true,
      ));
    }
    return courseWidgets;
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: SingleChildScrollView(
        child: Padding(
          padding: kIsWeb
              ? EdgeInsets.symmetric(
                  horizontal: MediaQuery.of(context).size.width * .3)
              : const EdgeInsets.all(8.0),
          child: Wrap(
            runSpacing: 8,
            spacing: 8,
            children: [
              // MONDAY
              Container(
                color: day == 1
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(context).colorScheme.secondary,
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 50),
                child: Center(
                  child: Column(
                    children: [
                      Text(
                        'Monday',
                        style: TextStyle(color: Colors.white, fontSize: 24),
                      ),
                      SizedBox(height: 25),
                      ..._getCourses(day: 'monday'),
                    ],
                  ),
                ),
              ),
              // TUESDAY
              Container(
                color: day == 2
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(context).colorScheme.secondary,
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 50),
                child: Center(
                  child: Column(
                    children: [
                      Text(
                        'Tuesday',
                        style: TextStyle(color: Colors.white, fontSize: 24),
                      ),
                      SizedBox(height: 25),
                      ..._getCourses(day: 'tuesday'),
                    ],
                  ),
                ),
              ),
              // WEDNESDAY
              Container(
                color: day == 3
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(context).colorScheme.secondary,
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 50),
                child: Center(
                    child: Column(
                  children: [
                    Text(
                      'Wednesday',
                      style: TextStyle(color: Colors.white, fontSize: 24),
                    ),
                    SizedBox(height: 25),
                    ..._getCourses(day: 'wednesday'),
                  ],
                )),
              ),
              // THURSDAY
              Container(
                color: day == 4
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(context).colorScheme.secondary,
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 50),
                child: Center(
                    child: Column(
                  children: [
                    Text(
                      'Thursday',
                      style: TextStyle(color: Colors.white, fontSize: 24),
                    ),
                    SizedBox(height: 25),
                    ..._getCourses(day: 'thursday'),
                  ],
                )),
              ),
              // FRIDAY
              Container(
                color: day == 5
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(context).colorScheme.secondary,
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 50),
                child: Center(
                    child: Column(
                  children: [
                    Text(
                      'Friday',
                      style: TextStyle(color: Colors.white, fontSize: 24),
                    ),
                    SizedBox(height: 25),
                    ..._getCourses(day: 'friday'),
                  ],
                )),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
