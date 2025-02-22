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
  late String username;
  static const LatLng _center = LatLng(39.033, -84.4631);
  late GoogleMapController mapController;

  @override
  void initState() {
    super.initState();
    username = user.email!.substring(0, user.email!.indexOf('@'));
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
      appBar: AppBar(
        actions: [
          // sign out button
          IconButton(
            onPressed: signUserOut,
            icon: Icon(Icons.logout),
          ),
        ],
        automaticallyImplyLeading: false, // remove back button
        title: Text('Hello, $username'),
        backgroundColor: const Color.fromARGB(255, 248, 120, 81),
      ),
      body: GoogleMap(
        onMapCreated: _onMapCreated,
        initialCameraPosition: CameraPosition(
          target: _center,
          zoom: 15.5,
        ),
      ),
    );
  }
}
