import 'package:ase_capstone/utils/firebase_operations.dart';
import 'package:flutter/material.dart';

class EditUniversityPage extends StatefulWidget {
  const EditUniversityPage({super.key});

  @override
  State<EditUniversityPage> createState() => _EditUniversityPageState();
}

class _EditUniversityPageState extends State<EditUniversityPage> {
  final FirestoreService _firestoreServices = FirestoreService();
  late String _name;
  Map<String, dynamic> _university = {};

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // get args passed to map page via Navigator.pushNamed
    final args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    if (args != null) {
      setState(() {
        _name = args['name'];
      });
      _getUniversity();
    }
  }

  Future<void> _getUniversity() async {
    Map<String, dynamic> university =
        await _firestoreServices.getUniversityByName(_name);

    setState(() {
      _university = university;
    });
  }

  @override
  Widget build(BuildContext context) {
    return _university.isEmpty
        ? const Center(
            child: CircularProgressIndicator(),
          )
        : Scaffold(
            appBar: AppBar(
              title: Text('Edit ${_university['abbreviation']}'),
            ),
            body: Padding(
              padding: const EdgeInsets.all(8.0),
              child: SingleChildScrollView(
                child: Center(
                  child: Column(
                    // crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // University Title
                      Text(
                        _university['name'],
                        style: const TextStyle(fontSize: 24),
                        overflow: TextOverflow.clip,
                        textAlign: TextAlign.center,
                      ),

                      Divider(),
                      SizedBox(height: 10),

                      // Buildings ExpansionTile
                      ExpansionTile(
                        title: const Text('Buildings'),
                        children:
                            _university['buildings'].map<Widget>((building) {
                          return ListTile(
                            title: Text(building['name']),
                            subtitle: Text(building['code']),
                            trailing: IconButton(
                                icon: const Icon(Icons.edit), onPressed: () {}),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
  }
}
