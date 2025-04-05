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
    return Column(
      children: [
        //TODO: add actions for the user (e.g. add to favorites, list of resources, etc.)
        Text('SOMETHING'),
        Text('HERE'),
      ],
    );
  }
}
