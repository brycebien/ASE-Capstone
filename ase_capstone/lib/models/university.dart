import 'package:google_maps_flutter/google_maps_flutter.dart';

class University {
  final String name;
  final LatLng location;
  final List<Map<String, dynamic>> buildings;

  University({
    required this.name,
    required this.location,
    required this.buildings,
  });

  factory University.fromJson(Map<String, dynamic> json) {
    // convert the json data to a University object
    return University(
      name: json['name'],
      location: LatLng(
        json['location']['latitude'],
        json['location']['longitude'],
      ),
      buildings: List<Map<String, dynamic>>.from(json['buildings']),
    );
  }

  Map<String, dynamic> toJson() {
    // convert the University object to json data
    return {
      'name': name,
      'location': {
        'latitude': location.latitude,
        'longitude': location.longitude,
      },
      'buildings': buildings,
    };
  }
}
