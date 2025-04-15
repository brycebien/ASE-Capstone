import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class ResourceDetailsDialog extends StatelessWidget {
  final Map<String, dynamic> resource;
  final Map<String, dynamic> university;
  final Function? onNavigateTapped;

  const ResourceDetailsDialog({
    super.key,
    required this.resource,
    required this.university,
    this.onNavigateTapped,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(resource['name']),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Name: ${resource['name']}',
            style: TextStyle(fontSize: 15),
          ),
          SizedBox(height: 5),
          Text(
            'Building: ${resource['building']}',
            style: TextStyle(fontSize: 15),
          ),
          SizedBox(height: 5),
          Text(
            'Room: ${resource['room']}',
            style: TextStyle(fontSize: 15),
          ),
          SizedBox(height: 5),
        ],
      ),
      actions: [
        IconButton(
          onPressed: () {
            if (onNavigateTapped == null) {
              Navigator.of(context).pop(); // close the dialog
              // get latlng of building
              List<dynamic> buildings = university['buildings'];
              final LatLng directions = LatLng(
                  buildings.firstWhere((building) =>
                          building['name'] == resource['building'])['address']
                      ['latitude'],
                  buildings.firstWhere((building) =>
                          building['name'] == resource['building'])['address']
                      ['longitude']);
              // return to map page with directions
              Navigator.pushNamed(
                context,
                '/map',
                arguments: {
                  // pass building latlng to map page for directions
                  'destination': directions,
                },
              );
            } else {
              Navigator.of(context).pop(); // close the dialog
              onNavigateTapped!(); // call the passed function
            }
          },
          icon: Icon(
            Icons.directions_walk,
            color: Colors.blue,
          ),
        ),
        IconButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          icon: Icon(
            Icons.close,
            color: Colors.red,
          ),
        ),
      ],
    );
  }
}
