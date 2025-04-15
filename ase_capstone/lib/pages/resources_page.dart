// lib/pages/resources_page.dart
import 'package:ase_capstone/components/resource_details_dialog.dart';
import 'package:ase_capstone/components/searchable_list.dart';
import 'package:ase_capstone/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:ase_capstone/components/textfield.dart';
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

  final TextEditingController _newTitleController = TextEditingController();
  final TextEditingController _newTypeController = TextEditingController();

  late Map<String, dynamic> _university;
  String? _universityId;
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
        _universityId = userUniversity['name'];
      });
    } catch (e) {
      setState(() {
        Utils.displayMessage(
          context: context,
          message: 'Error loading resources, please try again later',
        );
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  void _createResourceDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Add New Resource'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              MyTextField(
                controller: _newTitleController,
                hintText: 'Title (e.g. Library)',
                obscureText: false,
              ),
              SizedBox(height: 10),
              MyTextField(
                controller: _newTypeController,
                hintText: 'Type (e.g. Study, Food, Parking)',
                obscureText: false,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                _newTitleController.clear();
                _newTypeController.clear();
              },
              child: Text('Clear'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                if (_universityId == null) return;

                final newFieldValue = {
                  'title': _newTitleController.text,
                  'type': _newTypeController.text,
                  'timestamp': DateTime.now(),
                };

                _firestoreService.addResource(
                    resource: newFieldValue, uid: currentUser!.uid);

                Navigator.of(context).pop();
                _newTitleController.clear();
                _newTypeController.clear();
                _loadUniversityAndResources();
              },
              child: Text('Add'),
            ),
          ],
        );
      },
    );
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
      floatingActionButton: FloatingActionButton(
        onPressed: _createResourceDialog,
        tooltip: 'Add Resource',
        child: Icon(Icons.add),
      ),
    );
  }
}
