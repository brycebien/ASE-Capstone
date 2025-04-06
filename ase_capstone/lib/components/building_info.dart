import 'package:ase_capstone/utils/firebase_operations.dart';
import 'package:ase_capstone/utils/utils.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class BuildingInfo extends StatefulWidget {
  final String university;
  final String building;
  final Function(LatLng) onNavigateToBuilding;

  const BuildingInfo({
    super.key,
    required this.university,
    required this.building,
    required this.onNavigateToBuilding,
  });

  @override
  State<BuildingInfo> createState() => _BuildingInfoState();
}

class _BuildingInfoState extends State<BuildingInfo> {
  final FirestoreService _firestoreServices = FirestoreService();
  final user = FirebaseAuth.instance.currentUser!;
  bool _isFavorite = false;
  late Map<String, dynamic> _buildingInfo;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _setBuildingInfo();
  }

  void _setBuildingInfo() async {
    try {
      await _firestoreServices.getBuildings(userId: user.uid).then(
        (value) {
          setState(() {
            _buildingInfo = value.where((building) {
              return building['name'] == widget.building;
            }).first;
          });
        },
      );

      await _firestoreServices
          .getFavorite(
        userId: user.uid,
        building: widget.building,
      )
          .then(
        (value) {
          setState(() {
            _isFavorite = value;
          });
        },
      );
    } catch (e) {
      if (mounted) {
        Utils.displayMessage(
          context: context,
          message: 'Error fetching building info: $e',
        );
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _navigateToBuilding() {
    if (_buildingInfo['address'] is String) {
      Utils.convertAddressToLatLng(address: _buildingInfo['address']).then(
        (value) {
          widget.onNavigateToBuilding(value);
        },
      );
    } else {
      widget.onNavigateToBuilding(
        LatLng(
          _buildingInfo['address']['latitude'],
          _buildingInfo['address']['longitude'],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return _isLoading
        ? const Center(
            child: CircularProgressIndicator(),
          )
        : Column(
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
                            });
                            _firestoreServices.removeFavorite(
                              userId: user.uid,
                              building: widget.building,
                            );
                          },
                          icon: Icon(
                            Icons.favorite,
                            color: Colors.redAccent,
                          ),
                        )
                      : IconButton(
                          onPressed: () async {
                            setState(() {
                              _isFavorite = true;
                            });
                            await _firestoreServices.addToFavorites(
                              userId: user.uid,
                              building: widget.building,
                            );
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
                    onPressed: () {
                      _navigateToBuilding();
                    },
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
