import 'package:ase_capstone/components/map_editor.dart';
import 'package:flutter/material.dart';

class CreateUniversityPage extends StatefulWidget {
  const CreateUniversityPage({super.key});

  @override
  State<CreateUniversityPage> createState() => _CreateUniversityPageState();
}

class _CreateUniversityPageState extends State<CreateUniversityPage> {
  @override
  Widget build(BuildContext context) {
    return MapEditor();
  }
}
