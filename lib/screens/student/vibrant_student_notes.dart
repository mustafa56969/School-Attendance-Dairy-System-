import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import 'dart:convert';
import '../../theme/playful_theme.dart';

class VibrantStudentNotes extends StatefulWidget {
  const VibrantStudentNotes({super.key});

  @override
  State<VibrantStudentNotes> createState() => _VibrantStudentNotesState();
}

class _VibrantStudentNotesState extends State<VibrantStudentNotes> {
  List<NoteModel> _notes = [];
  bool _isLoading = true;
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isScrolled = false;

  // 12 vibrant color palettes matching the HTML
  final List<NoteColor> _colorPalettes = [
    NoteColor(background: Color(0xFFFEF08A), text: Color(0xFF713F12)), // Yellow
    NoteColor(background: Color(0xFFFED7AA), text: Color(0xFF7C2D12)), // Orange
    NoteColor(background: Color(0xFFBBF7D0), text: Color(0xFF064E3B)), // Green
    NoteColor(background: Color(0xFFBAE6FD), text: Color(0xFF0C4A6E)), // Sky
    NoteColor(background: Color(0xFFE9D5FF), text: Color(0xFF581C87)), // Purple
    NoteColor(background: Color(0xFFFECACA), text: Color(0xFF7F1D1D)), // Red
    NoteColor(background: Color(0xFFDDD6FE), text: Color(0xFF4C1D95)), // Violet
    NoteColor(background: Color(0xFFF5D0FE), text: Color(0xFF701A75)), // Fuchsia
    NoteColor(background: Color(0xFF99F6E4), text: Color(0xFF134E4A)), // Teal
    NoteColor(background: Color(0xFFD9F99D), text: Color(0xFF365314)), // Lime
    NoteColor(background: Color(0xFFFBCFE8), text: Color(0xFF831843)), // Pink
    NoteColor(background: Color(0xFFE2E8F0), text: Color(0xFF1E293B)), // Slate
  ];

  @override
  void initState() {
    super.initState();
    _loadNotes();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.offset > 10 && !_isScrolled) {
      setState(() => _isScrolled = true);
    } else if (_scrollController.offset <= 10 && _isScrolled) {
      setState(() => _isScrolled = false);
    }
  }

  Future<void> _loadNotes() async {
    final prefs = await SharedPreferences.getInstance();
    final notesJson = prefs.getString('vibrant_notes_v2') ?? '[]';
    final List<dynamic> notesList = json.decode(notesJson);

    setState(() {
      _notes = notesList.map((json) => NoteModel.fromJson(json)).toList();
      _notes.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
      _isLoading = false;
    });
  }

  Future<void> _saveNotes() async {
    final prefs = await SharedPreferences.getInstance();
    final notesJson = json.encode(_notes.map((note) => note.toJson()).toList());
    await prefs.setString('vibrant_notes_v2', notesJson);
  }

  void _deleteNote(String id) {
    setState(() {
      _notes.removeWhere((note) => note.id == id);
    });
    _saveNotes();
  }

  void _openEditor({NoteModel? note}) {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => _NoteEditorScreen(
          note: note,
          colorPalettes: _colorPalettes,
          onSave: (NoteModel savedNote) {
            setState(() {
              if (note == null) {
                _notes.insert(0, savedNote);
              } else {
                final index = _notes.indexWhere((n) => n.id == savedNote.id);
                if (index != -1) {
                  _notes[index] = savedNote;
                }
              }
            });
            _saveNotes();
          },
          onDelete: (String id) {
            _deleteNote(id);
          },
        ),
        transitionDuration: Duration(milliseconds: 300),
        reverseTransitionDuration: Duration(milliseconds: 250),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          var fadeAnimation = Tween(begin: 0.0, end: 1.0).animate(
            CurvedAnimation(parent: animation, curve: Curves.easeOut),
          );
          var slideAnimation = Tween(begin: Offset(0, 0.03), end: Offset.zero).animate(
            CurvedAnimation(parent: animation, curve: Curves.easeOut),
          );

          return FadeTransition(
            opacity: fadeAnimation,
            child: SlideTransition(
              position: slideAnimation,
              child: child,
            ),
          );
        },
      ),
    );
  }

  List<NoteModel> get _filteredNotes {
    if (_searchQuery.isEmpty) return _notes;
    return _notes.where((note) {
      return note.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          note.content.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final filteredNotes = _filteredNotes;
    final isWide = MediaQuery.of(context).size.width > 600;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: CustomScrollView(
        controller: _scrollController,
        physics: BouncingScrollPhysics(),
        slivers: [
          // Compact Fixed Header
          SliverAppBar(
            pinned: true,
            floating: false,
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            surfaceTintColor: Colors.transparent,
            elevation: _isScrolled ? 0 : 0,
            toolbarHeight: 70,
            automaticallyImplyLeading: false,
            flexibleSpace: Container(
              decoration: BoxDecoration(
                color: Theme.of(context).scaffoldBackgroundColor,
                border: _isScrolled
                    ? Border(
                        bottom: BorderSide(
                          color: Theme.of(context).dividerColor.withOpacity(0.1),
                          width: 1,
                        ),
                      )
                    : null,
              ),
              child: SafeArea(
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: isWide ? 24 : 20,
                    vertical: 12,
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [PlayfulTheme.primaryDark, PlayfulTheme.primaryTeal],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(14),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 8,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Icon(
                          Icons.note_alt_rounded,
                          color: Colors.white,
                          size: 22,
                        ),
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'My Notes',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w800,
                                color: Theme.of(context).colorScheme.onBackground,
                                height: 1.2,
                                letterSpacing: -0.5,
                              ),
                            ),
                            Text(
                              '${filteredNotes.length} ${filteredNotes.length == 1 ? 'note' : 'notes'}',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                color: Theme.of(context).textTheme.bodySmall?.color,
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Search Icon
                      Container(
                        padding: EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Theme.of(context).cardColor,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Theme.of(context).dividerColor.withOpacity(0.1)),
                        ),
                        child: Icon(
                          Icons.search,
                          color: Color(0xFF64748B),
                          size: 20,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Search Bar
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(
                isWide ? 24 : 20,
                16,
                isWide ? 24 : 20,
                16,
              ),
              child: Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Theme.of(context).dividerColor.withOpacity(0.1)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.03),
                      blurRadius: 8,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: TextField(
                  controller: _searchController,
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value;
                    });
                  },
                  decoration: InputDecoration(
                    hintText: 'Search notes...',
                    hintStyle: TextStyle(
                      color: Color(0xFF94A3B8),
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                    prefixIcon: Icon(
                      Icons.search,
                      color: Color(0xFF94A3B8),
                      size: 20,
                    ),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  ),
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              ).animate().fadeIn(delay: 100.ms, duration: 200.ms).slideY(begin: -0.1, end: 0),
            ),
          ),

          // Notes Grid
          if (_isLoading)
            SliverToBoxAdapter(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(48),
                  child: CircularProgressIndicator(
                    color: PlayfulTheme.primaryTeal,
                    strokeWidth: 3,
                  ),
                ),
              ),
            )
          else if (filteredNotes.isEmpty)
            SliverToBoxAdapter(
              child: Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    vertical: isWide ? 80 : 60,
                    horizontal: 24,
                  ),
                  child: Column(
                    children: [
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Color(0xFFF1F5F9),
                              Color(0xFFE2E8F0),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.note_alt_outlined,
                          size: 36,
                          color: Color(0xFFCBD5E1),
                        ),
                      ),
                      SizedBox(height: 20),
                      Text(
                        'No notes yet',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF64748B),
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        _searchQuery.isEmpty 
                            ? 'Tap + to create your first note'
                            : 'Try a different search',
                        style: TextStyle(
                          fontSize: 14,
                          color: Color(0xFF94A3B8),
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            )
          else
            SliverPadding(
              padding: EdgeInsets.fromLTRB(
                isWide ? 24 : 20,
                0,
                isWide ? 24 : 20,
                isWide ? 120 : 100,
              ),
              sliver: SliverGrid(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: isWide ? 3 : 2,
                  crossAxisSpacing: isWide ? 20 : 12,
                  mainAxisSpacing: isWide ? 20 : 12,
                  childAspectRatio: 1,
                ),
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final note = filteredNotes[index];
                    final colorPalette = _colorPalettes[note.colorIndex];

                    return GestureDetector(
                      onTap: () => _openEditor(note: note),
                      child: Container(
                        decoration: BoxDecoration(
                          color: colorPalette.background,
                          borderRadius: BorderRadius.circular(isWide ? 28 : 20),
                          border: Border.all(
                            color: Colors.black.withOpacity(0.05),
                            width: 1,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.04),
                              blurRadius: 12,
                              offset: Offset(0, 4),
                            ),
                          ],
                        ),
                        padding: EdgeInsets.all(isWide ? 24 : 16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    note.title.isEmpty ? 'Untitled' : note.title,
                                    style: TextStyle(
                                      fontSize: isWide ? 24 : 20,
                                      fontWeight: FontWeight.bold,
                                      color: colorPalette.text,
                                      height: 1.2,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  SizedBox(height: isWide ? 12 : 8),
                                  Expanded(
                                    child: Text(
                                      note.content.isEmpty ? 'No content yet...' : note.content,
                                      style: TextStyle(
                                        fontSize: isWide ? 14 : 13,
                                        fontWeight: FontWeight.w600,
                                        color: colorPalette.text.withOpacity(0.7),
                                        height: 1.5,
                                      ),
                                      maxLines: 4,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: EdgeInsets.only(top: isWide ? 16 : 12),
                              decoration: BoxDecoration(
                                border: Border(
                                  top: BorderSide(
                                    color: Colors.black.withOpacity(0.05),
                                    width: 1,
                                  ),
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Flexible(
                                    child: Text(
                                      DateFormat('MMM d').format(note.updatedAt),
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                        color: colorPalette.text.withOpacity(0.4),
                                        letterSpacing: 1.5,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  Container(
                                    width: 32,
                                    height: 32,
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.4),
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(
                                      Icons.edit_outlined,
                                      size: 14,
                                      color: colorPalette.text,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                        .animate(delay: (30 * index).ms)
                        .fadeIn(duration: 250.ms)
                        .scale(begin: Offset(0.95, 0.95), end: Offset(1, 1), curve: Curves.easeOut);
                  },
                  childCount: filteredNotes.length,
                ),
              ),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openEditor(),
        backgroundColor: PlayfulTheme.primaryTeal,
        elevation: 8,
        child: Icon(Icons.add, color: Colors.white, size: 32),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
      ).animate().scale(delay: 400.ms, duration: 400.ms, curve: Curves.elasticOut),
    );
  }
}

// Note Editor Screen - Simple & Clean like HTML
class _NoteEditorScreen extends StatefulWidget {
  final NoteModel? note;
  final List<NoteColor> colorPalettes;
  final Function(NoteModel) onSave;
  final Function(String) onDelete;

  const _NoteEditorScreen({
    this.note,
    required this.colorPalettes,
    required this.onSave,
    required this.onDelete,
  });

  @override
  State<_NoteEditorScreen> createState() => _NoteEditorScreenState();
}

class _NoteEditorScreenState extends State<_NoteEditorScreen> {
  late TextEditingController _titleController;
  late TextEditingController _contentController;
  late int _colorIndex;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.note?.title ?? '');
    _contentController = TextEditingController(text: widget.note?.content ?? '');
    _colorIndex = widget.note?.colorIndex ?? 
        (DateTime.now().millisecondsSinceEpoch % widget.colorPalettes.length);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  void _saveNote() {
    final title = _titleController.text.trim();
    final content = _contentController.text.trim();

    if (title.isEmpty && content.isEmpty) {
      Navigator.pop(context);
      return;
    }

    final note = NoteModel(
      id: widget.note?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      content: content,
      colorIndex: _colorIndex,
      updatedAt: DateTime.now(),
    );

    widget.onSave(note);
    Navigator.pop(context);
  }

  void _deleteNote() {
    if (widget.note == null) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Delete Note',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        content: Text(
          'Are you sure you want to delete this note?',
          style: TextStyle(fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: TextStyle(fontSize: 14)),
          ),
          ElevatedButton(
            onPressed: () {
              widget.onDelete(widget.note!.id);
              Navigator.pop(context);
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            ),
            child: Text('Delete', style: TextStyle(fontSize: 14)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width > 600;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // Simple Header - matching HTML
            Padding(
              padding: EdgeInsets.fromLTRB(
                isWide ? 24 : 20,
                isWide ? 32 : 24,
                isWide ? 24 : 20,
                isWide ? 24 : 20,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Back Button
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: Theme.of(context).cardColor,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Theme.of(context).dividerColor.withOpacity(0.1)),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.02),
                                blurRadius: 4,
                                offset: Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Icon(
                            Icons.arrow_back_ios_new,
                            size: 18,
                            color: Color(0xFF64748B),
                          ),
                        ),
                        SizedBox(width: 8),
                        Text(
                          'Back',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF64748B),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Action Buttons
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (widget.note != null) ...[
                        GestureDetector(
                          onTap: _deleteNote,
                          child: Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: Color(0xFFFEF2F2),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Color(0xFFFECACA)),
                            ),
                            child: Icon(
                              Icons.delete_outline,
                              size: 18,
                              color: Color(0xFFEF4444),
                            ),
                          ),
                        ),
                        SizedBox(width: 12),
                      ],
                      GestureDetector(
                        onTap: _saveNote,
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: isWide ? 32 : 24,
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            color: PlayfulTheme.primaryTeal,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Color(0xFF0F172A).withOpacity(0.2),
                                blurRadius: 16,
                                offset: Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Text(
                            'Save Note',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Simple Content Area - matching HTML
            Expanded(
              child: Container(
                constraints: BoxConstraints(maxWidth: isWide ? 900 : double.infinity),
                margin: EdgeInsets.symmetric(horizontal: isWide ? 24 : 20),
                child: SingleChildScrollView(
                  physics: BouncingScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title Input - Simple like HTML
                      TextField(
                        controller: _titleController,
                        autofocus: widget.note == null,
                        decoration: InputDecoration(
                          hintText: 'Enter a title...',
                          hintStyle: TextStyle(
                            color: Theme.of(context).dividerColor.withOpacity(0.2),
                            fontSize: isWide ? 48 : 36,
                            fontWeight: FontWeight.w800,
                          ),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.zero,
                          fillColor: Colors.transparent, // Fix hardcoded white fill
                        ),
                        style: TextStyle(
                          fontSize: isWide ? 48 : 36,
                          fontWeight: FontWeight.w800,
                          color: Theme.of(context).colorScheme.onBackground,
                          height: 1.2,
                          letterSpacing: -1,
                        ),
                        maxLines: null,
                      ),
                      
                      SizedBox(height: 24),
                      
                      // Content Input - Simple like HTML
                      TextField(
                        controller: _contentController,
                        decoration: InputDecoration(
                          hintText: 'Start typing your thoughts here...',
                          hintStyle: TextStyle(
                            color: Color(0xFFE2E8F0),
                            fontSize: isWide ? 20 : 18,
                            fontWeight: FontWeight.w500,
                          ),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.zero,
                        ),
                        style: TextStyle(
                          fontSize: isWide ? 20 : 18,
                          fontWeight: FontWeight.w500,
                          color: Theme.of(context).colorScheme.onBackground.withOpacity(0.7),
                          height: 1.6,
                        ),
                        maxLines: null,
                        minLines: 15,
                      ),
                      
                      SizedBox(height: 100),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Models
class NoteModel {
  final String id;
  final String title;
  final String content;
  final int colorIndex;
  final DateTime updatedAt;

  NoteModel({
    required this.id,
    required this.title,
    required this.content,
    required this.colorIndex,
    required this.updatedAt,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'content': content,
        'colorIndex': colorIndex,
        'updatedAt': updatedAt.toIso8601String(),
      };

  factory NoteModel.fromJson(Map<String, dynamic> json) => NoteModel(
        id: json['id'],
        title: json['title'],
        content: json['content'],
        colorIndex: json['colorIndex'],
        updatedAt: DateTime.parse(json['updatedAt']),
      );
}

class NoteColor {
  final Color background;
  final Color text;

  NoteColor({required this.background, required this.text});
}