import 'package:ase_capstone/components/bottom_dialog.dart';
import 'package:ase_capstone/components/my_button.dart';
import 'package:ase_capstone/components/search_buildings.dart';
import 'package:ase_capstone/components/search_resources.dart';
import 'package:ase_capstone/components/textfield.dart';
import 'package:ase_capstone/models/directions_handler.dart';
import 'package:ase_capstone/utils/firebase_operations.dart';
import 'package:ase_capstone/utils/utils.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapEditor extends StatefulWidget {
  final Map<String, dynamic>? university;

  const MapEditor({
    super.key,
    this.university,
  });

  @override
  State<MapEditor> createState() => _MapEditorState();
}

class _MapEditorState extends State<MapEditor> {
  final FirestoreService _firestoreServices = FirestoreService();
  GoogleMapController? _controller;
  bool _isLoading = true;

  // university variables
  Map<String, dynamic>? _university;
  LatLng? _universityLocation;
  LatLng? _southWestBound;
  LatLng? _northEastBound;
  String? _currentInstructions;

  // new building controllers
  final TextEditingController _buildingNameController = TextEditingController();
  final TextEditingController _buildingCodeController = TextEditingController();
  final TextEditingController _buildingAddressController =
      TextEditingController();

  // new resource controllers
  final TextEditingController _resourceNameController = TextEditingController();
  final TextEditingController _resourceRoomController = TextEditingController();
  final TextEditingController _resourceDescriptionController =
      TextEditingController();
  String? _selectedResourceBuilding;
  List<Map<String, dynamic>> _resources = [];

  // engagement link
  final TextEditingController _engagementLinkController =
      TextEditingController();
  String? _engagementLink;

  List<dynamic> _buildings = [];
  final List<Marker> _buildingMarkers = [];
  MinMaxZoomPreference? _zoomPreference;

  // VARIABLES FOR CREATING A NEW UNIVERSITY
  late bool _isCreate;
  bool _isTutorial = false;
  int _tutorialStep = 0;
  final List<Map<String, dynamic>> _tutorialSteps = [
    {
      'step': 1,
      'message': 'Tap on the map to select a location for the university.',
    },
    {
      'step': 2,
      'message':
          'Tap the bottom left corner of the university to set the camera\'s south west boundary.',
    },
    {
      'step': 3,
      'message':
          'Now, tap the top right corner of the university to set the camera\'s north east boundary.',
    },
    {
      'step': 4,
      'message':
          '${kIsWeb ? 'Click the create new building button' : 'Long press on the map'} to create a building. You can also edit or delete buildings by tapping on them.',
    },
    {
      'step': 5,
      'message':
          'To see the list of buildings you created press the arrow next to the buildings count on the bottm right of the screen.',
    },
    {
      'step': 6,
      'message':
          'You have successfully completed the tutorial! You can now save the university, or continue creating buildings.',
    }
  ];
  // save university controllers
  final TextEditingController _universityNameController =
      TextEditingController();
  final TextEditingController _universityAbbrevController =
      TextEditingController();

  // web only variables
  final GlobalKey buildingLocationMarkerKey = GlobalKey();
  bool _showDialog = false;

  @override
  void initState() {
    super.initState();
    setState(() {
      _university = widget.university;
      if (_university == null) {
        _isCreate = true;
      } else {
        _isCreate = false;
      }
    });
    if (!_isCreate) {
      _setUniversityVariables();
    } else {
      setState(() {
        _isLoading = false;
      });
    }
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
        List<dynamic> resourceData = _university!['resources'] ?? [];
        _resources = (resourceData.cast<Map<String, dynamic>>());
        _engagementLink = _university!['eventUrl'];
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
    if (!_isCreate) {
      Utils.zoomToLocation(
        location: _universityLocation!,
        controller: controller,
      );
    } else {
      if (mounted) {
        showDialog(
            context: context,
            builder: (BuildContext context) {
              return BottomDialog(
                message: 'Would you like to start the tutorial?',
                onResponse: _startTutoral,
              );
            });
      }
    }
  }

  ////////////////////////////////////
  ///       TUTORIAL FUNCTIONS    ///
  ////////////////////////////////////
  void _startTutoral(bool start) async {
    setState(() {
      _isTutorial = start;
    });
    if (start) {
      await _showStartTutorialDialog();
      setState(() {
        _tutorialStep = 1;
        _currentInstructions = _tutorialSteps
            .where((step) => step['step'] == _tutorialStep)
            .first['message'];
      });
    }
  }

  Future<void> _showStartTutorialDialog() async {
    setState(() {
      _showDialog = true;
    });
    await showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Welcome to the Create University Page!'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Welcome to the Create University Page. This page will help you create a university map. Follow the instructions at the top of the screen to get started!',
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
    setState(() {
      _showDialog = false;
    });
  }

  void _startBuildingTutorial() async {
    setState(() {
      _showDialog = true;
    });
    await showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Set University Buildings'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Next, ${kIsWeb ? 'press the create new building button' : 'long press on the map'} to create a building.',
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
    setState(() {
      _showDialog = false;
    });
  }

  //////////////////////////////////
  ///   END TUTORIAL FUNCTIONS   ///
  //////////////////////////////////

  void _showSuccessDialog({
    required String title,
    String? message,
    Function? callBack,
  }) async {
    setState(() {
      _showDialog = true;
    });
    await showDialog(
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
    setState(() {
      _showDialog = false;
    });
  }

  void _setUniversityLocation(LatLng location) async {
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
          if (_isTutorial) {
            _tutorialStep++;
            _currentInstructions = _tutorialSteps
                .where((step) => step['step'] == _tutorialStep)
                .first['message'];
          }
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
          if (_isTutorial) {
            _tutorialStep++;
            _currentInstructions = _tutorialSteps
                .where((step) => step['step'] == _tutorialStep)
                .first['message'];
          }
        });
        if (_isTutorial) {
          _showSuccessDialog(
            title: 'You successfully set the camera bounds for the map!',
            message: 'You have successfully set the camera\'s boundaries.',
            callBack: _startBuildingTutorial,
          );
        }
      }
    } else {
      if (_isTutorial) {
        // Setting university location
        setState(() {
          _showDialog = true;
        });
        await showDialog(
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
                      Utils.zoomToLocation(
                          location: _universityLocation!,
                          controller: _controller!,
                          zoom: 14);
                      _setUniversityBounds();
                    },
                    child: const Text('OK'),
                  ),
                ],
              );
            });
        setState(() {
          _showDialog = false;
        });
      }

      // set and zoom to university location
      setState(() {
        _universityLocation = location;
        Utils.zoomToLocation(
          location: _universityLocation!,
          controller: _controller!,
          zoom: 14,
        );

        if (_isTutorial) {
          _tutorialStep++;
          _currentInstructions = _tutorialSteps
              .where((step) => step['step'] == _tutorialStep)
              .first['message'];
        }
      });
    }
  }

  void _deleteUniversityLocation() async {
    setState(() {
      _showDialog = true;
    });
    await showDialog(
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
    setState(() {
      _showDialog = false;
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
                        Map<String, dynamic> newBuilding = {
                          'name': _buildingNameController.text,
                          'code': _buildingCodeController.text,
                          'address': location
                        };
                        // create building locally
                        _buildings.add(newBuilding);
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
                                _editBuilding(building: newBuilding);
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
                      if (_isTutorial) {
                        setState(() {
                          _tutorialStep++;
                          _currentInstructions = _tutorialSteps
                              .where((step) => step['step'] == _tutorialStep)
                              .first['message'];
                        });
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

  Future<void> _deleteBuilding({required LatLng buildingLocation}) async {
    final Map<String, dynamic> building = _buildings.firstWhere((building) {
      if (building['address'] is Map<String, dynamic>) {
        return building['address']['latitude'] == buildingLocation.latitude &&
            building['address']['longitude'] == buildingLocation.longitude;
      } else {
        return building['address'].latitude == buildingLocation.latitude &&
            building['address'].longitude == buildingLocation.longitude;
      }
    });

    await showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Delete Building'),
            content: Text(
                'Are you sure you want to delete ${building['name']}?\n\n'
                'This will also delete all resources associated with this building.'),
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

                    _buildings.removeWhere((building) {
                      if (building['address'] is Map<String, dynamic>) {
                        return building['address']['latitude'] ==
                                buildingLocation.latitude &&
                            building['address']['longitude'] ==
                                buildingLocation.longitude;
                      } else {
                        return building['address'].latitude ==
                                buildingLocation.latitude &&
                            building['address'].longitude ==
                                buildingLocation.longitude;
                      }
                    });

                    _resources.removeWhere((resource) {
                      return resource['building'] == building['name'];
                    });
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
    setState(() {
      _buildingNameController.text = building['name'];
      _buildingCodeController.text = building['code'];
    });
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Edit Building'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Building Name: ${building['name']}'),
              SizedBox(height: 8),
              MyTextField(
                controller: _buildingNameController,
                hintText: 'New Building Name',
                obscureText: false,
              ),
              SizedBox(height: 10),
              Text('Building Code: ${building['code']}'),
              SizedBox(height: 8),
              MyTextField(
                controller: _buildingCodeController,
                hintText: 'New Building Code',
                obscureText: false,
              ),
            ],
          ),
          actions: [
            IconButton(
              onPressed: () async {
                LatLng? address;
                if (building['address'] is Map) {
                  address = LatLng(
                    building['address']['latitude'],
                    building['address']['longitude'],
                  );
                } else {
                  address = building['address'];
                }

                address != null
                    ? await _deleteBuilding(buildingLocation: address)
                    : Utils.displayMessage(
                        context: context,
                        message:
                            'Error deleting building: Please try again later.',
                      );
                // clear controllers
                setState(() {
                  _buildingNameController.clear();
                  _buildingCodeController.clear();
                  _buildingAddressController.clear();
                });

                if (mounted) {
                  setState(() {
                    Navigator.of(context).pop();
                  });
                }
              },
              icon: Icon(
                Icons.delete,
                color: Colors.red[400],
              ),
              alignment: Alignment.bottomLeft,
            ),
            SizedBox(width: 10),
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
    if (_isCreate) {
      // CREATE UNIVERSITY
      // ask user for university name and abbreviation
      await showDialog(
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
                    controller: _universityAbbrevController,
                    hintText: 'University Abbreviation',
                    obscureText: false,
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    setState(() {
                      _universityAbbrevController.clear();
                      _universityNameController.clear();
                    });
                    Navigator.of(context).pop();
                    return;
                  },
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () async {
                    if (_universityNameController.text.isEmpty ||
                        _universityAbbrevController.text.isEmpty) {
                      Utils.displayMessage(
                        context: context,
                        message: 'Please fill out all fields.',
                      );
                    } else {
                      // SAVE UNIVERSITY TO FIRESTORE
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
                        await _firestoreServices.createUniversity(
                          university: {
                            'name': _universityNameController.text,
                            'abbreviation': _universityAbbrevController.text,
                            'location': {
                              'latitude':
                                  _universityLocation!.latitude.toDouble(),
                              'longitude':
                                  _universityLocation!.longitude.toDouble()
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
                            'resources': _resources,
                            'eventUrl': _engagementLink,
                          },
                        );
                      } catch (e) {
                        navigator.pop();
                        setState(() {
                          Utils.displayMessage(
                            context: context,
                            message:
                                'Error creating university: ${e.toString()}',
                          );
                        });
                        return;
                      }

                      // send the user back to the development page
                      navigator.popUntil((route) =>
                          route.settings.name == '/development-page');
                      navigator.pushReplacementNamed('/development-page');

                      // show create success dialog
                      _showSuccessDialog(
                        title: 'University Created Successfully!',
                        message:
                            'Your university has been created successfully. You can now view it on the development page.',
                      );
                    }
                  },
                  child: const Text('Save'),
                ),
              ],
            );
          });
    } else {
      // EDIT UNIVERSITY
      // show confirm dialog
      showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Save University'),
              content: const Text(
                  'Are you sure you want to save the changes to this university?'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () async {
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
                            'latitude':
                                _universityLocation!.latitude.toDouble(),
                            'longitude':
                                _universityLocation!.longitude.toDouble()
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
                          'resources': _resources,
                          'eventUrl': _engagementLink,
                        },
                      );
                    } catch (e) {
                      setState(() {
                        Utils.displayMessage(
                          context: context,
                          message: 'Error saving university: ${e.toString()}',
                        );
                      });
                      return;
                    }

                    // send the user back to the development page
                    navigator.popUntil(
                        (route) => route.settings.name == '/development-page');
                    navigator.pushReplacementNamed('/development-page');

                    // show edit success dialog
                    _showSuccessDialog(
                      title: '${_university!['name']} Updated Successfully!',
                      message:
                          '${_university!['name']} has been updated successfully!',
                    );
                  },
                  child: const Text('Save'),
                ),
              ],
            );
          });
    }
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
        LatLng? address;
        if (building['address'] is Map<String, dynamic>) {
          address = LatLng(
            building['address']['latitude'],
            building['address']['longitude'],
          );
        } else {
          address = building['address'];
        }

        _deleteBuilding(
          buildingLocation: address!,
        );
      }
    }
  }

  void _engagementLinkDialog() async {
    setState(() {
      _showDialog = true;
    });
    await showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Engagement Link'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                    'Enter the link to the universities engagement site (optional).'),
                _engagementLink != null
                    ? Text('\nCurrent Engagement Link:\n${_engagementLink!}')
                    : SizedBox(),
                SizedBox(height: 10),
                MyTextField(
                  controller: _engagementLinkController,
                  hintText: 'link to the universities engagement site',
                  obscureText: false,
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  _engagementLinkController.clear();
                  Navigator.of(context).pop();
                },
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  if (_engagementLinkController.text.isEmpty) {
                    Utils.displayMessage(
                      context: context,
                      message: 'Please enter a link.',
                    );
                  } else {
                    setState(() {
                      _engagementLink = _engagementLinkController.text;
                    });
                    if (mounted) {
                      Navigator.of(context).pop();
                    }
                  }
                },
                child: const Text('Confirm'),
              ),
            ],
          );
        });
    setState(() {
      _showDialog = false;
    });
  }

  Future<void> _addResourcesDialog() async {
    setState(() {
      _showDialog = true;
    });
    await showDialog(
        context: context,
        builder: (BuildContext context) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('Add Resources'),
            ),
            body: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Center(
                child: Column(
                  children: [
                    // resource name
                    MyTextField(
                      controller: _resourceNameController,
                      hintText: 'Resource Name',
                      obscureText: false,
                    ),
                    SizedBox(height: 20),

                    // resource link (not required)
                    // MyTextField(
                    //   controller: _resourceLinkController,
                    //   hintText: 'Resource Link (not required)',
                    //   obscureText: false,
                    // ),
                    // SizedBox(height: 20),

                    // resource location (building)
                    Autocomplete<Map<String, dynamic>>(
                      optionsBuilder: (TextEditingValue textEditingValue) {
                        if (textEditingValue.text.isEmpty) {
                          return const Iterable<Map<String, dynamic>>.empty();
                        }
                        return _buildings.where((building) {
                          return building['name']
                              .toLowerCase()
                              .contains(textEditingValue.text.toLowerCase());
                        }).cast<Map<String, dynamic>>();
                      },
                      displayStringForOption: (Map<String, dynamic> building) =>
                          building['name'],
                      onSelected: (Map<String, dynamic> selectedBuilding) {
                        setState(() {
                          _selectedResourceBuilding = selectedBuilding['name'];
                        });
                      },
                      fieldViewBuilder: (BuildContext context,
                          TextEditingController textEditingController,
                          FocusNode focusNode,
                          VoidCallback onFieldSubmitted) {
                        return TextFormField(
                          controller: textEditingController,
                          focusNode: focusNode,
                          decoration: InputDecoration(
                            labelText: 'Resource Building',
                            border: OutlineInputBorder(),
                          ),
                        );
                      },
                    ),
                    SizedBox(height: 20),

                    // room number
                    MyTextField(
                      controller: _resourceRoomController,
                      hintText: 'Room number',
                      obscureText: false,
                      isNumber: true,
                    ),
                    SizedBox(height: 20),

                    // description (optional)
                    MyTextField(
                      controller: _resourceDescriptionController,
                      hintText: 'Description (optional)',
                      obscureText: false,
                    ),
                    SizedBox(height: 50),

                    // submit button
                    MyButton(
                      buttonText: 'Save Resource',
                      onTap: () {
                        if (_resourceNameController.text.isEmpty ||
                            _selectedResourceBuilding == null ||
                            _resourceRoomController.text.isEmpty) {
                          Utils.displayMessage(
                            context: context,
                            message: 'Please fill out all fields.',
                          );
                        } else {
                          // add resource to resource map to university
                          Map<String, dynamic> resource = {
                            'name': _resourceNameController.text,
                            'building': _selectedResourceBuilding!,
                            'room': _resourceRoomController.text,
                            'description': _resourceDescriptionController.text,
                          };
                          setState(() {
                            _resources.add(resource);
                          });
                          if (mounted) {
                            Navigator.of(context).pop();
                          }
                        }
                      },
                    ),
                  ],
                ),
              ),
            ),
          );
        });
    setState(() {
      _showDialog = false;
    });
  }

  void _editResource(resource, newResource) {
    setState(() {
      _resources.removeWhere((res) => res['name'] == resource['name']);
      _resources.add(newResource);
    });
  }

  void _deleteResource(resource) async {
    setState(() {
      _resources.removeWhere((res) => res['name'] == resource['name']);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: _isCreate
            ? Text('Create Unversity')
            : Text('Editing: ${_university?['abbreviation'] ?? ''}'),
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
                  Padding(
                    padding: kIsWeb
                        ? const EdgeInsets.only(bottom: 200, top: 50)
                        : EdgeInsets.zero,
                    child: GoogleMap(
                      onMapCreated: _onMapCreated,
                      initialCameraPosition: CameraPosition(
                        target: LatLng(40, -96),
                      ),
                      minMaxZoomPreference:
                          _zoomPreference ?? MinMaxZoomPreference.unbounded,
                      markers: Set<Marker>.of(_buildingMarkers),
                      zoomControlsEnabled: false,
                      rotateGesturesEnabled: false,
                      onTap:
                          !_showDialog ? _setUniversityLocation : (location) {},
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
                      webGestureHandling: _showDialog
                          ? WebGestureHandling.none
                          : WebGestureHandling.auto,
                    ),
                  ),
                  if (kIsWeb && _universityLocation != null)
                    Stack(
                      children: (_universityLocation != null &&
                              _southWestBound != null &&
                              _northEastBound != null)
                          ? [
                              Center(
                                child: Icon(
                                  key: buildingLocationMarkerKey,
                                  Icons.location_pin,
                                  size: 50,
                                  color: Colors.purple[400],
                                ),
                              ),
                              Positioned(
                                top: 0,
                                child: SizedBox(
                                  height: 25,
                                  width: 250,
                                  child: FloatingActionButton(
                                    onPressed: () async {
                                      if (_controller != null) {
                                        RenderBox box =
                                            buildingLocationMarkerKey
                                                    .currentContext!
                                                    .findRenderObject()
                                                as RenderBox;
                                        Offset position =
                                            box.localToGlobal(Offset.zero);
                                        double y = position.dy;
                                        double x = position.dx;
                                        LatLng latLng =
                                            await _controller!.getLatLng(
                                          ScreenCoordinate(
                                            // modifing x and y to center the pin on purple marker
                                            x: x.toInt() + 20,
                                            y: y.toInt() - 90,
                                          ),
                                        );

                                        _createBuilding(latLng);
                                      }
                                    },
                                    child: Text(
                                        'Create new building on purple pin'),
                                  ),
                                ),
                              ),
                            ]
                          : [],
                    ),
                  // INSTRUCTIONS FOR USER
                  _currentInstructions == null
                      ? Text('')
                      : Padding(
                          padding: const EdgeInsets.fromLTRB(8, 30, 8, 8),
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
                  _buildings.isNotEmpty && !_isTutorial
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
                        if (_resources.isNotEmpty)
                          Container(
                            padding: EdgeInsets.only(left: 10),
                            color: Colors.black,
                            child: Row(
                              children: [
                                Text('Resources: (${_resources.length})'),
                                IconButton(
                                  onPressed: () async {
                                    setState(() {
                                      _showDialog = true;
                                    });
                                    await showDialog(
                                        context: context,
                                        builder: (BuildContext context) {
                                          return SearchResources(
                                            data: _resources,
                                            buildings: _buildings,
                                            onEdit: _editResource,
                                            onDelete: _deleteResource,
                                          );
                                        });
                                    setState(() {
                                      _showDialog = false;
                                    });
                                  },
                                  icon: Icon(
                                    Icons.arrow_forward_ios,
                                    size: 20,
                                    color: Colors.blue[400],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        _buildings.isNotEmpty
                            ? Container(
                                padding: EdgeInsets.only(left: 10),
                                color: Colors.black,
                                child: Row(
                                  children: [
                                    IconButton(
                                      onPressed: _addResourcesDialog,
                                      icon: Icon(
                                        Icons.menu_book,
                                        size: 20,
                                        color: Colors.green[500],
                                      ),
                                    ),
                                    Text('Buildings: (${_buildings.length})'),
                                    IconButton(
                                      onPressed: () async {
                                        setState(() {
                                          _showDialog = true;
                                        });
                                        Map<String, dynamic>? result =
                                            await showDialog(
                                          context: context,
                                          builder: (BuildContext context) {
                                            return SearchBuildings(
                                              buildings: _buildings,
                                              isTutorial: _isTutorial,
                                            );
                                          },
                                        );
                                        if (result != null) {
                                          _handleBuildingCallBack(
                                            result: result,
                                          );
                                        }

                                        setState(() {
                                          _showDialog = false;
                                        });

                                        // clear instructions for buildings
                                        if (_isTutorial) {
                                          setState(() {
                                            _tutorialStep++;
                                            _currentInstructions = null;
                                            _showSuccessDialog(
                                              title:
                                                  'Thank you for completing the tutorial!',
                                              message: _tutorialSteps
                                                  .where((step) =>
                                                      step['step'] ==
                                                      _tutorialStep)
                                                  .first['message'],
                                            );
                                            _isTutorial = false;
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
                                      onPressed: _engagementLinkDialog,
                                      icon: Icon(
                                        Icons.public,
                                        size: 20,
                                        color: const Color.fromARGB(
                                            255, 219, 201, 0),
                                      ),
                                    ),
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
