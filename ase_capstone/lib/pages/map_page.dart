import 'package:ase_capstone/utils/utils.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:location/location.dart';

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

  @override
  void initState() {
    _getCurrentLocation(); // get the user's location
    _loadMapStyle(); // load the map's color theme (light or dark mode)
    super.initState();
  }

  void _getCurrentLocation() async {
    Location location = Location();
    // this stops the app from moving the camera to the user's location when the user does not move.
    location.changeSettings(
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
      location.onLocationChanged.listen((newLocation) {
        setState(() {
          _currentLocation = newLocation;
        });

        // animate the camera to the user's location when the user moves/app is started
        _controller?.animateCamera(CameraUpdate.newCameraPosition(
          CameraPosition(
            zoom: 20.0,
            target: LatLng(
              _currentLocation!.latitude!,
              _currentLocation!.longitude!,
            ),
          ),
        ));
      });
    } catch (e) {
      Utils.displayMessage(
        context: context,
        message: 'Unable to get location: $e',
      );
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
  }

  // sign user out
  void signUserOut() async {
    // sign out user
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
          // sign out button
          IconButton(
            onPressed: signUserOut,
            icon: Icon(Icons.logout),
          ),
        ],
        title: Text('Campus Compass'),
      ),
      drawer: SafeArea(
        child: Drawer(
          child: ListView(
            padding: EdgeInsets.zero,
            children: <Widget>[
              DrawerHeader(
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary,
                ),
                child: Text(
                  'Settings',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.tertiary,
                    fontSize: 24,
                  ),
                ),
              ),
              ListTile(
                leading: Icon(Icons.account_circle),
                title: Text('Profile'),
                onTap: () {
                  // Handle profile tap
                },
              ),
              ListTile(
                leading: Icon(Icons.settings),
                title: Text('General'),
                onTap: () {
                  Navigator.pushNamed(
                    context,
                    '/settings',
                    arguments: user,
                  );
                },
              ),
              ListTile(
                leading: Icon(Icons.calendar_today),
                title: Text('Class Schedule'),
                onTap: () {
                  Navigator.pushNamed(
                    context,
                    '/schedule',
                  );
                },
              ),
            ],
          ),
        ),
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
                  markers: {
                    Marker(
                      // Marker set to user's location
                      markerId: const MarkerId('Current Location'),
                      position: LatLng(
                        _currentLocation!.latitude!,
                        _currentLocation!.longitude!,
                      ),
                      infoWindow: InfoWindow(
                        title: 'Current Location',
                        snippet: 'You are here',
                      ),
                    ),
                  },
                ),
                Positioned(
                  bottom: 16,
                  right: 16,
                  child: FloatingActionButton(
                    onPressed: () {
                      // Add your onPressed code here!
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
