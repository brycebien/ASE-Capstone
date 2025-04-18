import 'package:flutter/material.dart';

class WeekCalendar extends StatefulWidget {
  final List<dynamic> classes;
  const WeekCalendar({super.key, required this.classes});

  @override
  State<WeekCalendar> createState() => _WeekCalendarState();
}

class _WeekCalendarState extends State<WeekCalendar> {
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
  }

  List<Widget> _getCourses({required day}) {
    List<dynamic> courses = schedule[day];
    List<Widget> courseWidgets = [];
    for (var course in courses) {
      courseWidgets.add(Card(
        child: ListTile(
          title: Text(
            course['name'],
            style: const TextStyle(color: Colors.white, fontSize: 20),
          ),
        ),
      ));
    }
    return courseWidgets;
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Wrap(
            runSpacing: 8,
            spacing: 8,
            children: [
              // MONDAY
              Container(
                color: day == 1
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(context).colorScheme.secondary,
                padding: const EdgeInsets.all(50),
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
                padding: const EdgeInsets.all(50),
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
                padding: const EdgeInsets.all(50),
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
                padding: const EdgeInsets.all(50),
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
                padding: const EdgeInsets.all(50),
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
