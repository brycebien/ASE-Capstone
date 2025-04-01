import 'package:ase_capstone/models/directions_handler.dart';
import 'package:ase_capstone/utils/firebase_operations.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class Utils {
  static void displayMessage({required context, required String message}) {
    ScaffoldMessenger.of(context).showSnackBar(
      // displays error message at bottom of screen
      SnackBar(
        content: Text(message),
      ),
    );
  }

  static TimeOfDay parseTimeOfDay(String time) {
    final parts = time.split(':');
    final hour = int.parse(parts[0]);
    final minute = int.parse(parts[1].split(' ')[0]);
    final isPM = time.contains('PM');
    return TimeOfDay(hour: isPM && hour != 12 ? hour + 12 : hour, minute: minute);
  }

  static TimeOfDay subtractMinutesFromTimeOfDay(TimeOfDay time, int minutes) {
    final totalMinutes = time.hour * 60 + time.minute - minutes;
    final newHour = (totalMinutes ~/ 60) % 24;
    final newMinute = totalMinutes % 60;
    return TimeOfDay(hour: newHour, minute: newMinute);
  }

  static bool isTimeInFuture(TimeOfDay now, TimeOfDay time) {
    final nowMinutes = now.hour * 60 + now.minute;
    final timeMinutes = time.hour * 60 + time.minute;
    return timeMinutes > nowMinutes;
  }

  static String authErrorHandler({required FirebaseAuthException e}) {
    switch (e.code) {
      case 'invalid-email':
        return 'Invalid email address';
      case 'user-disabled':
        return 'User is disabled';
      case 'user-not-found':
        return 'User not found';
      case 'wrong-password':
        return 'Incorrect password';
      case 'email-already-in-use':
        return 'Email already in use';
      case 'weak-password':
        return 'Weak password';
      default:
        return 'An unexpected error occured: ${e.message!}';
    }
  }

  static Future<String?> showUniversityDialog({
    required BuildContext context,
    required FirestoreService firesotreService,
  }) async {
    List<Map<String, dynamic>> universities =
        await firesotreService.getUniversities();

    return showDialog<String>(
        // ignore: use_build_context_synchronously
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Choose University'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: universities.map(
                (e) {
                  return ListTile(
                    title: Text("${e['name']!}\n(${e['abbreviation']})"),
                    onTap: () {
                      Navigator.pop(context, e['name']);
                    },
                  );
                },
              ).toList(),
            ),
          );
        });
  }

  static Future<bool> validateAddress({required String address}) async {
    // validate address using google maps api
    try {
      await DirectionsHandler().getDirectionFromAddress(address: address);
      return true;
    } catch (e) {
      return false;
    }
  }

  static void zoomToLocation(
      {required LatLng location,
      required GoogleMapController controller,
      double zoom = 14}) {
    controller.animateCamera(
      CameraUpdate.newLatLngZoom(
        location,
        zoom,
      ),
    );
  }
}
