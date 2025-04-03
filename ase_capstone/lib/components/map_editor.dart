import 'package:ase_capstone/components/search_buildings.dart';
import 'package:ase_capstone/components/textfield.dart';
import 'package:ase_capstone/models/directions_handler.dart';
import 'package:ase_capstone/utils/firebase_operations.dart';
import 'package:ase_capstone/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapEditor extends StatefulWidget {
  final Map<String, dynamic> university;

  const MapEditor({
    super.key,
    required this.university,
  });

  @override
  State<MapEditor> createState() => _MapEditorState();
}

class _MapEditorState extends State<MapEditor> {
  final FirestoreService _firestoreServices = FirestoreService();
  GoogleMapController? _controller;
  bool _isLoading = true;
  final List<Marker> _buildingMarkers = [];
  Map<String, dynamic>? _university;
  LatLng? _universityLocation;
  LatLng? _southWestBound;
  LatLng? _northEastBound;
  String? _currentInstructions;
  final TextEditingController _buildingNameController = TextEditingController();
  final TextEditingController _buildingCodeController = TextEditingController();
  final TextEditingController _buildingAddressController =
      TextEditingController();
  List<dynamic> _buildings = [];
  MinMaxZoomPreference? _zoomPreference;

  @override
  void initState() {
    setState(() {
      _university = widget.university;
    });
    _setUniversityVariables();
    super.initState();
  }

  void _setUniversityVariables() async {
    if (_university != null) {
      // set university location, bounds, and buildings
      setState(() {
        _universityLocation = LatLng(
          _university!['location']['latitude'],
          _university!['location']['longitude'],
        );
        _southWestBound = LatLng(
          _university!['southWestBound']['latitude'],
          _university!['southWestBound']['longitude'],
        );
        _northEastBound = LatLng(
          _university!['northEastBound']['latitude'],
          _university!['northEastBound']['longitude'],
        );
        _buildings = _university!['buildings'];
      });

      // add markers for each building (this is async because it may take a while to load all markers)
      await _addBuildingMarkers();

      // set min max zoom preference
      setState(() {
        _zoomPreference = MinMaxZoomPreference(15.0, 20.0);
      });
      _isLoading = false;
    }
  }

  Future<void> _addBuildingMarkers() async {
    // check if building locations are addresses or latlng
    for (var building in _buildings) {
      if (building['address'] is String) {
        // convert address to latlng
        final LatLng location =
            await DirectionsHandler().getDirectionFromAddress(
          address: building['address'],
        );
        building['address'] = {
          'latitude': location.latitude,
          'longitude': location.longitude,
        };
      }

      // add marker for each building
      _buildingMarkers.add(
        Marker(
          markerId: MarkerId(building['name']),
          position: LatLng(
            building['address']['latitude'],
            building['address']['longitude'],
          ),
          infoWindow: InfoWindow(
            title: building['name'],
            snippet: building['code'],
            onTap: () {
              _editBuilding(building: building);
            },
          ),
        ),
      );
    }
  }

  void _onMapCreated(GoogleMapController controller) {
    _controller = controller;
    Utils.zoomToLocation(
      location: _universityLocation!,
      controller: controller,
    );
  }

  void _showSuccessDialog({
    required String title,
    String? message,
    Function? callBack,
  }) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(title),
            content: Text(message ?? ''),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  if (callBack != null) callBack();
                },
                child: const Text('OK'),
              ),
            ],
          );
        });
  }

  void _setUniversityLocation(LatLng location) {
    // user already has a location selected (setting bounds)
    if (_universityLocation != null) {
      if (_southWestBound == null) {
        // set southwest camera bound
        setState(() {
          _southWestBound = location;
          // add marker for the southwest bound
          _buildingMarkers.add(
            Marker(
              markerId: MarkerId('southwest-bound'),
              position: location,
              infoWindow: InfoWindow(
                title: 'Southwest Bound',
                snippet: 'Southwest Bound',
              ),
            ),
          );
        });
      } else if (_southWestBound != null && _northEastBound == null) {
        // check to make sure north east bound is north and east of south west bound
        if (location.latitude < _southWestBound!.latitude ||
            location.longitude < _southWestBound!.longitude) {
          Utils.displayMessage(
            context: context,
            message:
                'Error setting camera bounds: Please make sure the northeast bound is north and east of the southwest bound.',
          );
          return;
        }
        // set northeast camera bound
        setState(() {
          _northEastBound = location;
          // remove southwest bound marker
          _buildingMarkers.removeWhere(
            (marker) => marker.markerId == MarkerId('southwest-bound'),
          );
        });
      }
    } else {
      setState(() {
        _universityLocation = location;
        Utils.zoomToLocation(
          location: _universityLocation!,
          controller: _controller!,
          zoom: 14,
        );
      });
    }
  }

  void _deleteUniversityLocation() {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Delete Location'),
            content: const Text(
                'Are you sure you want to delete this location?\n\nThis will also remove the camera bounds you set for the university.\n\nNote: any buildings you have created will not be deleted.'),
            actions: [
              TextButton(
                onPressed: () {
                  setState(() {
                    _universityLocation = null;
                    _southWestBound = null;
                    _northEastBound = null;
                  });
                  Navigator.of(context).pop();
                },
                child: const Text('Yes'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('No'),
              ),
            ],
          );
        });
  }

  void _setUniversityBounds() {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Set University Bounds'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Tap the bottom left corner of the university, then the top right corner to set the camera\'s boundary.',
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('OK'),
              ),
            ],
          );
        });
  }

  void _showUniversityLocationHint() {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Set University Location'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Tap the center of the campus to set the university location.\n\nThis will be the center point for your university map.\n\nYou can adjust this later if needed.',
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('OK'),
              ),
            ],
          );
        });
  }

  void _createBuilding(LatLng location) {
    if (_southWestBound == null || _northEastBound == null) {
      _showSuccessDialog(
        title: 'Error',
        message: 'Please set the camera bounds before creating a building.',
      );
      return;
    } else {
      showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Create Building'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  MyTextField(
                    controller: _buildingNameController,
                    hintText: 'Building Name',
                    obscureText: false,
                  ),
                  SizedBox(height: 10),
                  MyTextField(
                    controller: _buildingCodeController,
                    hintText: 'Building Code',
                    obscureText: false,
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    setState(() {
                      _buildingNameController.clear();
                      _buildingCodeController.clear();
                      _buildingAddressController.clear();
                    });
                    Navigator.of(context).pop();
                  },
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () async {
                    setState(() {
                      if (_buildingCodeController.text.isEmpty ||
                          _buildingNameController.text.isEmpty) {
                        Navigator.of(context).pop();
                        Utils.displayMessage(
                          context: context,
                          message:
                              'Error creating building: Please fill out all fields.',
                        );
                      } else {
                        // create building locally
                        _buildings.add({
                          'name': _buildingNameController.text,
                          'code': _buildingCodeController.text,
                          'address': location
                        });
                        Navigator.of(context).pop();

                        // create marker on map for the building
                        _buildingMarkers.add(
                          Marker(
                            markerId: MarkerId(_buildingNameController.text),
                            position: location,
                            infoWindow: InfoWindow(
                              title: _buildingNameController.text,
                              snippet: _buildingCodeController.text,
                              onTap: () async {
                                _deleteBuilding(
                                  buildingLocation: location,
                                );
                              },
                            ),
                          ),
                        );

                        // clear controllers
                        _buildingNameController.clear();
                        _buildingCodeController.clear();
                        _buildingAddressController.clear();
                      }
                    });
                  },
                  child: const Text('Create'),
                ),
              ],
            );
          });
    }
  }

  void _deleteBuilding({required LatLng buildingLocation}) {
    final Map<String, dynamic> building = _buildings.firstWhere(
      (building) =>
          LatLng(building['address']['latitude'],
              building['address']['longitude']) ==
          buildingLocation,
    );

    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Delete Building'),
            content:
                Text('Are you sure you want to delete ${building['name']}?'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('No'),
              ),
              TextButton(
                onPressed: () {
                  setState(() {
                    _buildingMarkers.removeWhere(
                      (marker) => marker.markerId == MarkerId(building['name']),
                    );

                    _buildings.removeWhere(
                      (building) =>
                          LatLng(building['address']['latitude'],
                              building['address']['longitude']) ==
                          buildingLocation,
                    );
                  });
                  Navigator.of(context).pop();
                },
                child: const Text('Yes'),
              ),
            ],
          );
        });
  }

  void _editBuilding({required Map<String, dynamic> building}) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Edit Building'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Building Name: ${building['name']}'),
              SizedBox(height: 5),
              MyTextField(
                controller: _buildingNameController,
                hintText: 'Building Name',
                obscureText: false,
              ),
              SizedBox(height: 10),
              Text('Building Code: ${building['code']}'),
              SizedBox(height: 5),
              MyTextField(
                controller: _buildingCodeController,
                hintText: 'Building Code',
                obscureText: false,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                setState(() {
                  _buildingNameController.clear();
                  _buildingCodeController.clear();
                  _buildingAddressController.clear();
                });
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                if (_buildingCodeController.text.isEmpty ||
                    _buildingNameController.text.isEmpty) {
                  Utils.displayMessage(
                    context: context,
                    message: 'Please fill out all fields.',
                  );
                } else {
                  setState(() {
                    // update marker on map for the building
                    _buildingMarkers.removeWhere(
                      (marker) => marker.markerId == MarkerId(building['name']),
                    );
                    _buildingMarkers.add(
                      Marker(
                        markerId: MarkerId(_buildingNameController.text),
                        position: building['address'],
                        infoWindow: InfoWindow(
                          title: _buildingNameController.text,
                          snippet: _buildingCodeController.text,
                        ),
                      ),
                    );

                    // update building locally
                    building['name'] = _buildingNameController.text;
                    building['code'] = _buildingCodeController.text;

                    // clear controllers
                    _buildingNameController.clear();
                    _buildingCodeController.clear();
                    Navigator.of(context).pop();
                  });
                }
              },
              child: const Text('Confirm'),
            )
          ],
        );
      },
    );
  }

  void _saveUniversity() async {
    final navigator = Navigator.of(context);

    // SAVE UNIVERSITY TO FIRESTORE
    if (_university != null) {
      // convert building addresses to doubles for firestore
      setState(() {
        for (var building in _buildings) {
          if (building['address'] is Map<String, dynamic>) {
            // if the address has already been converted skip it
            continue;
          } else {
            LatLng address = building['address'] as LatLng;
            building['address'] = {
              'latitude': address.latitude.toDouble(),
              'longitude': address.longitude.toDouble(),
            };
          }
        }
      });

      try {
        await _firestoreServices.updateUniversity(
          name: _university!['name'],
          university: {
            'name': _university!['name'],
            'abbreviation': _university!['abbreviation'],
            'location': {
              'latitude': _universityLocation!.latitude.toDouble(),
              'longitude': _universityLocation!.longitude.toDouble()
            },
            'southWestBound': {
              'latitude': _southWestBound!.latitude.toDouble(),
              'longitude': _southWestBound!.longitude.toDouble()
            },
            'northEastBound': {
              'latitude': _northEastBound!.latitude.toDouble(),
              'longitude': _northEastBound!.longitude.toDouble()
            },
            'buildings': _buildings,
          },
        );
      } catch (e) {
        setState(() {
          Utils.displayMessage(
            context: context,
            message: 'Error creating university: ${e.toString()}',
          );
        });
        return;
      }
    }

    // send the user back to the development page
    navigator.popUntil((route) => route.settings.name == '/development-page');
    navigator.pushReplacementNamed('/development-page');

    // show success dialog
    _showSuccessDialog(
      title: '${_university!['name']} Updated Successfully!',
      message: '${_university!['name']} has been updated successfully!',
    );
  }

  void _handleBuildingCallBack({required Map<String, dynamic> result}) {
    if (result.isNotEmpty) {
      Map<String, dynamic> building = result['building'];

      if (result['callback'] == 'zoomToBuilding') {
        Utils.zoomToLocation(
          location: building['address'],
          controller: _controller!,
          zoom: 19,
        );
      } else if (result['callback'] == 'editBuilding') {
        _editBuilding(building: building);
      } else if (result['callback'] == 'deleteBuilding') {
        _deleteBuilding(
          buildingLocation: LatLng(
            building['address']['latitude'],
            building['address']['longitude'],
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Editing: ${_university?['abbreviation'] ?? ''}'),
      ),
      body: _isLoading
          ? const Center(
              child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 20),
                Text('Loading university assets... this may take some time')
              ],
            ))
          : Padding(
              padding: const EdgeInsets.fromLTRB(8, 20, 8, 8),
              child: Stack(
                children: [
                  GoogleMap(
                    onMapCreated: _onMapCreated,
                    initialCameraPosition: CameraPosition(
                      target: LatLng(40, -96),
                    ),
                    minMaxZoomPreference:
                        _zoomPreference ?? MinMaxZoomPreference.unbounded,
                    markers: Set<Marker>.of(_buildingMarkers),
                    zoomControlsEnabled: false,
                    rotateGesturesEnabled: false,
                    onTap: _setUniversityLocation,
                    cameraTargetBounds:
                        _southWestBound != null && _northEastBound != null
                            ? CameraTargetBounds(
                                LatLngBounds(
                                  southwest: _southWestBound!,
                                  northeast: _northEastBound!,
                                ),
                              )
                            : CameraTargetBounds.unbounded,
                    onLongPress: _createBuilding,
                  ),
                  // INSTRUCTIONS FOR USER
                  _currentInstructions == null
                      ? Text('')
                      : Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Align(
                            alignment: Alignment.topCenter,
                            child: Container(
                              padding: EdgeInsets.all(8),
                              color: Colors.black,
                              child: Text(_currentInstructions ?? ""),
                            ),
                          ),
                        ),
                  // SAVE BUTTON
                  _buildings.isNotEmpty
                      ? Positioned(
                          top: 10,
                          right: 10,
                          child: ElevatedButton(
                            onPressed: _saveUniversity,
                            style: ButtonStyle(
                              elevation: WidgetStateProperty.all(8),
                            ),
                            child: Text('Save'),
                          ),
                        )
                      : Text(''),
                  Positioned(
                    bottom: 10,
                    right: 10,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        _buildings.isNotEmpty
                            ? Container(
                                padding: EdgeInsets.only(left: 10),
                                color: Colors.black,
                                child: Row(
                                  children: [
                                    Text('Buildings: (${_buildings.length})'),
                                    IconButton(
                                      onPressed: () async {
                                        Map<String, dynamic> result =
                                            await showDialog(
                                          context: context,
                                          builder: (BuildContext context) {
                                            return SearchBuildings(
                                              buildings: _buildings,
                                            );
                                          },
                                        );
                                        _handleBuildingCallBack(result: result);
                                      },
                                      icon: Icon(
                                        Icons.arrow_forward_ios,
                                        size: 20,
                                        color: Colors.blue[400],
                                      ),
                                    )
                                  ],
                                ),
                              )
                            : Text(''),
                        // CAMERA BOUNDS
                        _southWestBound != null && _northEastBound != null
                            ? Container(
                                padding: EdgeInsets.only(left: 10),
                                color: Colors.black,
                                child: Row(
                                  children: [
                                    Text(
                                      'Camera bounds set',
                                    ),
                                    SizedBox(width: 10),
                                    IconButton(
                                      icon: Icon(
                                        Icons.delete,
                                        color: Colors.red[400],
                                        size: 20,
                                      ),
                                      onPressed: () {
                                        setState(() {
                                          _southWestBound = null;
                                          _northEastBound = null;
                                        });
                                      },
                                    ),
                                  ],
                                ),
                              )
                            : _universityLocation != null
                                ? Container(
                                    padding: EdgeInsets.only(left: 10),
                                    color: Colors.black,
                                    child: Row(
                                      children: [
                                        _southWestBound == null &&
                                                _northEastBound == null
                                            ? Text('Camera bounds not set yet')
                                            : _southWestBound != null
                                                ? Row(
                                                    children: [
                                                      Text(
                                                          'Northeast bound not set yet'),
                                                      SizedBox(width: 10),
                                                      IconButton(
                                                        onPressed: () {
                                                          setState(() {
                                                            _southWestBound =
                                                                null;
                                                            _buildingMarkers
                                                                .removeWhere(
                                                              (marker) =>
                                                                  marker
                                                                      .markerId ==
                                                                  MarkerId(
                                                                      'southwest-bound'),
                                                            );
                                                          });
                                                        },
                                                        icon: Icon(
                                                          Icons.restart_alt,
                                                          color:
                                                              Colors.red[400],
                                                          size: 20,
                                                        ),
                                                      ),
                                                    ],
                                                  )
                                                : Text(
                                                    'Southwest bound not set yet'),
                                        IconButton(
                                          icon: Icon(
                                            Icons.info_outline,
                                            color: Colors.blue[400],
                                            size: 20,
                                          ),
                                          onPressed: () {
                                            _setUniversityBounds();
                                          },
                                        ),
                                      ],
                                    ),
                                  )
                                : SizedBox(height: 0.0),
                        // UNIVERSITY LOCATION
                        _universityLocation != null
                            ? Container(
                                color: Colors.black,
                                child: Row(
                                  children: [
                                    IconButton(
                                        icon: Icon(
                                          Icons.location_on,
                                          color: Colors.blue[400],
                                          size: 20,
                                        ),
                                        onPressed: () {
                                          Utils.zoomToLocation(
                                            location: _universityLocation!,
                                            controller: _controller!,
                                            zoom: 14,
                                          );
                                        }),
                                    Text(
                                      'University Location: ${_universityLocation!.latitude.toStringAsFixed(1)}, ${_universityLocation!.longitude.toStringAsFixed(1)}',
                                    ),
                                    SizedBox(width: 10),
                                    IconButton(
                                      icon: Icon(
                                        Icons.delete,
                                        color: Colors.red[400],
                                        size: 20,
                                      ),
                                      onPressed: _deleteUniversityLocation,
                                    )
                                  ],
                                ),
                              )
                            : Container(
                                padding: EdgeInsets.only(left: 10),
                                color: Colors.black,
                                child: Row(
                                  children: [
                                    Text('University Location not set yet'),
                                    SizedBox(width: 10),
                                    IconButton(
                                      icon: Icon(
                                        Icons.info_outline,
                                        color: Colors.blue[400],
                                        size: 20,
                                      ),
                                      onPressed: () {
                                        _showUniversityLocationHint();
                                      },
                                    ),
                                  ],
                                ),
                              ),
                      ],
                    ),
                  )
                ],
              ),
            ),
    );
  }
}
