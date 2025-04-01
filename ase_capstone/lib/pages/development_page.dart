import 'package:ase_capstone/utils/firebase_operations.dart';
import 'package:flutter/material.dart';

class DevelopmentPage extends StatefulWidget {
  const DevelopmentPage({super.key});

  @override
  State<DevelopmentPage> createState() => _DevelopmentPageState();
}

class _DevelopmentPageState extends State<DevelopmentPage> {
  final FirestoreService _firestoreServices = FirestoreService();
  List<Map<String, dynamic>> _universities = [];
  List<Map<String, dynamic>> _foundUniversities = [];

  final TextEditingController _searchController = TextEditingController();

  @override
  initState() {
    super.initState();
    _getUniversities();
  }

  Future<void> _getUniversities() async {
    final universities = await _firestoreServices.getUniversities();
    setState(() {
      _universities = universities;
      _foundUniversities = universities;
    });
  }

  void _searchUniversities(String query) {
    setState(() {
      _foundUniversities = _universities.where((university) {
        final name = university['name'].toLowerCase();
        final abbreviation = university['abbreviation'].toLowerCase();
        final searchLower = query.toLowerCase();
        return name.contains(searchLower) || abbreviation.contains(searchLower);
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return _universities.isEmpty
        ? const Center(
            child: CircularProgressIndicator(),
          )
        : Scaffold(
            appBar: AppBar(
              title: const Text('Development Page'),
            ),
            body: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextField(
                    controller: _searchController,
                    decoration: const InputDecoration(
                      labelText: 'Search',
                      suffixIcon: Icon(Icons.search),
                    ),
                    onChanged: (value) {
                      _searchUniversities(value);
                    },
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: _foundUniversities.length,
                    itemBuilder: (context, index) {
                      return Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Card(
                              key: ValueKey(_foundUniversities[index]['name']),
                              elevation: 8,
                              child: ListTile(
                                title: Text(_foundUniversities[index]['name']),
                                subtitle: Text(
                                    _foundUniversities[index]['abbreviation']),
                                trailing: IconButton(
                                  icon: Icon(Icons.edit),
                                  onPressed: () {
                                    Navigator.pushNamed(
                                      context,
                                      '/edit-university',
                                      arguments: {
                                        'name': _foundUniversities[index]
                                            ['name']
                                      },
                                    );
                                  },
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: 10)
                        ],
                      );
                    },
                  ),
                ),
              ],
            ),
            floatingActionButton: FloatingActionButton(
              onPressed: () {
                // TODO: allow users to create a new university
                Navigator.pushNamed(
                  context,
                  '/create-university',
                );
                // _createUniversityDialog();
              },
              child: Icon(Icons.add),
            ),
          );
  }
}
