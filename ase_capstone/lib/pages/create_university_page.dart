import 'package:ase_capstone/components/search_buildings.dart';
import 'package:ase_capstone/components/textfield.dart';
import 'package:ase_capstone/utils/firebase_operations.dart';
import 'package:ase_capstone/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class CreateUniversityPage extends StatefulWidget {
  const CreateUniversityPage({super.key});

  @override
  State<CreateUniversityPage> createState() => _CreateUniversityPageState();
}

class _CreateUniversityPageState extends State<CreateUniversityPage> {
  final FirestoreService _firestoreServices = FirestoreService();
  GoogleMapController? _controller;
  bool _allowSave = false;
  final List<Marker> _buildingMarkers = [];
  LatLng? _universityLocation;
  LatLng? _southWestBound;
  LatLng? _northEastBound;
  String? _currentInstructions;
  final TextEditingController _buildingNameController = TextEditingController();
  final TextEditingController _buildingCodeController = TextEditingController();
  final TextEditingController _universityNameController =
      TextEditingController();
  final TextEditingController _universityAbbreviationController =
      TextEditingController();
  final TextEditingController _buildingAddressController =
      TextEditingController();
  final List<Map<String, dynamic>> _buildings = [];

  void _startTutorial(GoogleMapController controller) {
    _controller = controller;
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Tutorial'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Welcome to the Create University Page. This page will help you create a university map. Follow the instructions at the top of the screen to get started!',
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () async {
                  Navigator.of(context).pop();
                  setState(() {
                    _currentInstructions =
                        'Tap on the map to select a location for the university.';
                  });
                },
                child: const Text('OK'),
              ),
            ],
          );
        });
  }

  void _showSuccessDialog(
      {required String title, String? message, Function? callBack}) {
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
        });
        _showSuccessDialog(
          title: 'You successfully set a southwest camera bound',
          message:
              'Next, tap the top right corner of the university to set the camera\'s boundary.',
          callBack: () {
            setState(() {
              _currentInstructions =
                  'Tap the top right corner of the university';
            });
          },
        );
      } else if (_southWestBound != null && _northEastBound == null) {
        // set northeast camera bound
        setState(() {
          _northEastBound = location;
        });
        _showSuccessDialog(
          title: 'You successfully set a northeast camera bound',
          message: 'You have successfully set the camera\'s boundaries.',
          callBack: _startBuildingTutorial,
        );
      }
    } else {
      // Setting university location
      setState(() {
        _universityLocation = location;
      });
      showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Location Selected Successfully'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                      'You have selected a location for the university.'),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    _zoomToLocation(location: _universityLocation!, zoom: 14);
                    _setUniversityBounds();
                  },
                  child: const Text('OK'),
                ),
              ],
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
            content:
                const Text('Are you sure you want to delete this location?'),
            actions: [
              TextButton(
                onPressed: () {
                  setState(() {
                    _universityLocation = null;
                    _southWestBound = null;
                    _northEastBound = null;
                    _currentInstructions =
                        'Tap on the map to select a location for the university.';
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
                  'Next, tap the bottom left corner of the university, then the top right corner to set the camera\'s boundary.',
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  setState(() {
                    _currentInstructions =
                        'Tap the bottom left corner of the university';
                  });
                },
                child: const Text('OK'),
              ),
            ],
          );
        });
  }

  void _startBuildingTutorial() {
    setState(() {
      _currentInstructions = 'Long press on the map to create a building.';
    });
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Set University Buildings'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Next, long press on the map to create a building.',
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
                        Utils.displayMessage(
                          context: context,
                          message: 'Please fill out all fields.',
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

                      // set instruction after first building is created
                      if (_currentInstructions != null) {
                        _currentInstructions =
                            'To see the list of buildings you created press the arrow next to the buildings count on the bottm right of the screen.\n\nOnce there, you can choose to edit, delete, or zoom to a building.';
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
      (building) => building['address'] == buildingLocation,
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
                      (building) => building['address'] == buildingLocation,
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

  void _saveUniversity() {
    // ask user for university name and abbreviation
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Save University'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                MyTextField(
                  controller: _universityNameController,
                  hintText: 'University Name',
                  obscureText: false,
                ),
                SizedBox(height: 10),
                MyTextField(
                  controller: _universityAbbreviationController,
                  hintText: 'University Abbreviation',
                  obscureText: false,
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  setState(() {
                    _universityAbbreviationController.clear();
                    _universityNameController.clear();
                  });
                  Navigator.of(context).pop();
                },
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () async {
                  if (_universityNameController.text.isEmpty ||
                      _universityAbbreviationController.text.isEmpty) {
                    Utils.displayMessage(
                      context: context,
                      message: 'Please fill out all fields.',
                    );
                  } else {
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

                    final navigator = Navigator.of(context);

                    // SAVE UNIVERSITY TO FIRESTORE
                    await _firestoreServices.createUniversity(
                      university: {
                        'name': _universityNameController.text,
                        'abbreviation': _universityAbbreviationController.text,
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
                    navigator.popUntil(
                        (route) => route.settings.name == '/development-page');
                    navigator.pushReplacementNamed('/development-page');
                  }
                },
                child: const Text('Save'),
              ),
            ],
          );
        });
  }

  void _zoomToLocation({required LatLng location, double zoom = 14}) {
    _controller?.animateCamera(
      CameraUpdate.newLatLngZoom(
        location,
        zoom,
      ),
    );
  }

  void _handleBuildingCallBack({required Map<String, dynamic> result}) {
    if (result.isNotEmpty) {
      Map<String, dynamic> building = result['building'];

      if (result['callback'] == 'zoomToBuilding') {
        _zoomToLocation(
          location: building['address'],
          zoom: 19,
        );
      } else if (result['callback'] == 'editBuilding') {
        _editBuilding(building: building);
      } else if (result['callback'] == 'deleteBuilding') {
        _deleteBuilding(buildingLocation: building['address']);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create University'),
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(8, 20, 8, 8),
        child: Stack(
          children: [
            GoogleMap(
              onMapCreated: _startTutorial,
              initialCameraPosition: CameraPosition(
                target: LatLng(40, -96),
              ),
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
            _allowSave == true
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
            // UNIVERSITY LOCATION
            _universityLocation != null
                ? Positioned(
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

                                        // clear instructions for buildings
                                        if (_currentInstructions != null &&
                                            _currentInstructions!.contains(
                                                'To see the list of buildings you created')) {
                                          setState(() {
                                            _currentInstructions = null;
                                            Utils.displayMessage(
                                                context: context,
                                                message:
                                                    'You have successfully completed the tutorial!');
                                            _allowSave = true;
                                          });
                                        }
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
                                          _currentInstructions =
                                              'Tap the bottom left corner of the university';
                                        });
                                      },
                                    ),
                                  ],
                                ),
                              )
                            : SizedBox(height: 0.0),
                        Container(
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
                                    _zoomToLocation(
                                      location: _universityLocation!,
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
                        ),
                      ],
                    ),
                  )
                : Text(''),
          ],
        ),
      ),
    );
  }
}
