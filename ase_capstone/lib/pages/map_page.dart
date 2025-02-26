import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:async';

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
  Set<Marker> _markers = {};

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  void _addEventMarker(LatLng position) async {
    String markerId = position.toString();
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
                    child: Text("Orange"),
                    value: BitmapDescriptor.hueOrange,
                  ),
                  DropdownMenuItem(
                    child: Text("Red"),
                    value: BitmapDescriptor.hueRed,
                  ),
                  DropdownMenuItem(
                    child: Text("Blue"),
                    value: BitmapDescriptor.hueBlue,
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
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                if (nameController.text.isNotEmpty) {
                  markerTitle = nameController.text;
                }
                Navigator.pop(context);
              },
              child: Text("Save"),
            ),
          ],
        );
      },
    );

    final Marker marker = Marker(
      markerId: MarkerId(markerId),
      position: position,
      icon: BitmapDescriptor.defaultMarkerWithHue(markerColor),
      infoWindow: InfoWindow(title: markerTitle),
    );

    setState(() {
      _markers.add(marker);
    });

    Timer(Duration(minutes: 2), () {
      setState(() {
        _markers.removeWhere((m) => m.markerId.value == markerId);
      });
    });
  }

  void signUserOut() async {
    await FirebaseAuth.instance.signOut();
    if (!mounted) return;
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
          IconButton(
            onPressed: signUserOut,
            icon: Icon(Icons.logout),
          ),
        ],
        automaticallyImplyLeading: false,
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
                onTap: () {},
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
                onTap: () {},
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
            zoomControlsEnabled: false,
            markers: _markers,
            onTap: (LatLng position) {
              _addEventMarker(position);
            },
          ),
          Positioned(
            bottom: 16,
            right: 16,
            child: FloatingActionButton(
              onPressed: () {},
              backgroundColor: Colors.orange,
              child: Icon(Icons.add_location_alt),
            ),
          ),
        ],
      ),
    );
  }
}

