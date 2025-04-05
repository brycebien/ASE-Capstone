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
  bool _isFavorite = false;
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        //TODO: add actions for the user (e.g. add to favorites, list of resources, etc.)

        // ADD TO FAVORITES BUTTON
        Row(
          children: [
            _isFavorite
                ? IconButton(
                    onPressed: () {
                      setState(() {
                        _isFavorite = false;
                        // TODO: remove from favorites
                      });
                    },
                    icon: Icon(
                      Icons.favorite,
                      color: Colors.redAccent,
                    ),
                  )
                : IconButton(
                    onPressed: () {
                      setState(() {
                        _isFavorite = true;
                        //TODO: add to favorites
                      });
                    },
                    icon: Icon(Icons.favorite_outline),
                  ),
            Text('Add to favorites'),
          ],
        ),

        // NAVIGATE TO BUILDING BUTTON
        Row(
          children: [
            IconButton(
              onPressed: () {},
              icon: Icon(
                Icons.directions_walk,
                color: Colors.blue,
              ),
            ),
            Expanded(
              child: Text(
                'Navigate to ${widget.building}',
                overflow: TextOverflow.visible,
                softWrap: true,
              ),
            ),
          ],
        ),

        // RESOURCES DROPDOWN
        ExpansionTile(
          title: Text('Resources'),
          children: [
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.5,
              child: Scrollbar(
                thumbVisibility: true,
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.only(right: 20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // TODO: add resources for the building
                        Text('Resource 1: Library'),
                        Text('Resource 2: Cafeteria'),
                        Text('Resource 3: Study Rooms'),
                        Text('Resource 4: Gym'),
                        Text('Resource 4: Gym'),
                        Text('Resource 4: Gym'),
                        Text('Resource 4: Gym'),
                        Text('Resource 4: Gym'),
                        Text('Resource 4: Gym'),
                        Text('Resource 4: Gym'),
                        Text('Resource 4: Gym'),
                        Text('Resource 4: Gym'),
                        Text('Resource 4: Gym'),
                        Text('Resource 4: Gym'),
                        Text('Resource 4: Gym'),
                        Text('Resource 4: Gym'),
                        Text('Resource 4: Gym'),
                        Text('Resource 4: Gym'),
                        Text('Resource 4: Gym'),
                        Text('Resource 4: Gym'),
                        Text('Resource 4: Gym'),
                        Text('Resource 4: Gym'),
                        Text('Resource 4: Gym'),
                        Text('Resource 4: Gym'),
                        Text('Resource 4: Gym'),
                        Text('Resource 4: Gym'),
                        Text('Resource 4: Gym'),
                        Text('Resource 4: Gym'),
                        Text('Resource 4: Gym'),
                        Text('Resource 4: Gym'),
                        Text('Resource 4: Gym'),
                        Text('Resource 4: Gym'),
                        Text('Resource 4: Gym'),
                        Text('Resource 4: Gym'),
                        Text('Resource 4: Gym'),
                        Text('Resource 4: Gym'),
                        Text('Resource 4: Gym'),
                        Text('Resource 4: Gym'),
                        Text('Resource 4: Gym'),
                        Text('Resource 4: Gym'),
                        Text('Resource 4: Gym'),
                        Text('Resource 4: Gym'),
                        Text('Resource 4: Gym'),
                        Text('Resource 4: Gym'),
                        Text('Resource 4: Gym'),
                        Text('Resource 4: Gym'),
                        Text('Resource 4: Gym'),
                        Text('Resource 4: Gym'),
                        Text('Resource 4: Gym'),
                        Text('Resource 4: Gym'),
                        Text('Resource 4: Gym'),
                        Text('Resource 4: Gym'),
                        Text('Resource 4: Gym'),
                        Text('Resource 4: Gym'),
                        Text('Resource 4: Gym'),
                        Text('Resource 4: Gym'),
                        Text('Resource 4: Gym'),
                        Text('Resource 4: Gym'),
                        Text('Resource 4: Gym'),
                        Text('Resource 4: Gym'),
                        Text('Resource 4: Gym'),
                        Text('Resource 4: Gym'),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
