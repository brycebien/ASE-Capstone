import 'package:flutter/material.dart';

class WeekCalendar extends StatefulWidget {
  final List<dynamic> classes;
  const WeekCalendar({super.key, required this.classes});

  @override
  State<WeekCalendar> createState() => _WeekCalendarState();
}

class _WeekCalendarState extends State<WeekCalendar> {
  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      padding: const EdgeInsets.all(16),
      height: MediaQuery.of(context).size.height * 0.5,
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          Container(
            width: 100,
            height: 100,
            color: Colors.red,
            child: const Center(
              child: Text(
                'Monday',
                style: TextStyle(color: Colors.white, fontSize: 20),
              ),
            ),
          ),
          Container(
            width: 100,
            height: 100,
            color: Colors.red,
            child: const Center(
              child: Text(
                'Tuesday',
                style: TextStyle(color: Colors.white, fontSize: 20),
              ),
            ),
          ),
          Container(
            width: 100,
            height: 100,
            color: Colors.red,
            child: const Center(
              child: Text(
                'Wednesday',
                style: TextStyle(color: Colors.white, fontSize: 20),
              ),
            ),
          ),
          Container(
            width: 100,
            height: 100,
            color: Colors.red,
            child: const Center(
              child: Text(
                'Thursday',
                style: TextStyle(color: Colors.white, fontSize: 20),
              ),
            ),
          ),
          Container(
            width: 100,
            height: 100,
            color: Colors.red,
            child: const Center(
              child: Text(
                'Friday',
                style: TextStyle(color: Colors.white, fontSize: 20),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
