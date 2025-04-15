import 'package:ase_capstone/components/searchable_list.dart';
import 'package:ase_capstone/components/textfield.dart';
import 'package:ase_capstone/utils/utils.dart';
import 'package:flutter/material.dart';

class SearchResources extends StatefulWidget {
  final List<Map<String, dynamic>> data;
  final List<dynamic> buildings;
  final Function onEdit;
  final Function onDelete;
  const SearchResources({
    super.key,
    required this.data,
    required this.buildings,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  State<SearchResources> createState() => _SearchResourcesState();
}

class _SearchResourcesState extends State<SearchResources> {
  final TextEditingController _newResourceNameController =
      TextEditingController();
  final TextEditingController _newResourceRoomController =
      TextEditingController();
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
              searchBarHint: 'Search by building or resource name',
              keys: ['name', 'building', 'room'],
              prependSubtitle: ['Building: ', 'Room: '],
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
                              Navigator.of(context).pop();
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
                                setState(() {});
                              }
                            },
                            icon: Icon(Icons.delete, color: Colors.red),
                          ),
                          SizedBox(width: 5),
                          // EDIT BUTTON
                          IconButton(
                            onPressed: () async {
                              Navigator.of(context).pop();
                              String? selectedResourceBuilding;
                              Map<String, dynamic> newResource =
                                  await showDialog(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return AlertDialog(
                                          title:
                                              Text('Edit ${resource['name']}'),
                                          content: Column(
                                              mainAxisSize: MainAxisSize.min,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                    'Current Name: ${resource['name']}'),
                                                SizedBox(height: 5),
                                                MyTextField(
                                                  controller:
                                                      _newResourceNameController,
                                                  hintText: 'New Resource Name',
                                                  obscureText: false,
                                                ),
                                                SizedBox(height: 5),
                                                Text(
                                                    'Current Building: ${resource['building']}'),
                                                SizedBox(height: 5),
                                                Autocomplete<
                                                    Map<String, dynamic>>(
                                                  optionsBuilder:
                                                      (TextEditingValue
                                                          textEditingValue) {
                                                    if (textEditingValue
                                                        .text.isEmpty) {
                                                      return const Iterable<
                                                          Map<String,
                                                              dynamic>>.empty();
                                                    }
                                                    return widget.buildings
                                                        .where((building) {
                                                      return building['name']
                                                          .toLowerCase()
                                                          .contains(
                                                              textEditingValue
                                                                  .text
                                                                  .toLowerCase());
                                                    }).cast<
                                                            Map<String,
                                                                dynamic>>();
                                                  },
                                                  displayStringForOption:
                                                      (Map<String, dynamic>
                                                              building) =>
                                                          building['name'],
                                                  onSelected:
                                                      (Map<String, dynamic>
                                                          selectedBuilding) {
                                                    setState(() {
                                                      selectedResourceBuilding =
                                                          selectedBuilding[
                                                              'name'];
                                                    });
                                                  },
                                                  fieldViewBuilder: (BuildContext
                                                          context,
                                                      TextEditingController
                                                          textEditingController,
                                                      FocusNode focusNode,
                                                      VoidCallback
                                                          onFieldSubmitted) {
                                                    return TextFormField(
                                                      controller:
                                                          textEditingController,
                                                      focusNode: focusNode,
                                                      decoration:
                                                          InputDecoration(
                                                        labelText:
                                                            'Resource Building',
                                                        border:
                                                            OutlineInputBorder(),
                                                      ),
                                                    );
                                                  },
                                                ),
                                                SizedBox(height: 5),
                                                Text(
                                                    'Current Room Number: ${resource['room']}'),
                                                SizedBox(height: 5),
                                                MyTextField(
                                                  controller:
                                                      _newResourceRoomController,
                                                  hintText: 'New Room Number',
                                                  obscureText: false,
                                                  isNumber: true,
                                                ),
                                              ]),
                                          actions: [
                                            TextButton(
                                              onPressed: () {
                                                _newResourceNameController
                                                    .clear();
                                                _newResourceRoomController
                                                    .clear();
                                                Navigator.of(context).pop();
                                              },
                                              child: const Text('Cancel'),
                                            ),
                                            TextButton(
                                              onPressed: () {
                                                if (_newResourceNameController.text.isEmpty ||
                                                    _newResourceRoomController
                                                        .text.isEmpty ||
                                                    selectedResourceBuilding ==
                                                        null) {
                                                  Utils.displayMessage(
                                                    context: context,
                                                    message:
                                                        'Please fill in all fields.',
                                                  );
                                                  return;
                                                }
                                                Map<String, dynamic>
                                                    newResource = {
                                                  'name':
                                                      _newResourceNameController
                                                          .text,
                                                  'building':
                                                      selectedResourceBuilding,
                                                  'room':
                                                      _newResourceRoomController
                                                          .text,
                                                };
                                                _newResourceNameController
                                                    .clear();
                                                _newResourceRoomController
                                                    .clear();
                                                Navigator.of(context)
                                                    .pop(newResource);
                                              },
                                              child: const Text('Save'),
                                            )
                                          ],
                                        );
                                      });

                              if (newResource.isNotEmpty) {
                                widget.onEdit(
                                  resource,
                                  newResource,
                                );
                                setState(() {
                                  _newResourceNameController.clear();
                                  _newResourceRoomController.clear();
                                });
                              }
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
