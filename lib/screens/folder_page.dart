import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/file_item.dart';
import 'song_sheet_page.dart';

const _bg = Color(0xFFF4F0EA);
const _white = Color(0xFFFFFFFF);
const _sage = Color(0xFF7A9E87);
const _sageDark = Color(0xFF5A7D63);
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

  void _confirmDeleteSong(int index) {
    final itemToDelete = widget.folder.subItems[index];

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: _bg,
        title: Text(
          "Delete Song?",
          style: GoogleFonts.syne(fontWeight: FontWeight.w700, color: _ink),
        ),
        content: Text(
          "Are you sure you want to delete '${itemToDelete.name}'?",
          style: GoogleFonts.inter(color: _inkDeep),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Cancel", style: GoogleFonts.inter(color: _sageDark)),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                widget.folder.subItems.removeAt(index);
              });
              Navigator.pop(context);
            },
            child: Text("Delete", style: GoogleFonts.inter(color: Colors.red)),
          ),
        ],
      ),
    );
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
                    childAspectRatio: 2.5,
                  ),
                  delegate: SliverChildBuilderDelegate((context, index) {
                    final song = widget.folder.subItems[index];

                    return _GridSongCard(
                      song: song,
                      onTap: () => _openSong(song),
                      onLongPress: () => _confirmDeleteSong(index),
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
