import 'package:ase_capstone/components/settings_drawer.dart';
import 'package:ase_capstone/models/directions.dart';
import 'package:ase_capstone/models/directions_handler.dart';
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
  final user = FirebaseAuth.instance.currentUser!;
  GoogleMapController? _controller;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  late String _mapStyleString;
  String? _mapStyle;
  LocationData? _currentLocation;
  final Set<Marker> _markers = {};

  final Set<String> _votedPins = {};
  LatLng? destination;
  Directions? _info;

  @override
  void initState() {
    super.initState();
    _getCurrentLocation(); // get the user's location
    _loadMapStyle(); // load the map's color theme (light or dark mode)
    _listenToPins();
    _checkExpiredPins();
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
        _currentLocation = value;
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

  // detect theme changes to update map style (other widgets change dynamically with the theme so no need to update them here)
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_controller != null) {
      _updateMapStyle(_controller!);
    }

    final args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    if (args != null) {
      setState(() {
        destination = args['destination'] as LatLng?;
      });
      _checkForDirections();
    }
  }

  void _listenToPins() {
    FirebaseFirestore.instance.collection('pins').snapshots().listen(
      (snapshot) {
        setState(() {
          _markers.clear(); // Clear existing markers before updating
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
        Utils.displayMessage(
          context: context,
          message: 'Error loading pins: $error',
        );
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
                FirebaseFirestore.instance.collection('pins').add({
                  'latitude': _currentLocation!.latitude,
                  'longitude': _currentLocation!.longitude,
                  'title': markerTitle,
                  'color': markerColor
                      .toDouble(), // Ensure color is stored as double
                  'timestamp': FieldValue.serverTimestamp(),
                  'yesVotes': 0,
                  'noVotes': 0,
                });
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
              onPressed: () {
                _updateVotes(markerId, true);
                _votedPins.add(markerId);
                Navigator.pop(context);
              },
              child: Text("Yes"),
            ),
            TextButton(
              onPressed: () {
                _updateVotes(markerId, false);
                _votedPins.add(markerId);
                Navigator.pop(context);
              },
              child: Text("No"),
            ),
          ],
        );
      },
    );
  }

  void _updateVotes(String markerId, bool isYesVote) async {
    DocumentReference docRef =
        FirebaseFirestore.instance.collection('pins').doc(markerId);
    FirebaseFirestore.instance.runTransaction((transaction) async {
      DocumentSnapshot snapshot = await transaction.get(docRef);
      if (!snapshot.exists) {
        throw Exception("Marker does not exist!");
      }

      int newYesVotes = snapshot['yesVotes'];
      int newNoVotes = snapshot['noVotes'];

      if (isYesVote) {
        newYesVotes += 1;
      } else {
        newNoVotes += 1;
      }

      if (newNoVotes > 5) {
        transaction.delete(docRef);
      } else {
        transaction.update(docRef, {
          'yesVotes': newYesVotes,
          'noVotes': newNoVotes,
          'lastActivity': FieldValue.serverTimestamp()
        });
      }
    });
  }

  void _checkExpiredPins() async {
    final now = DateTime.now();
    final expirationTime = now.subtract(Duration(hours: 24));

    FirebaseFirestore.instance
        .collection('pins')
        .where('lastActivity', isLessThan: expirationTime)
        .get()
        .then((snapshot) {
      for (var doc in snapshot.docs) {
        doc.reference.delete();
      }
    }).catchError((error) {});
  }

  void signUserOut() async {
    await FirebaseAuth.instance.signOut();

    // navigate to login page
    setState(() {
      Navigator.of(context).pushReplacementNamed('/');
    });
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
          : Stack(
              children: [
                GoogleMap(
                  onMapCreated: _onMapCreated,
                  style: _mapStyle,
                  initialCameraPosition: CameraPosition(
                    target: LatLng(
                      _currentLocation!.latitude!,
                      _currentLocation!.longitude!,
                    ),
                    zoom: 15.5,
                    tilt: 0,
                  ),
                  rotateGesturesEnabled: true,
                  myLocationButtonEnabled: true,
                  zoomControlsEnabled:
                      false, // Disable zoom controls (+/- buttons)
                  myLocationEnabled: true,
                  cameraTargetBounds: CameraTargetBounds(
                    LatLngBounds(
                      southwest: LatLng(39.028, -84.467),
                      northeast: LatLng(39.038, -84.459),
                    ),
                  ),
                  minMaxZoomPreference: MinMaxZoomPreference(15.0, 20.0),
                  polylines: {
                    if (_info != null)
                      Polyline(
                        polylineId: PolylineId('route'),
                        points: _info!.polylineCoordinates
                            .map((e) => LatLng(e.latitude, e.longitude))
                            .toList(),
                        color: Colors.yellow,
                        width: 5,
                      ),
                  },
                  markers: _markers,
                ),
                Positioned(
                  bottom: 16,
                  right: 16,
                  child: FloatingActionButton(
                    onPressed: () {
                      if (_currentLocation != null) {
                        _addEventMarker(LatLng(
                          _currentLocation!.latitude!,
                          _currentLocation!.longitude!,
                        ));
                      }
                    },
                    backgroundColor: Colors.orange,
                    child: Icon(Icons.add_location_alt),
                  ),
                ),
              ],
            ),
    );
  }
}
