import 'package:ase_capstone/components/resource_details_dialog.dart';
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
  late Map<String, dynamic> _university;
  late List<Map<String, dynamic>> _resources;

  @override
  void initState() {
    super.initState();
    _initializePage();
  }

  void _initializePage() async {
    await _initResources();
    await _setBuildingInfo().then((_) {
      setState(() {
        _isLoading = false;
      });
    });
  }

  Future<void> _initResources() async {
    try {
      await _firestoreServices
          .getUniversityByName(name: widget.university)
          .then((value) {
        setState(() {
          _university = value;
        });
      });

      List<dynamic> resources = _university['resources'].where((resource) {
        return resource['building'] == widget.building;
      }).toList();

      setState(() {
        _resources = resources.cast<Map<String, dynamic>>();
      });
    } catch (e) {
      if (mounted) {
        Utils.displayMessage(
          context: context,
          message: 'Error fetching university info: $e',
        );
      }
    }
  }

  Future<void> _setBuildingInfo() async {
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
      // setState(() {
      //   _isLoading = false;
      // });
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
                            children: _resources.isNotEmpty
                                ? _resources.map((resource) {
                                    return Card(
                                      elevation: 8,
                                      child: ListTile(
                                        title: Text(resource['name']),
                                        subtitle: Text(
                                          'Room Number: ${resource['room']}',
                                        ),
                                        onTap: () async {
                                          await showDialog(
                                              context: context,
                                              builder: (BuildContext context) {
                                                return ResourceDetailsDialog(
                                                  resource: resource,
                                                  university: _university,
                                                );
                                              });
                                        },
                                        trailing: IconButton(
                                            onPressed: () async {
                                              await showDialog(
                                                  context: context,
                                                  builder:
                                                      (BuildContext context) {
                                                    return ResourceDetailsDialog(
                                                        resource: resource,
                                                        university: _university,
                                                        onNavigateTapped: () {
                                                          _navigateToBuilding();
                                                        });
                                                  });
                                            },
                                            icon: Icon(
                                              Icons.info_outline,
                                              color: Colors.blue[400],
                                              size: 20,
                                            )),
                                      ),
                                    );
                                  }).toList()
                                : [
                                    Text(
                                      'There are no resources available for this building.',
                                    ),
                                    SizedBox(height: 10),
                                    Text(
                                        'You can add resources by going to the resources page.')
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
