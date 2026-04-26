import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/file_item.dart';
import '../utils/music_logic.dart';
import '../widgets/chord_text.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'dart:typed_data';
import 'package:screenshot/screenshot.dart';
import 'package:image_gallery_saver_plus/image_gallery_saver_plus.dart';
import 'dart:async';

const _bg = Color(0xFFF4F0EA);
const _white = Color(0xFFFFFFFF);
const _sage = Color(0xFF7A9E87);
const _sageDark = Color(0xFF5A7D63);
const _sageLight = Color(0xFFEAF0EB);
const _sageBorder = Color(0xFFC9D8CB);
const _brown = Color(0xFFB5845A);
const _ink = Color(0xFF2C3A2F);
const _muted = Color(0xFFA8B8AA);
const _cardBorder = Color(0xFFE8E0D4);

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

  final ScrollController _scrollController = ScrollController();
  final ScreenshotController _screenshotController = ScreenshotController();
  Timer? _scrollTimer;

  bool _isScrolling = false;
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();

    _currentKey = widget.song.songKey;
    _scrollSpeed = widget.song.scrollSpeed;
    _lyricsController = TextEditingController(text: widget.song.content);
    _isEditing = widget.song.content.trim().isEmpty;

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
        SnackBar(
          content: Text(
            "Song saved!",
            style: GoogleFonts.syne(fontWeight: FontWeight.w600),
          ),
          backgroundColor: _sageDark,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
    }
  }

  bool _updateSongInTree(List<FileItem> items, FileItem targetSong) {
    for (int i = 0; i < items.length; i++) {
      if (!items[i].isFolder && items[i].id == targetSong.id) {
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
      if (!mounted) return;

      if (result['isSuccess']) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              "Saved to Gallery!",
              style: GoogleFonts.syne(fontWeight: FontWeight.w600),
            ),
            backgroundColor: _brown,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }
    }
  }

  void _startAutoScroll() {
    _scrollTimer?.cancel();

    _scrollTimer = Timer.periodic(const Duration(milliseconds: 16), (timer) {
      if (!_isScrolling || !_scrollController.hasClients) {
        timer.cancel();
        return;
      }

      final maxScroll = _scrollController.position.maxScrollExtent;
      final nextOffset = _scrollController.offset + (_scrollSpeed * 0.5);

      if (nextOffset >= maxScroll) {
        _scrollController.jumpTo(maxScroll);
        setState(() {
          _isScrolling = false;
        });
        timer.cancel();
        return;
      }

      _scrollController.jumpTo(nextOffset);
    });
  }

  void _toggleScroll() {
    setState(() => _isScrolling = !_isScrolling);
    if (_isScrolling) {
      _startAutoScroll();
    }
  }

  void _transpose(int semitones) {
    setState(() {
      _lyricsController.text = MusicLogic.transposeSong(
        _lyricsController.text,
        semitones,
        preferFlats: semitones < 0,
      );
      _detectFirstKey();
      widget.song.songKey = _currentKey;
    });
  }

  void _speedDown() {
    setState(() {
      if (_scrollSpeed > 0.5) {
        _scrollSpeed -= 0.1;
      }
      widget.song.scrollSpeed = _scrollSpeed;
    });
  }

  void _speedUp() {
    setState(() {
      _scrollSpeed += 0.1;
      widget.song.scrollSpeed = _scrollSpeed;
    });
  }

  @override
  void dispose() {
    _scrollTimer?.cancel();
    _scrollController.dispose();
    _lyricsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _white,
      body: SafeArea(
        child: Column(
          children: [
            _buildTopBar(),
            Expanded(
              child: Screenshot(
                controller: _screenshotController,
                child: Container(
                  width: double.infinity,
                  color: _white,
                  child: _isEditing ? _buildEditor() : _buildViewer(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    return Container(
      decoration: const BoxDecoration(
        color: _white,
        border: Border(bottom: BorderSide(color: _cardBorder, width: 1)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _TopIconBtn(
              onTap: () => setState(() => _isEditing = !_isEditing),
              color: _sageLight,
              borderColor: _sageBorder,
              child: Icon(
                _isEditing ? Icons.remove_red_eye : Icons.edit_rounded,
                color: _sage,
                size: 19,
              ),
            ),
            const SizedBox(width: 14),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 160),
              child: Text(
                widget.song.name,
                style: GoogleFonts.syne(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: _ink,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 22),

            _SectionLabel('Key'),
            const SizedBox(width: 8),
            _PillControl(
              onMinus: () => _transpose(-1),
              onPlus: () => _transpose(1),
              label: _currentKey,
            ),

            _Divider(),

            _SectionLabel('Speed'),
            const SizedBox(width: 8),
            _PillControl(
              onMinus: _speedDown,
              onPlus: _speedUp,
              label: _scrollSpeed.toStringAsFixed(1),
            ),

            _Divider(),

            _ScrollBtn(isScrolling: _isScrolling, onTap: _toggleScroll),

            _Divider(),

            _TopIconBtn(
              onTap: _manualSave,
              color: Colors.transparent,
              borderColor: _cardBorder,
              child: const Icon(Icons.save_rounded, color: _muted, size: 19),
            ),
            const SizedBox(width: 8),
            _TopIconBtn(
              onTap: _printToGallery,
              color: Colors.transparent,
              borderColor: _cardBorder,
              child: const Icon(Icons.print_rounded, color: _muted, size: 19),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEditor() {
    return TextField(
      controller: _lyricsController,
      scrollController: _scrollController,
      maxLines: null,
      decoration: InputDecoration(
        contentPadding: const EdgeInsets.all(20),
        border: InputBorder.none,
        hintText: "Start writing...",
        hintStyle: GoogleFonts.inter(color: _muted),
      ),
      style: GoogleFonts.inter(fontSize: 18, height: 2.2, color: _ink),
      cursorColor: _sage,
    );
  }

  Widget _buildViewer() {
    return SingleChildScrollView(
      controller: _scrollController,
      padding: const EdgeInsets.all(20),
      child: Align(
        alignment: Alignment.topLeft,
        child: ChordText(text: _lyricsController.text),
      ),
    );
  }
}

class _TopIconBtn extends StatelessWidget {
  final VoidCallback onTap;
  final Color color;
  final Color borderColor;
  final Widget child;

  const _TopIconBtn({
    required this.onTap,
    required this.color,
    required this.borderColor,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: borderColor),
        ),
        child: Center(child: child),
      ),
    );
  }
}

class _PillControl extends StatelessWidget {
  final VoidCallback onMinus;
  final VoidCallback onPlus;
  final String label;

  const _PillControl({
    required this.onMinus,
    required this.onPlus,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 40,
      decoration: BoxDecoration(
        color: _bg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _cardBorder),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _PillBtn(label: '−', onTap: onMinus),
          Container(width: 1, height: 40, color: _cardBorder),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Text(
              label,
              style: GoogleFonts.syne(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: _ink,
              ),
            ),
          ),
          Container(width: 1, height: 40, color: _cardBorder),
          _PillBtn(label: '+', onTap: onPlus),
        ],
      ),
    );
  }
}

class _PillBtn extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _PillBtn({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: 36,
        height: 40,
        child: Center(
          child: Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: _sageDark,
            ),
          ),
        ),
      ),
    );
  }
}

class _ScrollBtn extends StatelessWidget {
  final bool isScrolling;
  final VoidCallback onTap;

  const _ScrollBtn({required this.isScrolling, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        height: 40,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          color: isScrolling ? _sageDark : _sageLight,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: isScrolling ? _sageDark : _sageBorder),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isScrolling
                  ? Icons.stop_rounded
                  : Icons.keyboard_arrow_down_rounded,
              color: isScrolling ? _white : _sageDark,
              size: 18,
            ),
            const SizedBox(width: 5),
            Text(
              isScrolling ? "Stop" : "Scroll",
              style: GoogleFonts.syne(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: isScrolling ? _white : _sageDark,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 24,
      color: _cardBorder,
      margin: const EdgeInsets.symmetric(horizontal: 14),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text.toUpperCase(),
      style: GoogleFonts.syne(
        fontSize: 10,
        fontWeight: FontWeight.w700,
        color: _muted,
        letterSpacing: 1.2,
      ),
    );
  }
}
