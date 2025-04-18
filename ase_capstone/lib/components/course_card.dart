import 'package:ase_capstone/models/directions_handler.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class CourseCard extends StatefulWidget {
  final Map<String, dynamic> course;
  final List<dynamic> courseList;
  final Function onDeleteClass;
  final bool omitDays;

  const CourseCard({
    super.key,
    required this.course,
    required this.courseList,
    required this.onDeleteClass,
    this.omitDays = false,
  });

  @override
  State<CourseCard> createState() => _CourseCardState();
}

class _CourseCardState extends State<CourseCard> {
  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 8,
      child: ListTile(
        title: Text(
          widget.course['name'],
          style: TextStyle(fontSize: 20),
        ),
        subtitle: Text(
            '${widget.course['startTime']} - ${widget.course['endTime']}\n${widget.course['building']} - ${widget.course['code']}\nRoom: ${widget.course['room']}${widget.omitDays ? '' : '\nDays: ${widget.course['days'].join(', ')}'}'),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: Icon(Icons.directions_walk),
              style: ButtonStyle(
                foregroundColor: WidgetStateProperty.all(Colors.blue),
              ),
              onPressed: () async {
                LatLng destination;
                // check wether the address is latlng or address
                if (widget.course['address'] is Map &&
                    widget.course['address']['latitude'] != null &&
                    widget.course['address']['longitude'] != null) {
                  destination = LatLng(widget.course['address']['latitude'],
                      widget.course['address']['longitude']);
                } else {
                  // get destination from building address
                  destination = await DirectionsHandler()
                      .getDirectionFromAddress(
                          address: widget.course['address']);
                }

                setState(() {
                  Navigator.pushNamed(
                    context,
                    '/map',
                    arguments: {
                      // pass building latlng to map page for directions
                      'destination': destination,
                    },
                  );
                });
              },
            ),
            IconButton(
              icon: Icon(Icons.delete),
              style: ButtonStyle(
                foregroundColor: WidgetStateProperty.all(Colors.red),
              ),
              onPressed: () {
                widget.onDeleteClass(widget.courseList.indexOf(widget.course));
              },
            ),
          ],
        ),
      ),
    );
  }
}
