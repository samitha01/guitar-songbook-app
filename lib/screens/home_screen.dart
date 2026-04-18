import 'package:flutter/material.dart';
import '../models/file_item.dart';
import 'folder_page.dart';
import 'song_sheet_page.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<FileItem> _myItems = []; // Master List
  List<FileItem> _filteredItems = []; // What the user actually sees

  final TextEditingController _nameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  // FIXED: Search now looks at everything in the master list
  void _runSearch(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredItems = _myItems;
      } else {
        _filteredItems = _myItems
            .where(
              (item) => item.name.toLowerCase().contains(query.toLowerCase()),
            )
            .toList();
      }
    });
  }

  Future<void> _saveData() async {
    final prefs = await SharedPreferences.getInstance();
    String jsonString = jsonEncode(
      _myItems.map((item) => item.toJson()).toList(),
    );
    await prefs.setString('guitar_library', jsonString);
  }

  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();
    String? jsonString = prefs.getString('guitar_library');
    if (jsonString != null) {
      Iterable l = jsonDecode(jsonString);
      setState(() {
        _myItems = List<FileItem>.from(
          l.map((model) => FileItem.fromJson(model)),
        );
        _filteredItems = _myItems;
      });
    } else {
      setState(() {
        _myItems = [
          FileItem(name: "Sinhala Songs", isFolder: true),
          FileItem(name: "English Songs", isFolder: true),
        ];
        _filteredItems = _myItems;
      });
    }
  }

  // FIXED: Now works for both Folders and Files
  void _confirmDelete(int index) {
    final itemToDelete = _filteredItems[index];

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Delete Item?"),
        content: Text(
          "Are you sure you want to delete '${itemToDelete.name}'?",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                _myItems.remove(itemToDelete);
                _filteredItems = _myItems; // Reset search view after delete
              });
              _saveData();
              Navigator.pop(context);
            },
            child: const Text("Delete", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _showCreateDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Add New Item"),
          content: TextField(
            controller: _nameController,
            decoration: const InputDecoration(hintText: "Enter name"),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () {
                if (_nameController.text.isNotEmpty) {
                  setState(() {
                    _myItems.add(
                      FileItem(name: _nameController.text, isFolder: true),
                    );
                    _filteredItems = _myItems;
                  });
                  _saveData();
                  _nameController.clear();
                  Navigator.pop(context);
                }
              },
              child: const Text("Folder"),
            ),
            ElevatedButton(
              onPressed: () {
                if (_nameController.text.isNotEmpty) {
                  setState(() {
                    _myItems.add(
                      FileItem(name: _nameController.text, isFolder: false),
                    );
                    _filteredItems = _myItems;
                  });
                  _saveData();
                  _nameController.clear();
                  Navigator.pop(context);
                }
              },
              child: const Text("Song File"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              onChanged: (value) => _runSearch(value),
              decoration: InputDecoration(
                hintText: 'Search songs or folders...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),
          // FIXED: Changed GridView to ListView for better readability
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _filteredItems.length,
              separatorBuilder: (context, index) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final item = _filteredItems[index];
                return ListTile(
                  leading: Icon(
                    item.isFolder ? Icons.folder : Icons.description,
                    color: item.isFolder ? Colors.amber : Colors.blueGrey,
                    size: 30,
                  ),
                  title: Text(
                    item.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 16,
                    ),
                  ),
                  subtitle: Text(item.isFolder ? "Folder" : "Song File"),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    if (item.isFolder) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              FolderContentsPage(folder: item),
                        ),
                      ).then((_) => _saveData());
                    } else {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => SongSheetPage(song: item),
                        ),
                      ).then((_) => _saveData());
                    }
                  },
                  onLongPress: () => _confirmDelete(index),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showCreateDialog,
        child: const Icon(Icons.add),
      ),
    );
  }
}
