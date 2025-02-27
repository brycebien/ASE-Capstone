import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter/services.dart' show rootBundle;

class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  final user = FirebaseAuth.instance.currentUser!;
  GoogleMapController? _controller;
  static const LatLng _center = LatLng(39.033, -84.4631);
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  late String _mapStyleString;
  String? _mapStyle;

  @override
  void initState() {
    // get username from email
    super.initState();
    _loadMapStyle();
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
        leading: IconButton(
          icon: Icon(Icons.menu),
          onPressed: () {
            _scaffoldKey.currentState?.openEndDrawer();
          },
        ),
        actions: [
          // sign out button
          IconButton(
            onPressed: signUserOut,
            icon: Icon(Icons.logout),
          ),
        ],
        automaticallyImplyLeading: false, // remove back button
        title: Text('Campus Compass'),
      ),
      endDrawer: SafeArea(
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
                leading: Icon(Icons.help),
                title: Text('Help'),
                onTap: () {
                  // Handle help tap
                },
              ),
            ],
          ),
        ),
      ),
      body: Stack(
        children: [
          GoogleMap(
            onMapCreated: _onMapCreated,
            style: _mapStyle,
            initialCameraPosition: CameraPosition(
              target: _center,
              zoom: 15.5,
              tilt: 0,
            ),
            compassEnabled:
                true, // not working? compass icon not showing (I think this is a location data issue since we are not getting the user's location yet)
            rotateGesturesEnabled: true,
            myLocationButtonEnabled: true,
            zoomControlsEnabled: false, // Disable zoom controls (+/- buttons)
            myLocationEnabled: true,
            cameraTargetBounds: CameraTargetBounds(
              LatLngBounds(
                southwest: LatLng(39.028, -84.467),
                northeast: LatLng(39.038, -84.459),
              ),
            ),
            minMaxZoomPreference: MinMaxZoomPreference(15.0, 20.0),
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
