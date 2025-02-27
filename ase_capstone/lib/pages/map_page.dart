import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  final user = FirebaseAuth.instance.currentUser!;
  static const LatLng _center = LatLng(39.033, -84.4631);
  late GoogleMapController mapController;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    // get username from email
    super.initState();
  }

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  // sign user out
  void signUserOut() async {
    // sign out user
    await FirebaseAuth.instance.signOut();

    // check if the widget is still mounted
    if (!mounted) return;

    // navigate to login page
    Navigator.of(context).pushReplacementNamed('/');
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
                  Navigator.pushNamed(
                    context,
                    '/profile',
                    arguments: user,
                  );
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
            initialCameraPosition: CameraPosition(
              target: _center,
              zoom: 15.5,
            ),
            zoomControlsEnabled: false, // Disable zoom controls
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
