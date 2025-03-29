import 'package:flutter/material.dart';

class SearchableList extends StatefulWidget {
  final List<Map<String, dynamic>> items;
  final String listTitle;
  const SearchableList(
      {super.key, required this.items, required this.listTitle});

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
        final name = item['name'].toLowerCase();
        final abbreviation = item['abbreviation'].toLowerCase();
        final searchLower = query.toLowerCase();
        return name.contains(searchLower) || abbreviation.contains(searchLower);
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.listTitle),
      ),
      body: Column(
        children: [
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
                        key: ValueKey(_foundItems[index]['name']),
                        elevation: 8,
                        child: ListTile(
                          title: Text(_foundItems[index]['name']),
                          subtitle: Text(_foundItems[index]['abbreviation']),
                          trailing: IconButton(
                            icon: Icon(Icons.done),
                            onPressed: () {
                              Navigator.of(context)
                                  .pop(_foundItems[index]['name']);
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
    );
  }
}
