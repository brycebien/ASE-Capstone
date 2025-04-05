import 'package:flutter/material.dart';

class SearchableList extends StatefulWidget {
  final List<Map<String, dynamic>> items;
  final List<String> keys;
  final Widget? trailing;
  final String? prependSubtitle;
  final Function? onSelected;
  const SearchableList({
    super.key,
    required this.items,
    required this.keys,
    this.trailing,
    this.prependSubtitle,
    this.onSelected,
  });

  @override
  State<SearchableList> createState() => _SearchableListState();
}

class _SearchableListState extends State<SearchableList> {
  List _foundItems = [];
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    setState(() {
      _foundItems = widget.items;
    });
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
          decoration: const InputDecoration(
            labelText: 'Search',
            suffixIcon: Icon(Icons.search),
          ),
          onChanged: (value) {
            _searchList(value);
          },
        ),
      ),
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
