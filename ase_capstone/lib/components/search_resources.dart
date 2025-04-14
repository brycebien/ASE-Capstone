import 'package:ase_capstone/components/searchable_list.dart';
import 'package:flutter/material.dart';

class SearchResources extends StatefulWidget {
  final List<Map<String, dynamic>> data;
  final Function onEdit;
  final Function onDelete;
  const SearchResources({
    super.key,
    required this.data,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  State<SearchResources> createState() => _SearchResourcesState();
}

class _SearchResourcesState extends State<SearchResources> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Search Resources'),
      ),
      body: SearchableList(
        items: widget.data,
        keys: ['name', 'building'],
        prependSubtitle: 'Building: ',
        onSelected: (resource) async {
          // TODO: show dialog similar to edit building for resource (cannot change building have to delete to do that)
          await showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: Text('TEST'),
                  content: Text('${resource['building']}'),
                );
              });
        },
      ),
    );
  }
}
