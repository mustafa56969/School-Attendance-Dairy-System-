import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import '../../../theme/playful_theme.dart';
import '../../../widgets/vibrant_note_card.dart';

class StudentNotesTab extends StatefulWidget {
  const StudentNotesTab({super.key});

  @override
  State<StudentNotesTab> createState() => _StudentNotesTabState();
}

class _StudentNotesTabState extends State<StudentNotesTab> {
  List<Map<String, dynamic>> _notes = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadNotes();
  }

  Future<void> _loadNotes() async {
    final prefs = await SharedPreferences.getInstance();
    final notesList = prefs.getStringList('student_notes') ?? [];
    final timestampsList =
        prefs.getStringList('student_notes_timestamps') ?? [];

    final notesWithTimestamps = <Map<String, dynamic>>[];
    for (int i = 0; i < notesList.length; i++) {
      notesWithTimestamps.add({
        'content': notesList[i],
        'timestamp': i < timestampsList.length
            ? timestampsList[i]
            : DateTime.now().toIso8601String(),
      });
    }

    // Sort by timestamp (newest first)
    notesWithTimestamps.sort(
      (a, b) => DateTime.parse(
        b['timestamp'],
      ).compareTo(DateTime.parse(a['timestamp'])),
    );

    setState(() {
      _notes = notesWithTimestamps;
      _isLoading = false;
    });
  }

  Future<void> _saveNotes() async {
    final prefs = await SharedPreferences.getInstance();
    final notesList = _notes.map((note) => note['content'] as String).toList();
    final timestampsList = _notes
        .map((note) => note['timestamp'] as String)
        .toList();

    await prefs.setStringList('student_notes', notesList);
    await prefs.setStringList('student_notes_timestamps', timestampsList);
  }

  void _deleteNote(int index) {
    setState(() {
      _notes.removeAt(index);
    });
    _saveNotes();
  }

  void _showNoteDialog({Map<String, dynamic>? note, int? index}) {
    final controller = TextEditingController(text: note?['content']);
    final isEditing = note != null;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text(
          isEditing ? 'Edit Note' : 'New Note',
          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: controller,
              autofocus: true,
              maxLines: 10,
              decoration: InputDecoration(
                hintText: 'Write your thoughts here...',
                hintStyle: TextStyle(
                  color: PlayfulTheme.textSecondary.withOpacity(0.7),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(
                    color: PlayfulTheme.primaryTeal.withOpacity(0.5),
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(
                    color: PlayfulTheme.primaryTeal,
                    width: 2,
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(
                    color: PlayfulTheme.textSecondary.withOpacity(0.3),
                  ),
                ),
                filled: true,
                fillColor: PlayfulTheme.bgColor.withOpacity(0.7),
                contentPadding: const EdgeInsets.all(16),
              ),
              style: const TextStyle(fontSize: 16, height: 1.5),
            ),
            if (isEditing) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: PlayfulTheme.primaryTeal.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.info_outline,
                      size: 18,
                      color: PlayfulTheme.primaryTeal,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Created: ${DateFormat('MMM d, yyyy \'at\' HH:mm').format(DateTime.parse(note['timestamp']))}',
                        style: const TextStyle(
                          fontSize: 13,
                          color: PlayfulTheme.primaryTeal,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
        actions: [
          if (isEditing)
            TextButton(
              onPressed: () {
                _deleteNote(index!);
                Navigator.pop(context);
              },
              style: TextButton.styleFrom(
                foregroundColor: Colors.red,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.delete_outline, size: 18),
                  SizedBox(width: 6),
                  Text(
                    'Delete',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
            child: const Text(
              'Cancel',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              if (controller.text.trim().isNotEmpty) {
                if (isEditing) {
                  setState(() {
                    _notes[index!] = {
                      'content': controller.text.trim(),
                      'timestamp': note['timestamp'], // Keep original timestamp
                    };
                  });
                } else {
                  setState(() {
                    _notes.insert(0, {
                      'content': controller.text.trim(),
                      'timestamp': DateTime.now().toIso8601String(),
                    });
                  });
                }
                _saveNotes();
                Navigator.pop(context);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: PlayfulTheme.primaryTeal,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: Text(
              isEditing ? 'Update Note' : 'Create Note',
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: PlayfulTheme.bgColor,
      body: CustomScrollView(
        slivers: [
          // Enhanced App Bar
          SliverAppBar(
            pinned: true,
            backgroundColor: Colors.white,
            expandedHeight: 100,
            collapsedHeight: 70,
            flexibleSpace: FlexibleSpaceBar(
              title: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: PlayfulTheme.primaryTeal.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.note_alt,
                      color: PlayfulTheme.primaryTeal,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'My Notes',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: PlayfulTheme.textMain,
                    ),
                  ),
                ],
              ),
              titlePadding: const EdgeInsets.only(left: 20, bottom: 16),
            ),
            centerTitle: false,
            actions: [
              if (_notes.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(right: 16, top: 8),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: PlayfulTheme.primaryTeal.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.note_alt_outlined,
                          size: 16,
                          color: PlayfulTheme.primaryTeal,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          '${_notes.length}',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: PlayfulTheme.primaryTeal,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),

          // Quick Add Bar
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
              child: GestureDetector(
                onTap: () => _showNoteDialog(),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: PlayfulTheme.primaryTeal.withOpacity(0.3),
                      width: 2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: PlayfulTheme.primaryTeal.withOpacity(0.1),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: PlayfulTheme.primaryTeal.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.add,
                          color: PlayfulTheme.primaryTeal,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Text(
                          'Quick add a note...',
                          style: TextStyle(
                            fontSize: 16,
                            color: PlayfulTheme.textSecondary,
                          ),
                        ),
                      ),
                      const Icon(
                        Icons.edit_outlined,
                        color: PlayfulTheme.primaryTeal,
                        size: 20,
                      ),
                    ],
                  ),
                ),
              ).animate().fadeIn(delay: 200.ms).slideY(begin: -0.3, end: 0),
            ),
          ),

          if (_isLoading)
            const SliverToBoxAdapter(
              child: Center(
                child: Padding(
                  padding: EdgeInsets.all(32),
                  child: CircularProgressIndicator(
                    color: PlayfulTheme.primaryTeal,
                  ),
                ),
              ),
            )
          else if (_notes.isEmpty)
            SliverToBoxAdapter(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(30),
                        decoration: BoxDecoration(
                          color: PlayfulTheme.primaryYellow.withOpacity(0.15),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.note_alt_outlined,
                          size: 70,
                          color: PlayfulTheme.primaryYellow,
                        ),
                      ).animate().scale(
                        duration: 600.ms,
                        curve: Curves.elasticOut,
                      ),
                      const SizedBox(height: 30),
                      const Text(
                        'No notes yet',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: PlayfulTheme.textMain,
                        ),
                      ).animate(delay: 200.ms).fadeIn(),
                      const SizedBox(height: 12),
                      Text(
                        'Tap the quick add bar above to create your first note',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 16,
                          color: PlayfulTheme.textSecondary,
                          height: 1.6,
                        ),
                      ).animate(delay: 400.ms).fadeIn(),
                    ],
                  ),
                ),
              ),
            )
          else
            // GRID VIEW
            SliverPadding(
              padding: const EdgeInsets.all(20),
              sliver: SliverGrid(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2, // 2 columns
                  childAspectRatio: 0.9, // Card height ratio
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                ),
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final note = _notes[index];
                    final colors = [
                      PlayfulTheme.primaryTeal,
                      PlayfulTheme.primaryPink,
                      PlayfulTheme.primaryOrange,
                      PlayfulTheme.accentPurple,
                      PlayfulTheme.primaryYellow,
                      PlayfulTheme.primaryRed,
                    ];
                    final color = colors[index % colors.length];

                    return GestureDetector(
                      onTap: () => _showNoteDialog(note: note, index: index),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: color.withOpacity(0.3),
                            width: 2,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: color.withOpacity(0.15),
                              blurRadius: 20,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Gradient Header
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [color, color.withOpacity(0.7)],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderRadius: const BorderRadius.vertical(
                                  top: Radius.circular(18),
                                ),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(6),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.25),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: const Icon(
                                      Icons.note,
                                      color: Colors.white,
                                      size: 16,
                                    ),
                                  ),
                                  const Spacer(),
                                  Text(
                                    DateFormat('MMM d').format(
                                      DateTime.parse(note['timestamp']),
                                    ),
                                    style: const TextStyle(
                                      fontSize: 11,
                                      color: Colors.white70,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            // Content
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.all(12),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        note['content'],
                                        style: const TextStyle(
                                          fontSize: 13,
                                          height: 1.5,
                                          color: PlayfulTheme.textMain,
                                        ),
                                        maxLines: 5,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          DateFormat('h:mm a').format(
                                            DateTime.parse(note['timestamp']),
                                          ),
                                          style: TextStyle(
                                            fontSize: 10,
                                            color: Colors.grey[600],
                                          ),
                                        ),
                                        Icon(
                                          Icons.arrow_forward_ios,
                                          size: 10,
                                          color: color,
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                        .animate(delay: (50 * index).ms)
                        .fadeIn(duration: 400.ms)
                        .scale(
                          begin: const Offset(0.8, 0.8),
                          curve: Curves.easeOutBack,
                        );
                  },
                  childCount: _notes.length,
                ),
              ),
            ),

          // Bottom padding
          const SliverToBoxAdapter(child: SizedBox(height: 80)),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showNoteDialog(),
        backgroundColor: PlayfulTheme.primaryTeal,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        elevation: 6,
        icon: const Icon(Icons.add, size: 24),
        label: const Text(
          'New Note',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ).animate().scale(delay: 800.ms, curve: Curves.elasticOut),
    );
  }
}
