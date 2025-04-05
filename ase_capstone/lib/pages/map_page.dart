import 'package:ase_capstone/components/building_info.dart';
import 'package:ase_capstone/components/searchable_list.dart';
import 'package:ase_capstone/components/settings_drawer.dart';
import 'package:ase_capstone/models/directions.dart';
import 'package:ase_capstone/models/directions_handler.dart';
import 'package:ase_capstone/utils/firebase_operations.dart';
import 'package:ase_capstone/utils/utils.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:location/location.dart';
import 'dart:async';

class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  final FirestoreService _firestoreServices = FirestoreService();
  final user = FirebaseAuth.instance.currentUser!;
  GoogleMapController? _controller;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  late String _mapStyleString;
  String? _mapStyle;
  LocationData? _currentLocation;
  final Set<Marker> _markers = {};
  bool _hasUniversity = false;
  bool isLoadingBuildingMarkers = true;
  String? _userUniversity;
  CameraPosition? _initialCameraPosition;
  CameraTargetBounds? _cameraTargetBounds;
  String? _selectedBuilding;
  bool _showBuildingInfo = false;

  final Set<String> _votedPins = {};
  LatLng? destination;
  Directions? _info;

  @override
  void initState() {
    super.initState();
    _getCurrentLocation(); // get the user's location
    _loadMapStyle(); // load the map's color theme (light or dark mode)
    _listenToPins(); // check for pins in the database
    _checkExpiredPins(); // check that no pins are expired (older than 24 hrs)
    _checkUserUniversity(); // check that he user has a university chosen
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // detect theme changes to update map style (other widgets change dynamically with the theme so no need to update them here)
    if (_controller != null) {
      _updateMapStyle(_controller!);
    }

    // detect changes to user university
    if (_hasUniversity == true) {
      _checkUserUniversity();
    }

    // get args passed to map page via Navigator.pushNamed
    final args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    if (args != null) {
      setState(() {
        destination = args['destination'] as LatLng?;
      });
    }
  }

  void _setInitialCameraPosition() async {
    // get the user's university location
    final String universityName =
        await _firestoreServices.getUserUniversity(userId: user.uid);

    if (universityName == "") {
      return;
    }
    _firestoreServices.getUniversityByName(name: universityName).then((value) {
      setState(() {
        _initialCameraPosition = CameraPosition(
          target: LatLng(
            value['location']['latitude'],
            value['location']['longitude'],
          ),
          zoom: 15.5,
          tilt: 0,
        );

        _cameraTargetBounds = CameraTargetBounds(
          LatLngBounds(
            southwest: LatLng(
              value['southWestBound']['latitude'],
              value['southWestBound']['longitude'],
            ),
            northeast: LatLng(
              value['northEastBound']['latitude'],
              value['northEastBound']['longitude'],
            ),
          ),
        );
      });

      if (_controller != null) {
        Utils.zoomToLocation(
          location: LatLng(
            value['location']['latitude'],
            value['location']['longitude'],
          ),
          controller: _controller!,
        );
      }
    });
  }

  void _checkUserUniversity() async {
    String universityName =
        await _firestoreServices.getUserUniversity(userId: user.uid);

    if (universityName != _userUniversity) {
      setState(() {
        if (universityName == "") {
          _hasUniversity = false;
        } else {
          _hasUniversity = true;
          _userUniversity = universityName;
        }
      });
      _setInitialCameraPosition(); // set the camera position to the new university
      _setBuildingMarkers(
        university: universityName,
      ); // generate building markers for the new university
    } else {
      return; // do nothing if the user hasn't changed their university
    }
  }

  void _setBuildingMarkers({required String university}) async {
    setState(() {
      isLoadingBuildingMarkers = true;
    });

    // delete any existing building markers
    _markers
        .removeWhere((element) => element.markerId.value.contains('building-'));

    // get the university's buildings and add them to the map
    Map<String, dynamic> userUniversity =
        await _firestoreServices.getUniversityByName(name: university);
    BitmapDescriptor customIcon = await _customIcon();
    LatLng? address;
    for (var building in userUniversity['buildings']) {
      if (building['address'] is String) {
        LatLng newAddress = await DirectionsHandler()
            .getDirectionFromAddress(address: building['address']);
        // convert the address to a LatLng object
        setState(() {
          address = newAddress;
        });
      } else {
        setState(() {
          address = LatLng(
            building['address']['latitude'],
            building['address']['longitude'],
          );
        });
      }
      _markers.add(
        Marker(
          markerId: MarkerId('building-${building['name']}'),
          position: address!,
          icon: customIcon,
          onTap: () async {
            //TODO: open building info page
            setState(() {
              _selectedBuilding = building['name'];
              _showBuildingInfo = true;
            });
            // _getDirections(
            //     destination: _markers
            //         .firstWhere((element) =>
            //             element.markerId.value ==
            //             'building-${building['name']}')
            //         .position);
          },
        ),
      );
    }
    setState(() {
      isLoadingBuildingMarkers = false;
    });
  }

  Future<BitmapDescriptor> _customIcon() async {
    return await BitmapDescriptor.asset(
      ImageConfiguration(size: Size(24, 24)),
      'assets/images/building.png',
    );
  }

  void _checkForDirections() async {
    if (destination != null) {
      final directions = await DirectionsHandler().getDirections(
        origin: LatLng(
          _currentLocation!.latitude!,
          _currentLocation!.longitude!,
        ),
        destination: destination!,
      );
      setState(() {
        _info = directions;
        _markers.add(Marker(
          markerId: MarkerId('destinationMarker'),
          position: destination!,
          icon: BitmapDescriptor.defaultMarkerWithHue(
            BitmapDescriptor.hueViolet,
          ),
        ));
      });
    } else {
      // no destination provided
      return;
    }
  }

  void _getCurrentLocation() async {
    Location location = Location();

    // check if location services are enabled and ask user to enable location permissions if not
    var serviceEnabled = await location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await location.requestService();
      if (!serviceEnabled) {
        return;
      }
    }

    // check if location permissions are granted and ask user to grant permissions if not
    var permissionGranted = await location.hasPermission();
    if (permissionGranted == PermissionStatus.denied) {
      permissionGranted = await location.requestPermission();
      if (permissionGranted != PermissionStatus.granted) {
        return;
      }
    }

    // this stops the app from moving the camera to the user's location when the user does not move.
    await location.changeSettings(
      accuracy: LocationAccuracy.high, // high accuracy for better location
      interval: 1000, // update location every second
      distanceFilter: 10,
    );

    try {
      // set current location to the user's location when the app starts
      location.getLocation().then((value) {
        setState(() {
          _currentLocation = value;
        });
      });

      // update the current location when the user moves
      location.onLocationChanged.listen((LocationData newLocation) {
        setState(() {
          _currentLocation = newLocation;
          _checkForDirections();
        });

        // animate the camera to the user's location when the user moves/app is started
        _controller?.animateCamera(CameraUpdate.newCameraPosition(
          CameraPosition(
            zoom: 20.0,
            tilt: 50.0,
            target: LatLng(
              _currentLocation!.latitude!,
              _currentLocation!.longitude!,
            ),
          ),
        ));
      });
    } catch (e) {
      setState(() {
        Utils.displayMessage(
          context: context,
          message: 'Unable to get location: $e',
        );
      });
    }
  }

  // get the map style from the json file as a string
  Future _loadMapStyle() async {
    _mapStyleString = await rootBundle.loadString('assets/map_dark_theme.json');
  }

  // update the map style when the map is created
  void _onMapCreated(GoogleMapController controller) {
    _controller = controller;
    _updateMapStyle(controller);
  }

  // update the map style when the theme changes
  void _updateMapStyle(GoogleMapController controller) {
    setState(() {
      _mapStyle = Theme.of(context).brightness == Brightness.dark
          ? _mapStyleString
          : null;
    });
  }

  void _listenToPins() {
    FirebaseFirestore.instance.collection('pins').snapshots().listen(
      (snapshot) {
        setState(() {
          _markers.removeWhere((element) =>
              element.markerId.value !=
              'destinationMarker'); // Clear existing markers before updating
          for (var doc in snapshot.docs) {
            final data = doc.data();
            if (data.containsKey('latitude') &&
                data.containsKey('longitude') &&
                data.containsKey('color') &&
                data.containsKey('title') &&
                data.containsKey('yesVotes') &&
                data.containsKey('noVotes')) {
              _markers.add(
                Marker(
                  markerId: MarkerId(doc.id),
                  position: LatLng((data['latitude'] as num).toDouble(),
                      (data['longitude'] as num).toDouble()),
                  icon: BitmapDescriptor.defaultMarkerWithHue(
                      (data['color'] as num).toDouble()),
                  infoWindow: InfoWindow(
                    title: data['title'],
                    snippet: 'Yes: ${data['yesVotes']} No: ${data['noVotes']}',
                    onTap: () => _showVoteDialog(
                        doc.id, data['yesVotes'], data['noVotes']),
                  ),
                ),
              );
            }
          }
        });
      },
      onError: (error) {
        setState(() {
          Utils.displayMessage(
            context: context,
            message: 'Error loading pins: $error',
          );
        });
      },
    );
  }

  void _addEventMarker(LatLng position) async {
    if (_currentLocation == null) {
      Utils.displayMessage(
        context: context,
        message: 'Current location is not available.',
      );
      return;
    }

    String markerTitle = "Reported Event";
    double markerColor = BitmapDescriptor.hueOrange;

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        TextEditingController nameController = TextEditingController();
        return AlertDialog(
          title: Text("Customize Event Marker"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: InputDecoration(labelText: "Event Name"),
              ),
              DropdownButton<double>(
                value: markerColor,
                items: [
                  DropdownMenuItem(
                    value: BitmapDescriptor.hueOrange,
                    child: Text("Orange"),
                  ),
                  DropdownMenuItem(
                    value: BitmapDescriptor.hueRed,
                    child: Text("Red"),
                  ),
                  DropdownMenuItem(
                    value: BitmapDescriptor.hueBlue,
                    child: Text("Blue"),
                  ),
                ],
                onChanged: (value) {
                  if (value != null) {
                    markerColor = value;
                  }
                },
              )
            ],
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(context), child: Text("Cancel")),
            TextButton(
              onPressed: () {
                if (nameController.text.isNotEmpty) {
                  markerTitle = nameController.text;
                }
                _firestoreServices.createPin(
                  currentLocation: _currentLocation!,
                  markerTitle: markerTitle,
                  markerColor: markerColor,
                );
                Navigator.pop(context);
              },
              child: Text("Save"),
            ),
          ],
        );
      },
    );
  }

  void _showVoteDialog(String markerId, int yesVotes, int noVotes) {
    if (_votedPins.contains(markerId)) {
      Utils.displayMessage(
        context: context,
        message: 'You have already voted on this event.',
      );
      return;
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Is this event still here?"),
          content: Text("Yes: $yesVotes No: $noVotes"),
          actions: [
            TextButton(
              onPressed: () async {
                await _firestoreServices.updatePins(
                  markerId: markerId,
                  isYesVote: true,
                );
                _votedPins.add(markerId);
                setState(() {
                  Navigator.pop(context);
                });
              },
              child: Text("Yes"),
            ),
            TextButton(
              onPressed: () async {
                await _firestoreServices.updatePins(
                  markerId: markerId,
                  isYesVote: false,
                );
                _votedPins.add(markerId);
                setState(() {
                  Navigator.pop(context);
                });
              },
              child: Text("No"),
            ),
          ],
        );
      },
    );
  }

  void _checkExpiredPins() async {
    final now = DateTime.now();
    final expirationTime = now.subtract(Duration(hours: 24));

    try {
      await _firestoreServices.deleteExpiredPins(
          expirationTime: expirationTime);
    } catch (e) {
      setState(() {
        Utils.displayMessage(
          context: context,
          message: e.toString(),
        );
      });
    }
  }

  void signUserOut() async {
    await FirebaseAuth.instance.signOut();

    // navigate to login page
    setState(() {
      Navigator.of(context).pushReplacementNamed('/');
    });
  }

  void _getDirections({required LatLng destination}) async {
    final directions = await DirectionsHandler().getDirections(
      origin: LatLng(
        _currentLocation!.latitude!,
        _currentLocation!.longitude!,
      ),
      destination: destination,
    );
    _markers.add(
      Marker(
        markerId: MarkerId('destinationMarker'),
        position: destination,
        icon: BitmapDescriptor.defaultMarkerWithHue(
          BitmapDescriptor.hueViolet,
        ),
      ),
    );
    setState(() {
      _info = directions;
    });
  }

  void _showUniversityPicker() async {
    List<Map<String, dynamic>> universities =
        await _firestoreServices.getUniversities();
    String? result;
    if (mounted) {
      result = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => Scaffold(
            appBar: AppBar(
              title: Text('Select a University'),
            ),
            body: SearchableList(
              items: universities,
              keys: ['name', 'abbreviation'],
            ),
          ),
        ),
      );
    } else {
      return;
    }

    if (result != null) {
      await _firestoreServices.updateUserUniversity(
        userId: user.uid,
        university: result,
      );
      setState(() {
        _hasUniversity = true;
        _userUniversity = result;
      });
      _checkUserUniversity(); // check that the user has a university and update the map based on the new university
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        actions: [
          IconButton(onPressed: signUserOut, icon: Icon(Icons.logout)),
        ],
        title: Text('Campus Compass'),
      ),
      drawer: SafeArea(
        child: SettingsDrawer(user: user),
      ),
      body: _currentLocation == null
          ? Center(
              child: CircularProgressIndicator(),
            )
          : !_hasUniversity
              ? AlertDialog(
                  title: Text('No University Selected'),
                  content: Text('Please select a university to use the map.'),
                  actions: [
                    TextButton(
                      onPressed: () async {
                        _showUniversityPicker();
                      },
                      child: Text('Universities'),
                    ),
                  ],
                )
              : Stack(
                  alignment: Alignment.center,
                  children: [
                    (_initialCameraPosition == null ||
                            _cameraTargetBounds == null ||
                            isLoadingBuildingMarkers)
                        ? Center(child: CircularProgressIndicator())
                        : GoogleMap(
                            onMapCreated: _onMapCreated,
                            style: _mapStyle,
                            initialCameraPosition: _initialCameraPosition!,
                            rotateGesturesEnabled: true,
                            myLocationButtonEnabled: true,
                            zoomControlsEnabled:
                                false, // Disable zoom controls (+/- buttons)
                            myLocationEnabled: true,
                            cameraTargetBounds: _cameraTargetBounds!,
                            minMaxZoomPreference:
                                MinMaxZoomPreference(15.0, 20.0),
                            polylines: {
                              if (_info != null)
                                Polyline(
                                  polylineId: PolylineId('route'),
                                  points: _info!.polylineCoordinates
                                      .map((e) =>
                                          LatLng(e.latitude, e.longitude))
                                      .toList(),
                                  color: Colors.yellow,
                                  width: 5,
                                ),
                            },
                            markers: _markers,
                            onLongPress: (LatLng tappedPoint) {
                              _getDirections(destination: tappedPoint);
                            },
                          ),

                    // Resources and Event buttons
                    Positioned(
                      bottom: 16,
                      right: 16,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Resources Button
                          FloatingActionButton(
                            heroTag: 'resourcesBtn',
                            onPressed: () {
                              Navigator.pushNamed(context, '/resources');
                            },
                            tooltip: 'View Campus Resources',
                            child: Icon(Icons.menu_book),
                          ),
                          SizedBox(height: 12), // space between buttons
                          FloatingActionButton(
                            heroTag: 'eventBtn',
                            onPressed: () {
                              if (_currentLocation != null) {
                                _addEventMarker(LatLng(
                                  _currentLocation!.latitude!,
                                  _currentLocation!.longitude!,
                                ));
                              }
                            },
                            tooltip: 'Report Event',
                            child: Icon(Icons.add_location_alt),
                          ),
                        ],
                      ),
                    ),

                    // BuildingInfo Container
                    if (_selectedBuilding != null)
                      AnimatedPositioned(
                        duration: Duration(milliseconds: 100),
                        curve: Curves.easeInOut,
                        top: 0,
                        bottom: 0,
                        right: 0,
                        left: _showBuildingInfo
                            ? MediaQuery.of(context).size.width * 0.25
                            : MediaQuery.of(context).size.width,
                        child: Container(
                          width: MediaQuery.of(context).size.width * 0.75,
                          color: Colors.black54,
                          child: !_showBuildingInfo
                              ? SizedBox(width: 0.0)
                              : Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Expanded(
                                          child: Center(
                                            child: Text(
                                              _selectedBuilding!,
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 20,
                                              ),
                                            ),
                                          ),
                                        ),
                                        IconButton(
                                          icon: Icon(
                                            Icons.close,
                                            color: Colors.red,
                                            size: 20,
                                          ),
                                          onPressed: () {
                                            setState(() {
                                              _showBuildingInfo = false;
                                            });
                                          },
                                        ),
                                      ],
                                    ),
                                    Divider(thickness: 1, color: Colors.white),
                                    SizedBox(height: 10),
                                    Center(
                                      child: BuildingInfo(
                                        university: _userUniversity!,
                                        building: _selectedBuilding!,
                                      ),
                                    ),
                                  ],
                                ),
                        ),
                      ),

                    // Cancel directions button
                    if (_info != null)
                      Positioned(
                        bottom: 16,
                        left: 16,
                        child: FloatingActionButton(
                          onPressed: () {
                            setState(() {
                              _info = null;
                              destination = null;
                              _markers.removeWhere((element) =>
                                  element.markerId.value ==
                                  'destinationMarker');
                            });
                          },
                          backgroundColor:
                              Theme.of(context).colorScheme.primary,
                          child: Icon(Icons.delete),
                        ),
                      ),

                    if (_info != null)
                      // Display distance and time
                      Positioned(
                        top: 20,
                        child: Container(
                          padding: EdgeInsets.symmetric(
                              vertical: 10, horizontal: 20),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.primary,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 1),
                                blurRadius: 6,
                                offset: Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Text(
                            'Distance: ${_info!.totalDistance}\nTime: ${_info!.totalDuration}',
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
    );
  }
}
