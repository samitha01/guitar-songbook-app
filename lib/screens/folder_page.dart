import 'package:flutter/material.dart';
import '../models/file_item.dart';
import 'song_sheet_page.dart';

class FolderContentsPage extends StatefulWidget {
  final FileItem folder;
  const FolderContentsPage({super.key, required this.folder});

  @override
  State<FolderContentsPage> createState() => _FolderContentsPageState();
}

class _FolderContentsPageState extends State<FolderContentsPage> {
  final TextEditingController _fileController = TextEditingController();

  void _confirmDeleteSong(int index) {
    final itemToDelete = widget.folder.subItems[index];

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Delete Song?"),
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
                widget.folder.subItems.removeAt(index);
              });
              Navigator.pop(context);
            },
            child: const Text("Delete", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _addNewFile() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Add New Song"),
        content: TextField(
          controller: _fileController,
          decoration: const InputDecoration(hintText: "Song Name"),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () {
              if (_fileController.text.isNotEmpty) {
                setState(() {
                  widget.folder.subItems.add(
                    FileItem(name: _fileController.text, isFolder: false),
                  );
                });
                _fileController.clear();
                Navigator.pop(context);
              }
            },
            child: const Text("Add Song"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.folder.name)),
      body: widget.folder.subItems.isEmpty
          ? const Center(child: Text("This folder is empty. Add a song!"))
          : ListView.separated(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: widget.folder.subItems.length,
              separatorBuilder: (context, index) => const Divider(),
              itemBuilder: (context, index) {
                final song = widget.folder.subItems[index];
                return ListTile(
                  leading: const Icon(
                    Icons.description,
                    color: Colors.blueGrey,
                    size: 30,
                  ),
                  title: Text(
                    song.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 16,
                    ),
                  ),
                  subtitle: const Text("Song File"),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => SongSheetPage(song: song),
                      ),
                    );
                  },
                  onLongPress: () => _confirmDeleteSong(index),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addNewFile,
        child: const Icon(Icons.note_add),
      ),
    );
  }

  @override
  void dispose() {
    _fileController.dispose();
    super.dispose();
  }
}
