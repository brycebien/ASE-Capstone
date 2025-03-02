import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
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

  @override
  void initState() {
    super.initState();
    _listenToPins();
    _checkExpiredPins();
  }

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  void _listenToPins() {
    FirebaseFirestore.instance.collection('pins').snapshots().listen((snapshot) {
      print("Firestore snapshot received: ${snapshot.docs.length} documents");
      setState(() {
        _markers.clear(); // Clear existing markers before updating
        for (var doc in snapshot.docs) {
          final data = doc.data();
          if (data.containsKey('latitude') && data.containsKey('longitude') && data.containsKey('color') && data.containsKey('title') && data.containsKey('yesVotes') && data.containsKey('noVotes')) {
            print("Adding marker: ${data['title']} at (${data['latitude']}, ${data['longitude']})");
            _markers.add(
              Marker(
                markerId: MarkerId(doc.id),
                position: LatLng((data['latitude'] as num).toDouble(), (data['longitude'] as num).toDouble()),
                icon: BitmapDescriptor.defaultMarkerWithHue((data['color'] as num).toDouble()),
                infoWindow: InfoWindow(
                  title: data['title'],
                  snippet: 'Yes: ${data['yesVotes']} No: ${data['noVotes']}',
                  onTap: () => _showVoteDialog(doc.id, data['yesVotes'], data['noVotes']),
                ),
              ),
            );
          } else {
            print("Document missing required fields: ${doc.id}");
          }
        }
      });
    }, onError: (error) {
      print("Error fetching Firestore data: $error");
    });
  }

  void _addEventMarker(LatLng position) async {
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
                  DropdownMenuItem(child: Text("Orange"), value: BitmapDescriptor.hueOrange),
                  DropdownMenuItem(child: Text("Red"), value: BitmapDescriptor.hueRed),
                  DropdownMenuItem(child: Text("Blue"), value: BitmapDescriptor.hueBlue),
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
            TextButton(onPressed: () => Navigator.pop(context), child: Text("Cancel")),
            TextButton(
              onPressed: () {
                if (nameController.text.isNotEmpty) {
                  markerTitle = nameController.text;
                }
                FirebaseFirestore.instance.collection('pins').add({
                  'latitude': position.latitude,
                  'longitude': position.longitude,
                  'title': markerTitle,
                  'color': markerColor.toDouble(), // Ensure color is stored as double
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
                Navigator.pop(context);
              },
              child: Text("Yes"),
            ),
            TextButton(
              onPressed: () {
                _updateVotes(markerId, false);
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
    DocumentReference docRef = FirebaseFirestore.instance.collection('pins').doc(markerId);
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
        transaction.update(docRef, {'yesVotes': newYesVotes, 'noVotes': newNoVotes, 'lastActivity': FieldValue.serverTimestamp()});
      }
    });
  }

  void _checkExpiredPins() async {
    final now = DateTime.now();
    final expirationTime = now.subtract(Duration(hours: 24));

    FirebaseFirestore.instance.collection('pins').where('lastActivity', isLessThan: expirationTime).get().then((snapshot) {
      for (var doc in snapshot.docs) {
        doc.reference.delete();
      }
    }).catchError((error) {
      print("Error checking expired pins: $error");
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
          IconButton(onPressed: signUserOut, icon: Icon(Icons.logout)),
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
                decoration: BoxDecoration(color: Theme.of(context).colorScheme.primary),
                child: Text('Settings', style: TextStyle(color: Theme.of(context).colorScheme.tertiary, fontSize: 24)),
              ),
              ListTile(leading: Icon(Icons.account_circle), title: Text('Profile'), onTap: () {}),
              ListTile(leading: Icon(Icons.settings), title: Text('General'), onTap: () {
                Navigator.pushNamed(context, '/settings', arguments: user);
              }),
              ListTile(leading: Icon(Icons.help), title: Text('Help'), onTap: () {}),
            ],
          ),
        ),
      ),
      body: Stack(
        children: [
          GoogleMap(
            onMapCreated: _onMapCreated,
            initialCameraPosition: CameraPosition(target: _center, zoom: 15.5),
            zoomControlsEnabled: false,
            markers: _markers,
            onTap: _addEventMarker,
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


