import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:ase_capstone/utils/utils.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:ase_capstone/utils/firebase_operations.dart';

class InboxPage extends StatefulWidget {
  const InboxPage({super.key});

  @override
  State<InboxPage> createState() => _InboxPageState();
}

class _InboxPageState extends State<InboxPage> {
  final FirestoreService _firestoreService = FirestoreService();
  final User? currentUser = FirebaseAuth.instance.currentUser;
  List<Map<String, dynamic>> notifications = [];

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    final now = TimeOfDay.now();
    final userClasses = await _firestoreService.getClassesFromDatabase(
      userId: currentUser!.uid,
    );

    final List<Map<String, dynamic>> upcomingNotifications = [];
    for (var userClass in userClasses['classes'] ?? []) {
      final startTime = Utils.parseTimeOfDay(userClass['startTime']);
      final notificationTime =
          Utils.subtractMinutesFromTimeOfDay(startTime, 10);

      if (Utils.isTimeInFuture(now, notificationTime)) {
        setState(() {
          upcomingNotifications.add({
            'title': userClass['name'],
            'time': notificationTime.format(context),
            'details': '${userClass['building']} - ${userClass['room']}',
          });
        });
      }
    }

    final Map<String, dynamic> userData =
        await _firestoreService.getUser(userId: currentUser!.uid);
    final List<dynamic> upcomingEvents = userData['eventReminders'] ?? [];

    for (var event in upcomingEvents) {
      if (DateTime.parse(event['date'].toString()).toLocal().year ==
              DateTime.now().year &&
          DateTime.parse(event['date'].toString()).toLocal().month ==
              DateTime.now().month &&
          DateTime.parse(event['date'].toString()).toLocal().day ==
              DateTime.now().day) {
        final eventTime = Utils.parseTimeOfDay(event['startTime']);
        final notificationTime =
            Utils.subtractMinutesFromTimeOfDay(eventTime, 10);

        if (Utils.isTimeInFuture(now, notificationTime)) {
          setState(() {
            upcomingNotifications.add({
              'title': event['name'],
              'time': notificationTime.format(context),
              'details': event['buildingName'],
            });
          });
        }
      }
    }

    setState(() {
      notifications.addAll(upcomingNotifications);
    });
  }

  void _dismissNotification(int index) {
    setState(() {
      notifications.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
      ),
      body: Padding(
        padding: kIsWeb
            ? EdgeInsets.symmetric(
                horizontal: MediaQuery.of(context).size.width > 800
                    ? MediaQuery.of(context).size.width * .3
                    : 20,
              )
            : EdgeInsets.all(8),
        child: notifications.isEmpty
            ? const Center(
                child: Text(
                  'No upcoming notifications.',
                  style: TextStyle(fontSize: 18),
                ),
              )
            : ListView.builder(
                itemCount: notifications.length,
                itemBuilder: (context, index) {
                  final notification = notifications[index];
                  return Card(
                    elevation: 8,
                    child: ListTile(
                      title: Text(
                        notification['title'],
                        style: const TextStyle(fontSize: 18),
                      ),
                      subtitle: Text(
                        'Time: ${notification['time']}\nDetails: ${notification['details']}',
                      ),
                      trailing: IconButton(
                        icon: const Icon(
                          Icons.close,
                          color: Colors.red,
                        ),
                        onPressed: () => _dismissNotification(index),
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }
}
