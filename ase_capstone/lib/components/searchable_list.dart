import 'package:ase_capstone/utils/firebase_operations.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class SearchableList extends StatefulWidget {
  final List<Map<String, dynamic>> items;
  final List<String> keys;
  final Widget? trailing;
  final bool includePriorityBuildings;
  final String? prependSubtitle;
  final Function? onSelected;
  final String? searchBarHint;

  const SearchableList({
    super.key,
    required this.items,
    required this.keys,
    this.trailing,
    this.includePriorityBuildings = false,
    this.prependSubtitle,
    this.onSelected,
    this.searchBarHint,
  });

  @override
  State<SearchableList> createState() => _SearchableListState();
}

class _SearchableListState extends State<SearchableList> {
  final FirestoreService _firestoreServices = FirestoreService();
  final user = FirebaseAuth.instance.currentUser!;
  List _foundItems = [];
  List _favoriteItems = [];
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    setState(() {
      _foundItems = widget.items;
    });
    if (widget.includePriorityBuildings) {
      _getFavoriteBuildings();
    }
  }

  void _getFavoriteBuildings() async {
    try {
      await _firestoreServices.getFavorite(userId: user.uid).then(
        (value) {
          setState(() {
            _favoriteItems = value;
          });
        },
      );
    } catch (e) {
      return;
    }
  }

  void _searchList(String query) {
    setState(() {
      _foundItems = widget.items.where((item) {
        final searchLower = query.toLowerCase();
        for (var key in widget.keys) {
          if (item[key]
              .toString()
              .toLowerCase()
              .contains(query.toLowerCase())) {
            return item[key].toLowerCase().contains(searchLower);
          }
        }
        return false;
      }).toList();
    });
  }

  String _getItemsSubtitle({required int index}) {
    String subtitle = "";
    if (widget.keys.length > 1) {
      for (var i = 1; i < widget.keys.length; i++) {
        subtitle += '${_foundItems[index][widget.keys[i]]}';
        if (i + 1 != widget.keys.length) {
          subtitle += '\n'; // add a new line if not the last key
        }
      }
      return subtitle;
    } else {
      return ''; // return empty string if there is only 1 key per item
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Padding(
        padding: const EdgeInsets.all(8),
        child: TextField(
          controller: _searchController,
          decoration: InputDecoration(
            labelText: widget.searchBarHint ?? 'Search',
            suffixIcon: Icon(Icons.search),
          ),
          onChanged: (value) {
            _searchList(value);
          },
        ),
      ),

      // PRIORITY ITEMS EXPANSION TILE
      if (widget.includePriorityBuildings && _favoriteItems.isNotEmpty)
        SizedBox(height: 10),
      if (widget.includePriorityBuildings && _favoriteItems.isNotEmpty)
        ExpansionTile(
          title: const Text('Favorite Buildings'),
          children: [
            ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.3,
              ),
              child: ListView(
                shrinkWrap: true,
                children: _favoriteItems.map((item) {
                  return ListTile(
                    title: Text(item),
                    onTap: () {
                      if (widget.onSelected != null) {
                        widget.onSelected!(widget.items.firstWhere((element) {
                          return element[widget.keys[0]] == item;
                        }));
                      } else {
                        setState(() {
                          _foundItems = widget.items.where((element) {
                            return element[widget.keys[0]] == item;
                          }).toList();
                        });
                      }
                    },
                  );
                }).toList(),
              ),
            ),
          ],
        ),

      // SEARCHABLE LIST
      Expanded(
        child: ListView.builder(
          itemCount: _foundItems.length,
          itemBuilder: (context, index) {
            return Column(
              children: [
                Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Card(
                      key: ValueKey(_foundItems[index][widget.keys[0]]),
                      elevation: 8,
                      child: ListTile(
                        title: Text(_foundItems[index][widget.keys[0]]),
                        subtitle: Text(
                            '${widget.prependSubtitle ?? ''} ${_getItemsSubtitle(index: index)}'),
                        trailing: widget.trailing ??
                            IconButton(
                              icon: Icon(
                                Icons.arrow_forward_ios,
                                color: Colors.blue[400],
                              ),
                              onPressed: () {
                                if (widget.onSelected != null) {
                                  widget.onSelected!(_foundItems[index]);
                                } else {
                                  Navigator.of(context)
                                      .pop(_foundItems[index][widget.keys[0]]);
                                }
                              },
                            ),
                      ),
                    )),
                SizedBox(height: 10)
              ],
            );
          },
        ),
      )
    ]);
  }
}
