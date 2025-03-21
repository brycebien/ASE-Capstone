import 'package:ase_capstone/models/directions.dart';
import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class DirectionsHandler {
  static const String _baseUrl =
      'https://maps.googleapis.com/maps/api/directions/json?';
  static const String _baseUrlGeocoding =
      'https://maps.googleapis.com/maps/api/geocode/json?';

  final Dio _dio;

  DirectionsHandler({Dio? dio}) : _dio = dio ?? Dio();

  Future<Directions> getDirections({
    required LatLng origin,
    required LatLng destination,
  }) async {
    final response = await _dio.get(_baseUrl, queryParameters: {
      'origin': '${origin.latitude},${origin.longitude}',
      'destination': '${destination.latitude},${destination.longitude}',
      'mode': 'walking',
      'key': dotenv.env['GOOGLE_MAPS_API_KEY'],
    });

    if (response.statusCode == 200) {
      return Directions.fromMap(response.data);
    } else {
      throw Exception('Failed to load directions');
    }
  }

  Future<LatLng> getDirectionFromAddress({required String address}) async {
    final result = await _dio.get(_baseUrlGeocoding, queryParameters: {
      'address': address,
      'key': dotenv.env['GOOGLE_MAPS_API_KEY'],
    });

    return LatLng(result.data['results'][0]['geometry']['location']['lat'],
        result.data['results'][0]['geometry']['location']['lng']);

    // try {
    //   final directions = getDirections(
    //       origin: origin,
    //       destination: LatLng(
    //           result.data['results'][0]['geometry']['location']['lat'],
    //           result.data['results'][0]['geometry']['location']['lng']));
    //   return directions;
    // } catch (e) {
    //   throw Exception('Failed to load directions');
    // }
  }
}
