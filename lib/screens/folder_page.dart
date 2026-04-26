import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/file_item.dart';
import 'song_sheet_page.dart';

const _bg = Color(0xFFF4F0EA);
const _white = Color(0xFFFFFFFF);
const _sage = Color(0xFF7A9E87);
const _sageDark = Color(0xFF5A7D63);
const _sageLight = Color(0xFFEAF0EB);
const _sageBorder = Color(0xFFC9D8CB);
const _brown = Color(0xFFB5845A);
const _brownLight = Color(0xFFF5EDE4);
const _brownBorder = Color(0xFFDFC9B0);
const _ink = Color(0xFF2C3A2F);
const _inkDeep = Color(0xFF3B4F3E);
const _muted = Color(0xFFA8B8AA);
const _cardBorder = Color(0xFFE8E0D4);

class FolderContentsPage extends StatefulWidget {
  final FileItem folder;
  const FolderContentsPage({super.key, required this.folder});

  @override
  State<FolderContentsPage> createState() => _FolderContentsPageState();
}

class _FolderContentsPageState extends State<FolderContentsPage> {
  final TextEditingController _fileController = TextEditingController();
  final TextEditingController _renameController = TextEditingController();

  void _showSongOptions(int index) {
    final song = widget.folder.subItems[index];

    showModalBottomSheet(
      context: context,
      backgroundColor: _bg,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 44,
                height: 5,
                decoration: BoxDecoration(
                  color: _cardBorder,
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              const SizedBox(height: 18),
              Row(
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: _brownLight,
                      borderRadius: BorderRadius.circular(13),
                      border: Border.all(color: _brownBorder),
                    ),
                    child: const Icon(
                      Icons.description_rounded,
                      color: _brown,
                      size: 21,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      song.name,
                      style: GoogleFonts.syne(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        color: _ink,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              _OptionTile(
                icon: Icons.edit_rounded,
                title: "Rename",
                color: _brown,
                backgroundColor: _brownLight,
                onTap: () {
                  Navigator.pop(context);
                  _showRenameDialog(song);
                },
              ),
              const SizedBox(height: 10),
              _OptionTile(
                icon: Icons.delete_rounded,
                title: "Delete",
                color: Colors.red,
                backgroundColor: Colors.red.withOpacity(0.08),
                onTap: () {
                  Navigator.pop(context);
                  _confirmDeleteSong(song);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showRenameDialog(FileItem song) {
    _renameController.text = song.name;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: _bg,
        title: Text(
          "Rename",
          style: GoogleFonts.syne(fontWeight: FontWeight.w700, color: _ink),
        ),
        content: TextField(
          controller: _renameController,
          autofocus: true,
          cursorColor: _sage,
          decoration: InputDecoration(
            hintText: "New name",
            hintStyle: GoogleFonts.inter(color: _muted),
            filled: true,
            fillColor: _white,
            prefixIcon: const Icon(Icons.edit_rounded, color: _brown),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: _cardBorder),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: _brown, width: 1.5),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              _renameController.clear();
              Navigator.pop(context);
            },
            child: Text("Cancel", style: GoogleFonts.inter(color: _muted)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: _brown,
              foregroundColor: _white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            onPressed: () {
              final newName = _renameController.text.trim();

              if (newName.isNotEmpty) {
                setState(() {
                  song.name = newName;
                });

                _renameController.clear();
                Navigator.pop(context);
              }
            },
            child: Text(
              "Save",
              style: GoogleFonts.inter(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  void _confirmDeleteSong(FileItem song) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: _bg,
        title: Text(
          "Delete Song?",
          style: GoogleFonts.syne(fontWeight: FontWeight.w700, color: _ink),
        ),
        content: Text(
          "Are you sure you want to delete '${song.name}'?",
          style: GoogleFonts.inter(color: _inkDeep),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Cancel", style: GoogleFonts.inter(color: _sageDark)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteSong(song);
            },
            child: Text("Delete", style: GoogleFonts.inter(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _deleteSong(FileItem song) {
    setState(() {
      widget.folder.subItems.remove(song);
    });
  }

  void _addNewFile() {
    _fileController.clear();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: _bg,
        title: Text(
          "New Sheet File",
          style: GoogleFonts.syne(fontWeight: FontWeight.w700, color: _ink),
        ),
        content: TextField(
          controller: _fileController,
          cursorColor: _sage,
          decoration: InputDecoration(
            hintText: "Song name",
            hintStyle: GoogleFonts.inter(color: _muted),
            filled: true,
            fillColor: _white,
            prefixIcon: const Icon(Icons.description_rounded, color: _brown),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: _cardBorder),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: _brown, width: 1.5),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              _fileController.clear();
              Navigator.pop(context);
            },
            child: Text("Cancel", style: GoogleFonts.inter(color: _muted)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: _brown,
              foregroundColor: _white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            onPressed: () {
              if (_fileController.text.trim().isNotEmpty) {
                setState(() {
                  widget.folder.subItems.add(
                    FileItem(
                      name: _fileController.text.trim(),
                      isFolder: false,
                    ),
                  );
                });
                _fileController.clear();
                Navigator.pop(context);
              }
            },
            child: Text(
              "Create",
              style: GoogleFonts.inter(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  void _openSong(FileItem song) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => SongSheetPage(song: song)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(child: _buildHeader(context)),
            SliverToBoxAdapter(child: _buildSectionLabel()),
            if (widget.folder.subItems.isEmpty)
              SliverFillRemaining(
                hasScrollBody: false,
                child: _buildEmptyState(),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 110),
                sliver: SliverGrid(
                  gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent: 250,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                    mainAxisExtent: 115,
                  ),
                  delegate: SliverChildBuilderDelegate((context, index) {
                    final song = widget.folder.subItems[index];

                    return _GridSongCard(
                      song: song,
                      onTap: () => _openSong(song),
                      onLongPress: () => _showSongOptions(index),
                    );
                  }, childCount: widget.folder.subItems.length),
                ),
              ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: _sageDark,
        onPressed: _addNewFile,
        child: const Icon(Icons.note_add_rounded, color: _white),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 16, 24, 18),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back_rounded, color: _inkDeep),
          ),
          Expanded(
            child: Text(
              widget.folder.name,
              style: GoogleFonts.syne(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: _inkDeep,
                letterSpacing: -0.5,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionLabel() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 12),
      child: Text(
        'S H E E T S',
        style: GoogleFonts.syne(
          fontSize: 10.5,
          fontWeight: FontWeight.w700,
          letterSpacing: 2.5,
          color: _muted,
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Text(
        "This folder is empty.\nTap + to add a song.",
        textAlign: TextAlign.center,
        style: GoogleFonts.inter(color: _muted, fontSize: 14, height: 1.5),
      ),
    );
  }

  @override
  void dispose() {
    _fileController.dispose();
    _renameController.dispose();
    super.dispose();
  }
}

class _GridSongCard extends StatelessWidget {
  final FileItem song;
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  const _GridSongCard({
    required this.song,
    required this.onTap,
    required this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        onLongPress: onLongPress,
        borderRadius: BorderRadius.circular(16),
        child: Ink(
          decoration: BoxDecoration(
            color: _white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: _cardBorder, width: 1.5),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 4,
                decoration: const BoxDecoration(
                  color: _brown,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(15),
                    topRight: Radius.circular(15),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 12, 12, 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        color: _brownLight,
                        borderRadius: BorderRadius.circular(11),
                        border: Border.all(color: _brownBorder),
                      ),
                      child: const Icon(
                        Icons.description_rounded,
                        color: _brown,
                        size: 20,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      song.name,
                      style: GoogleFonts.syne(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: _ink,
                        height: 1.3,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _OptionTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final Color color;
  final Color backgroundColor;
  final VoidCallback onTap;

  const _OptionTile({
    required this.icon,
    required this.title,
    required this.color,
    required this.backgroundColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: _white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: _cardBorder),
          ),
          child: Row(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: backgroundColor,
                  borderRadius: BorderRadius.circular(11),
                ),
                child: Icon(icon, color: color, size: 18),
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: GoogleFonts.syne(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: _ink,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
