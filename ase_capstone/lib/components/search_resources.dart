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
      body: widget.data.isEmpty
          ? Center(
              child: Text(
              'There are no resources for this university.',
              style: TextStyle(fontSize: 20),
              textAlign: TextAlign.center,
            ))
          : SearchableList(
              items: widget.data,
              keys: ['name', 'building'],
              prependSubtitle: 'Building: ',
              onSelected: (resource) async {
                await showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: Text(resource['name']),
                        content: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Resource Name: ${resource['name']}',
                              style: TextStyle(fontSize: 15),
                            ),
                            SizedBox(height: 5),
                            Text(
                              'Building: ${resource['building']}',
                              style: TextStyle(fontSize: 15),
                            ),
                            SizedBox(height: 5),
                            Text(
                              'Room Number: ${resource['room']}',
                              style: TextStyle(fontSize: 15),
                            ),
                          ],
                        ),
                        actions: [
                          // DELETE BUTTON
                          IconButton(
                            onPressed: () async {
                              bool result = await showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return AlertDialog(
                                      title: Text(
                                          'Are you sure you want to delete ${resource['name']}'),
                                      content: Text('This cannot be undone.'),
                                      actions: [
                                        TextButton(
                                          onPressed: () {
                                            Navigator.of(context).pop(false);
                                          },
                                          child: const Text('Cancel'),
                                        ),
                                        TextButton(
                                          onPressed: () {
                                            Navigator.of(context).pop(true);
                                          },
                                          child: const Text('Delete'),
                                        ),
                                      ],
                                    );
                                  });
                              if (result) {
                                widget.onDelete(resource);
                                setState(() {
                                  Navigator.of(context).pop();
                                });
                              }
                            },
                            icon: Icon(Icons.delete, color: Colors.red),
                          ),
                          SizedBox(width: 5),
                          // EDIT BUTTON
                          IconButton(
                            onPressed: () {
                              widget.onEdit(resource);
                              Navigator.of(context).pop();
                            },
                            icon: Icon(Icons.edit, color: Colors.lightGreen),
                          ),
                        ],
                      );
                    });
              },
            ),
    );
  }
}
