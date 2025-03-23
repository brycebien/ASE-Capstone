import 'package:ase_capstone/components/textfield.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class CreateUniversityPage extends StatefulWidget {
  const CreateUniversityPage({super.key});

  @override
  State<CreateUniversityPage> createState() => _CreateUniversityPageState();
}

class _CreateUniversityPageState extends State<CreateUniversityPage> {
  GoogleMapController? _controller;
  LatLng? _universityLocation;
  LatLng? _southWestBound;
  LatLng? _northEastBound;
  String? _currentInstructions;

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
                  SizedBox(height: 10),
                  Text(
                    'Latitude: ${_universityLocation!.latitude}\nLongitude: ${_universityLocation!.longitude}',
                  ),
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
                  'Next, tap the bottom left corner of the university, then the top right corner to set the camperas boundary.',
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
                    controller: TextEditingController(),
                    hintText: 'Building Name',
                    obscureText: false,
                  ),
                  SizedBox(height: 10),
                  MyTextField(
                    controller: TextEditingController(),
                    hintText: 'Building Abbreviation',
                    obscureText: false,
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () {},
                  child: const Text('Create'),
                ),
              ],
            );
          });
    }
  }

  void _zoomToLocation({required LatLng location, required double zoom}) {
    _controller?.animateCamera(
      CameraUpdate.newLatLngZoom(
        _universityLocation!,
        14,
      ),
    );
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
            _universityLocation != null
                ? Positioned(
                    bottom: 10,
                    right: 10,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
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
