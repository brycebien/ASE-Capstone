import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';

class Directions {
  final LatLngBounds bounds;
  final List<PointLatLng> polylineCoordinates;
  final String totalDistance;
  final String totalDuration;

  const Directions({
    required this.bounds,
    required this.polylineCoordinates,
    required this.totalDistance,
    required this.totalDuration,
  });

  factory Directions.fromMap(Map<String, dynamic> map) {
    // check if route is available
    if ((map['routes'] as List).isEmpty) {
      throw Exception('No routes found');
    }

    // get route data
    final data = Map<String, dynamic>.from(map['routes'][0]);

    // setting bounds
    final northeast = data['bounds']['northeast'];
    final southwest = data['bounds']['southwest'];
    final bounds = LatLngBounds(
      southwest: LatLng(southwest['lat'], southwest['lng']),
      northeast: LatLng(northeast['lat'], northeast['lng']),
    );

    // setting distance and duration
    String distance = '';
    String duration = '';
    if ((data['legs'] as List).isNotEmpty) {
      final leg = Map<String, dynamic>.from(data['legs'][0]);
      distance = leg['distance']['text'];
      duration = leg['duration']['text'];
    }

    // setting polyline coordinates
    List<PointLatLng> polyLine =
        PolylinePoints().decodePolyline(data['overview_polyline']['points']);

    // return Directions object
    return Directions(
      bounds: bounds,
      polylineCoordinates: polyLine,
      totalDistance: distance,
      totalDuration: duration,
    );
  }
}
