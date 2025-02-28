import 'package:flutter/material.dart';

class SchedulePage extends StatelessWidget {
  const SchedulePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Campus Compass'),
      ),
      body: Center(
        child: Text('Schedule Page'),
      ),
    );
  }
}
