// lib/pages/resources_page.dart
import 'package:flutter/material.dart';
import 'package:ase_capstone/components/textfield.dart';
import 'package:ase_capstone/utils/firebase_operations.dart';

class ResourcesPage extends StatefulWidget {
  const ResourcesPage({super.key});

  @override
  State<ResourcesPage> createState() => _ResourcesPageState();
}

class _ResourcesPageState extends State<ResourcesPage> {
  final FirestoreService _firestoreService = FirestoreService();
  List<Map<String, dynamic>> _resources = [];
  List<Map<String, dynamic>> _filteredResources = [];

  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _newTitleController = TextEditingController();
  final TextEditingController _newTypeController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _getResources();
  }

  Future<void> _getResources() async {
    final resources = await _firestoreService.getResources();
    setState(() {
      _resources = resources;
      _filteredResources = _resources;
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
                await _firestoreService.addResource({
                  'title': _newTitleController.text,
                  'type': _newTypeController.text,
                  'timestamp': DateTime.now(),
                });
                Navigator.of(context).pop();
                _newTitleController.clear();
                _newTypeController.clear();
                _getResources();
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
    return _filteredResources.isEmpty
        ? const Center(child: CircularProgressIndicator())
        : Scaffold(
            appBar: AppBar(
              title: const Text('Campus Resources'),
            ),
            body: Column(
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
                  child: ListView.builder(
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
