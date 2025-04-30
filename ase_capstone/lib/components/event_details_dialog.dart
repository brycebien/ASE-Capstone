import 'package:flutter/material.dart';

class EventDetailsDialog extends StatelessWidget {
  final Map<String, dynamic> event;
  final Function? onNavigateTapped;
  final Function? onDeleteTapped;

  const EventDetailsDialog({
    super.key,
    required this.event,
    this.onNavigateTapped,
    this.onDeleteTapped,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(event['name']),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Name: ${event['name']}',
            style: TextStyle(fontSize: 15),
          ),
          SizedBox(height: 5),
          Text(
            'Date: ${event['date']}',
            style: TextStyle(fontSize: 15),
          ),
          SizedBox(height: 5),
          Text(
            'Time: ${event['time']}',
            style: TextStyle(fontSize: 15),
          ),
          SizedBox(height: 10),
          event['description'] != null
              ? Text(
                  'Description:\n ${event['description']}',
                  style: TextStyle(fontSize: 15),
                )
              : SizedBox(),
          SizedBox(height: 5),
        ],
      ),
      actions: [
        IconButton(
          onPressed: () {
            if (onDeleteTapped == null) {
              Navigator.of(context).pop(); // close the dialog
            } else {
              onDeleteTapped!();
            }
          },
          icon: Icon(
            Icons.delete,
            color: Colors.red,
          ),
        ),
        IconButton(
          onPressed: () {
            if (onNavigateTapped == null) {
              Navigator.of(context).pop(); // close the dialog
            } else {
              onNavigateTapped!();
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
