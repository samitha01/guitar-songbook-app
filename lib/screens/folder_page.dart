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

class _FolderContentsPageState extends State<FolderContentsPage>
    with SingleTickerProviderStateMixin {
  final TextEditingController _fileController = TextEditingController();
  final TextEditingController _renameController = TextEditingController();

  bool _fabOpen = false;
  late final AnimationController _fabAnim;
  late final Animation<double> _fabRotation;

  @override
  void initState() {
    super.initState();

    _fabAnim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 220),
    );

    _fabRotation = Tween<double>(
      begin: 0,
      end: 0.125,
    ).animate(CurvedAnimation(parent: _fabAnim, curve: Curves.easeInOut));
  }

  void _toggleFab() {
    setState(() => _fabOpen = !_fabOpen);
    _fabOpen ? _fabAnim.forward() : _fabAnim.reverse();
  }

  void _closeFab() {
    if (_fabOpen) {
      setState(() => _fabOpen = false);
      _fabAnim.reverse();
    }
  }

  void _showItemOptions(int index) {
    final item = widget.folder.subItems[index];

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
                      color: item.isFolder ? _sageLight : _brownLight,
                      borderRadius: BorderRadius.circular(13),
                      border: Border.all(
                        color: item.isFolder ? _sageBorder : _brownBorder,
                      ),
                    ),
                    child: Icon(
                      item.isFolder
                          ? Icons.folder_rounded
                          : Icons.description_rounded,
                      color: item.isFolder ? _sage : _brown,
                      size: 21,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      item.name,
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
                  _showRenameDialog(item);
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
                  _confirmDeleteItem(item);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showRenameDialog(FileItem item) {
    _renameController.text = item.name;

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
                  item.name = newName;
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

  void _confirmDeleteItem(FileItem item) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: _bg,
        title: Text(
          item.isFolder ? "Delete Folder?" : "Delete Song?",
          style: GoogleFonts.syne(fontWeight: FontWeight.w700, color: _ink),
        ),
        content: Text(
          "Are you sure you want to delete '${item.name}'?",
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
              _deleteItem(item);
            },
            child: Text("Delete", style: GoogleFonts.inter(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _deleteItem(FileItem item) {
    setState(() {
      widget.folder.subItems.remove(item);
    });
  }

  void _createItem({required bool isFolder}) {
    if (_fileController.text.trim().isNotEmpty) {
      setState(() {
        widget.folder.subItems.add(
          FileItem(name: _fileController.text.trim(), isFolder: isFolder),
        );
      });

      _fileController.clear();
      Navigator.pop(context);
    }
  }

  void _showCreateDialog({required bool isFolder}) {
    _fileController.clear();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: _bg,
        title: Text(
          isFolder ? "New Folder" : "New Sheet File",
          style: GoogleFonts.syne(fontWeight: FontWeight.w700, color: _ink),
        ),
        content: TextField(
          controller: _fileController,
          cursorColor: _sage,
          decoration: InputDecoration(
            hintText: isFolder ? "Folder name" : "Song name",
            hintStyle: GoogleFonts.inter(color: _muted),
            filled: true,
            fillColor: _white,
            prefixIcon: Icon(
              isFolder ? Icons.folder_rounded : Icons.description_rounded,
              color: isFolder ? _sage : _brown,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: _cardBorder),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(
                color: isFolder ? _sage : _brown,
                width: 1.5,
              ),
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
              backgroundColor: isFolder ? _sageDark : _brown,
              foregroundColor: _white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            onPressed: () => _createItem(isFolder: isFolder),
            child: Text(
              "Create",
              style: GoogleFonts.inter(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  void _openItem(FileItem item) {
    if (item.isFolder) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => FolderContentsPage(folder: item),
        ),
      ).then((_) => setState(() {}));
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => SongSheetPage(song: item)),
      ).then((_) => setState(() {}));
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _closeFab,
      child: Scaffold(
        backgroundColor: _bg,
        body: SafeArea(
          child: Stack(
            children: [
              CustomScrollView(
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
                        gridDelegate:
                            const SliverGridDelegateWithMaxCrossAxisExtent(
                              maxCrossAxisExtent: 250,
                              crossAxisSpacing: 10,
                              mainAxisSpacing: 10,
                              mainAxisExtent: 115,
                            ),
                        delegate: SliverChildBuilderDelegate((context, index) {
                          final item = widget.folder.subItems[index];

                          return _GridItemCard(
                            item: item,
                            onTap: () => _openItem(item),
                            onLongPress: () => _showItemOptions(index),
                          );
                        }, childCount: widget.folder.subItems.length),
                      ),
                    ),
                ],
              ),
              _buildFabMenu(),
            ],
          ),
        ),
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
        'C O N T E N T S',
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
        "This folder is empty.\nTap + to add a folder or song.",
        textAlign: TextAlign.center,
        style: GoogleFonts.inter(color: _muted, fontSize: 14, height: 1.5),
      ),
    );
  }

  Widget _buildFabMenu() {
    return Positioned(
      right: 24,
      bottom: 28,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedSlide(
            offset: _fabOpen ? Offset.zero : const Offset(0, 0.3),
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOut,
            child: AnimatedOpacity(
              opacity: _fabOpen ? 1 : 0,
              duration: const Duration(milliseconds: 180),
              child: IgnorePointer(
                ignoring: !_fabOpen,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    _PopButton(
                      label: 'New sheet file',
                      isFile: true,
                      onTap: () {
                        _closeFab();
                        _showCreateDialog(isFolder: false);
                      },
                    ),
                    const SizedBox(height: 8),
                    _PopButton(
                      label: 'New folder',
                      isFile: false,
                      onTap: () {
                        _closeFab();
                        _showCreateDialog(isFolder: true);
                      },
                    ),
                    const SizedBox(height: 12),
                  ],
                ),
              ),
            ),
          ),
          GestureDetector(
            onTap: _toggleFab,
            child: AnimatedBuilder(
              animation: _fabRotation,
              builder: (context, child) => Transform.rotate(
                angle: _fabRotation.value * 2 * 3.14159,
                child: child,
              ),
              child: Container(
                width: 58,
                height: 58,
                decoration: BoxDecoration(
                  color: _sageDark,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: _sageDark.withOpacity(0.28),
                      blurRadius: 16,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Icon(Icons.add, color: _white, size: 26),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _fabAnim.dispose();
    _fileController.dispose();
    _renameController.dispose();
    super.dispose();
  }
}

class _GridItemCard extends StatelessWidget {
  final FileItem item;
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  const _GridItemCard({
    required this.item,
    required this.onTap,
    required this.onLongPress,
  });

  bool get isFolder => item.isFolder;

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
                decoration: BoxDecoration(
                  color: isFolder ? _sage : _brown,
                  borderRadius: const BorderRadius.only(
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
                        color: isFolder ? _sageLight : _brownLight,
                        borderRadius: BorderRadius.circular(11),
                        border: Border.all(
                          color: isFolder ? _sageBorder : _brownBorder,
                        ),
                      ),
                      child: Icon(
                        isFolder
                            ? Icons.folder_rounded
                            : Icons.description_rounded,
                        color: isFolder ? _sage : _brown,
                        size: 20,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      item.name,
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

class _PopButton extends StatelessWidget {
  final String label;
  final bool isFile;
  final VoidCallback onTap;

  const _PopButton({
    required this.label,
    required this.isFile,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: _white,
          borderRadius: BorderRadius.circular(13),
          border: Border.all(color: _cardBorder, width: 1.5),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: isFile ? _brownLight : _sageLight,
                borderRadius: BorderRadius.circular(9),
              ),
              child: Icon(
                isFile ? Icons.description_rounded : Icons.folder_rounded,
                color: isFile ? _brown : _sage,
                size: 15,
              ),
            ),
            const SizedBox(width: 9),
            Text(
              label,
              style: GoogleFonts.syne(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: _ink,
              ),
            ),
          ],
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
