import 'package:ase_capstone/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:ase_capstone/utils/firebase_operations.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:firebase_auth/firebase_auth.dart';

class EventPage extends StatefulWidget {
  const EventPage({super.key});

  @override
  State<EventPage> createState() => _EventPageState();
}

class _EventPageState extends State<EventPage> {
  final FirestoreService _firestoreService = FirestoreService();
  final user = FirebaseAuth.instance.currentUser!;
  String? _eventUrl;

  @override
  void initState() {
    super.initState();
    _fetchEventUrl();
  }

  Future<void> _fetchEventUrl() async {
    try {
      final url = await _firestoreService.getEventUrl(
          userId: user.uid); // Fetch URL from Firestore
      if (url.isEmpty || url == 'https://default-url.com') {
        // Handle case where no event URL is available
        setState(() {
          _eventUrl = null;
        });
        if (mounted) {
          Utils.displayMessage(
            context: context,
            message: 'This university has no event URL.',
          );
        }
      } else {
        setState(() {
          _eventUrl = url;
        });
      }
    } catch (e) {
      setState(() {
        _eventUrl = null; // Handle error by setting URL to null
      });
      if (mounted) {
        Utils.displayMessage(
          context: context,
          message: 'Failed to load the event URL.',
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Event Page'),
      ),
      body: _eventUrl == null
          ? const Center(
              child: Text(
                'This university has no event URL.',
                style: TextStyle(fontSize: 16),
                textAlign: TextAlign.center,
              ),
            )
          : InAppWebView(
              initialUrlRequest: URLRequest(
                url: WebUri(_eventUrl!), // Use the fetched URL
              ),
            ),
    );
  }
}
