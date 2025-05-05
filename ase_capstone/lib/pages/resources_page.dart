// lib/pages/resources_page.dart
import 'package:ase_capstone/components/resource_details_dialog.dart';
import 'package:ase_capstone/components/searchable_list.dart';
import 'package:ase_capstone/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:ase_capstone/utils/firebase_operations.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ResourcesPage extends StatefulWidget {
  const ResourcesPage({super.key});

  @override
  State<ResourcesPage> createState() => _ResourcesPageState();
}

class _ResourcesPageState extends State<ResourcesPage> {
  User? currentUser = FirebaseAuth.instance.currentUser;
  final FirestoreService _firestoreService = FirestoreService();
  List<Map<String, dynamic>> _resources = [];

  late Map<String, dynamic> _university;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadUniversityAndResources();
  }

  Future<void> _loadUniversityAndResources() async {
    setState(() {
      isLoading = true;
    });

    final uid = FirebaseAuth.instance.currentUser?.uid;
    final Map<String, dynamic> userUniversity =
        await _firestoreService.getUniversityByName(
            name: await _firestoreService.getUserUniversity(userId: uid!));

    setState(() {
      _university = userUniversity;
    });

    try {
      List<Map<String, dynamic>> resources = await _firestoreService
          .getResources(universityId: userUniversity['name']);
      setState(() {
        _resources = resources;
      });
    } catch (e) {
      setState(() {
        Utils.displayMessage(
          context: context,
          message: 'This University has no resources, please check back later',
        );
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Campus Resources'),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : SearchableList(
              items: _resources,
              searchBarHint:
                  'Search by resource name, building, or room number',
              keys: ['name', 'building', 'room'],
              prependSubtitle: ['Building: ', 'Room: '],
              onSelected: (resource) async {
                await showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return ResourceDetailsDialog(
                        resource: resource,
                        university: _university,
                      );
                    });
              },
            ),
    );
  }
}
