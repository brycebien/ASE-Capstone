import 'package:ase_capstone/components/map_editor.dart';
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
  bool _isLoading = true;
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
        await _firestoreServices.getUniversityByName(name: _name);
    if (mounted) {
      setState(() {
        _university = university;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return _isLoading
        ? const Center(child: CircularProgressIndicator())
        : MapEditor(university: _university);
  }
}
