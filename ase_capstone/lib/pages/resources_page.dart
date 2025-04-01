// lib/pages/resources_page.dart
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
  List<dynamic> _resources = [];
  List<dynamic> _filteredResources = [];

  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _newTitleController = TextEditingController();
  final TextEditingController _newTypeController = TextEditingController();

  String? _universityId;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadUniversityAndResources();
  }

  Future<void> _loadUniversityAndResources() async {
    setState(() => isLoading = true);

    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      print("No user signed in.");
      setState(() => isLoading = false);
      return;
    }

    final user = await _firestoreService.getUser(userId: uid);
    final universityId = user['university'] as String?;

    if (universityId == null) {
      print(" User has no university set.");
      setState(() => isLoading = false);
      return;
    }

    List<dynamic> resources =
        await _firestoreService.getResources(universityId: universityId);

    setState(() {
      _resources = resources;
      _filteredResources = resources;
      isLoading = false;
      _universityId = universityId;
    });
  }

  void _searchResources(String query) {
    setState(() {
      _filteredResources = _resources.where((resource) {
        final title = resource['title'].toLowerCase();
        final type = resource['type'].toLowerCase();
        final searchLower = query.toLowerCase();
        return title.contains(searchLower) || type.contains(searchLower);
      }).toList();
    });
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
                _newTitleController.clear();
                _newTypeController.clear();
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

                // await FirebaseFirestore.instance
                //     .collection('universities')
                //     .doc(_universityId)
                //     .update({newFieldKey: newFieldValue});

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
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextField(
                    controller: _searchController,
                    decoration: const InputDecoration(
                      labelText: 'Search Resources',
                      suffixIcon: Icon(Icons.search),
                    ),
                    onChanged: _searchResources,
                  ),
                ),
                Expanded(
                  child: _filteredResources.isEmpty
                      ? Center(child: Text("No resources available."))
                      : ListView.builder(
                          itemCount: _filteredResources.length,
                          itemBuilder: (context, index) {
                            final resource = _filteredResources[index];
                            return Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Card(
                                elevation: 6,
                                child: ListTile(
                                  title: Text(resource['title']),
                                  subtitle: Text('Type: ${resource['type']}'),
                                ),
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _createResourceDialog,
        child: Icon(Icons.add),
        tooltip: 'Add Resource',
      ),
    );
  }
}
