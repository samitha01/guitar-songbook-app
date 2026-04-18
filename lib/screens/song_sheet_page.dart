import 'package:flutter/material.dart';
import '../models/file_item.dart';
import '../utils/music_logic.dart';
import '../widgets/chord_text.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'dart:typed_data';
import 'package:screenshot/screenshot.dart';
import 'package:image_gallery_saver_plus/image_gallery_saver_plus.dart';

class SongSheetPage extends StatefulWidget {
  final FileItem song;
  const SongSheetPage({super.key, required this.song});

  @override
  State<SongSheetPage> createState() => _SongSheetPageState();
}

class _SongSheetPageState extends State<SongSheetPage> {
  late String _currentKey;
  late double _scrollSpeed;
  late TextEditingController _lyricsController;

  final TextEditingController _customChordController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final ScreenshotController _screenshotController = ScreenshotController();

  bool _isScrolling = false;
  bool _isEditing = true;

  @override
  void initState() {
    super.initState();

    _currentKey = widget.song.songKey;
    _scrollSpeed = widget.song.scrollSpeed;
    _lyricsController = TextEditingController(text: widget.song.content);

    _detectFirstKey();

    _lyricsController.addListener(() {
      widget.song.content = _lyricsController.text;
      _detectFirstKey();
    });
  }

  void _detectFirstKey() {
    final text = _lyricsController.text;
    final RegExp regExp = RegExp(r'\[(.*?)\]');
    final match = regExp.firstMatch(text);

    if (match != null) {
      String firstChord = match.group(1) ?? "C";

      String rootKey;
      if (firstChord.length > 1 &&
          (firstChord[1] == '#' || firstChord[1] == 'b')) {
        rootKey = firstChord.substring(0, 2);
      } else {
        rootKey = firstChord.substring(0, 1);
      }

      if (rootKey.isNotEmpty && rootKey != _currentKey) {
        setState(() {
          _currentKey = rootKey;
          widget.song.songKey = rootKey;
        });
      }
    }
  }

  Future<void> _manualSave() async {
    widget.song.content = _lyricsController.text;
    widget.song.scrollSpeed = _scrollSpeed;
    widget.song.songKey = _currentKey;

    final prefs = await SharedPreferences.getInstance();
    String? jsonString = prefs.getString('guitar_library');

    if (jsonString != null) {
      List<dynamic> libraryJson = jsonDecode(jsonString);
      List<FileItem> library = libraryJson
          .map((item) => FileItem.fromJson(item))
          .toList();

      bool updated = _updateSongInTree(library, widget.song);

      if (updated) {
        String updatedJson = jsonEncode(
          library.map((e) => e.toJson()).toList(),
        );
        await prefs.setString('guitar_library', updatedJson);
      }
    }

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Song saved!"),
          backgroundColor: Colors.brown,
        ),
      );
    }
  }

  bool _updateSongInTree(List<FileItem> items, FileItem targetSong) {
    for (int i = 0; i < items.length; i++) {
      if (!items[i].isFolder && items[i].name == targetSong.name) {
        items[i].content = targetSong.content;
        items[i].scrollSpeed = targetSong.scrollSpeed;
        items[i].songKey = targetSong.songKey;
        return true;
      }

      if (items[i].isFolder && items[i].subItems.isNotEmpty) {
        bool found = _updateSongInTree(items[i].subItems, targetSong);
        if (found) return true;
      }
    }
    return false;
  }

  Future<void> _printToGallery() async {
    final Uint8List? image = await _screenshotController.capture();
    if (image != null) {
      final result = await ImageGallerySaverPlus.saveImage(image);
      if (result['isSuccess']) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Saved to Gallery!"),
            backgroundColor: Colors.blue,
          ),
        );
      }
    }
  }

  void _startAutoScroll() async {
    while (_isScrolling && _scrollController.hasClients) {
      await Future.delayed(const Duration(milliseconds: 80));

      if (!_scrollController.hasClients) return;

      final maxScroll = _scrollController.position.maxScrollExtent;
      final nextOffset = _scrollController.offset + _scrollSpeed;

      if (nextOffset >= maxScroll) {
        setState(() {
          _isScrolling = false;
        });
        return;
      }

      _scrollController.jumpTo(nextOffset);
    }
  }

  void _showCustomChordDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Insert Chord"),
        content: TextField(
          controller: _customChordController,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: "e.g. Asus2, Cadd9, F#m7",
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              _customChordController.clear();
              Navigator.pop(context);
            },
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () {
              final chord = _customChordController.text.trim();
              if (chord.isNotEmpty) {
                _insertChord(chord);
                _customChordController.clear();
                Navigator.pop(context);
              }
            },
            child: const Text("Insert"),
          ),
        ],
      ),
    );
  }

  void _insertChord(String chord) {
    final text = _lyricsController.text;
    final selection = _lyricsController.selection;

    int start = selection.start >= 0 ? selection.start : text.length;
    int end = selection.end >= 0 ? selection.end : text.length;

    final newText = text.replaceRange(start, end, "[$chord]");

    setState(() {
      _lyricsController.text = newText;
      _lyricsController.selection = TextSelection.collapsed(
        offset: start + chord.length + 2,
      );
      _detectFirstKey();
    });
  }

  void _transpose(int semitones) {
    setState(() {
      _lyricsController.text = MusicLogic.transposeSong(
        _lyricsController.text,
        semitones,
      );
      _detectFirstKey();
      widget.song.songKey = _currentKey;
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _lyricsController.dispose();
    _customChordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.song.name),
        leading: IconButton(
          icon: Icon(_isEditing ? Icons.remove_red_eye : Icons.edit),
          onPressed: () => setState(() => _isEditing = !_isEditing),
        ),
        actions: [
          IconButton(
            onPressed: _manualSave,
            icon: const Icon(Icons.save, color: Colors.brown),
          ),
          IconButton(onPressed: _printToGallery, icon: const Icon(Icons.print)),
        ],
      ),
      body: Column(
        children: [
          Container(
            color: Colors.grey[200],
            padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
            child: Wrap(
              alignment: WrapAlignment.spaceEvenly,
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 4,
              runSpacing: 4,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.remove_circle_outline),
                      onPressed: () => _transpose(-1),
                    ),
                    Text(
                      _currentKey,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.add_circle_outline),
                      onPressed: () => _transpose(1),
                    ),
                  ],
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.remove),
                      onPressed: () => setState(() {
                        if (_scrollSpeed > 0.5) {
                          _scrollSpeed -= 0.1;
                        }
                        widget.song.scrollSpeed = _scrollSpeed;
                      }),
                    ),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text("Speed", style: TextStyle(fontSize: 10)),
                        Text(
                          _scrollSpeed.toStringAsFixed(1),
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    IconButton(
                      icon: const Icon(Icons.add),
                      onPressed: () => setState(() {
                        _scrollSpeed += 0.1;
                        widget.song.scrollSpeed = _scrollSpeed;
                      }),
                    ),
                  ],
                ),
                ElevatedButton(
                  onPressed: _showCustomChordDialog,
                  child: const Text("Chord"),
                ),
                ActionChip(
                  avatar: Icon(
                    _isScrolling ? Icons.stop : Icons.arrow_downward,
                    size: 16,
                    color: _isScrolling ? Colors.red : null,
                  ),
                  label: Text(_isScrolling ? "Stop" : "Scroll"),
                  onPressed: () {
                    setState(() => _isScrolling = !_isScrolling);
                    if (_isScrolling) {
                      _startAutoScroll();
                    }
                  },
                ),
              ],
            ),
          ),
          Expanded(
            child: Screenshot(
              controller: _screenshotController,
              child: Container(
                width: double.infinity,
                color: Colors.white,
                child: _isEditing
                    ? TextField(
                        controller: _lyricsController,
                        scrollController: _scrollController,
                        maxLines: null,
                        decoration: const InputDecoration(
                          contentPadding: EdgeInsets.all(16),
                          border: InputBorder.none,
                          hintText: "Start writing...",
                        ),
                        style: const TextStyle(fontSize: 18, height: 2.2),
                      )
                    : SingleChildScrollView(
                        controller: _scrollController,
                        padding: const EdgeInsets.all(16.0),
                        child: Align(
                          alignment: Alignment.topLeft,
                          child: ChordText(text: _lyricsController.text),
                        ),
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
