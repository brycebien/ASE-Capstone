import 'package:flutter/material.dart';

class BuildingInfo extends StatefulWidget {
  final String university;
  final String building;
  const BuildingInfo({
    super.key,
    required this.university,
    required this.building,
  });

  @override
  State<BuildingInfo> createState() => _BuildingInfoState();
}

class _BuildingInfoState extends State<BuildingInfo> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.building),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              //TODO: add actions for the user (e.g. add to favorites, list of resources, etc.)
            ],
          ),
        ),
      ),
    );
  }
}
