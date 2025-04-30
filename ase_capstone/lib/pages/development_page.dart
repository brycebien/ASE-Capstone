import 'package:ase_capstone/utils/firebase_operations.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class DevelopmentPage extends StatefulWidget {
  const DevelopmentPage({super.key});

  @override
  State<DevelopmentPage> createState() => _DevelopmentPageState();
}

class _DevelopmentPageState extends State<DevelopmentPage> {
  final FirestoreService _firestoreServices = FirestoreService();
  final User user = FirebaseAuth.instance.currentUser!;
  bool? _isAdmin;

  List<Map<String, dynamic>> _universities = [];
  List<Map<String, dynamic>> _foundUniversities = [];

  final TextEditingController _searchController = TextEditingController();

  @override
  initState() {
    super.initState();
    _getUniversities();
    _checkUserAdmin();
  }

  Future<void> _checkUserAdmin() async {
    bool isAdmin = await _firestoreServices.isAdmin(userId: user.uid);
    setState(() {
      _isAdmin = isAdmin;
    });
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
    return _universities.isEmpty || _isAdmin == null
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
                  padding: kIsWeb
                      ? EdgeInsets.symmetric(
                          horizontal: MediaQuery.of(context).size.width > 500
                              ? MediaQuery.of(context).size.width * .3
                              : 20,
                        )
                      : EdgeInsets.all(8),
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
                            padding: kIsWeb
                                ? EdgeInsets.symmetric(
                                    horizontal: MediaQuery.of(context)
                                                .size
                                                .width >
                                            500
                                        ? MediaQuery.of(context).size.width * .3
                                        : 20,
                                  )
                                : EdgeInsets.all(8),
                            child: Card(
                              key: ValueKey(_foundUniversities[index]['name']),
                              elevation: 8,
                              child: ListTile(
                                title: Text(_foundUniversities[index]['name']),
                                subtitle: Text(
                                    _foundUniversities[index]['abbreviation']),
                                trailing: _isAdmin! ||
                                        _foundUniversities[index]
                                                ['createdBy'] ==
                                            user.uid
                                    ? IconButton(
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
                                      )
                                    : null,
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
                Navigator.pushNamed(
                  context,
                  '/create-university',
                );
              },
              child: Icon(Icons.add),
            ),
          );
  }
}
