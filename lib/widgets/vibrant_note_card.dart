import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../theme/playful_theme.dart';

class VibrantNoteCard extends StatelessWidget {
  final String note;
  final String timestamp;
  final VoidCallback onTap;
  final VoidCallback? onDelete;

  const VibrantNoteCard({
    super.key,
    required this.note,
    required this.timestamp,
    required this.onTap,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final dateTime = DateTime.parse(timestamp);
    final formattedDate = DateFormat('MMM d').format(dateTime);
    final formattedTime = DateFormat('HH:mm').format(dateTime);

    // Get first few lines of note for preview
    final lines = note.split('\n');
    final notePreview = lines.take(2).join('\n');
    final isLongNote = lines.length > 2 || note.length > 150;

    // Generate a vibrant color based on note content
    final colors = [
      PlayfulTheme.primaryTeal,
      PlayfulTheme.primaryPink,
      PlayfulTheme.primaryYellow,
      PlayfulTheme.primaryOrange,
      PlayfulTheme.accentPurple,
    ];
    final colorIndex = note.hashCode.abs() % colors.length;
    final accentColor = colors[colorIndex];

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: accentColor.withOpacity(0.2),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Accent decoration
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Container(
                height: 4,
                decoration: BoxDecoration(
                  color: accentColor,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(24),
                  ),
                ),
              ),
            ),

            // Main content
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header with icon, title and delete button
                  Row(
                    children: [
                      // Note icon with gradient background
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              accentColor.withOpacity(0.2),
                              accentColor.withOpacity(0.05),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Icon(
                            _getNoteIcon(note),
                            color: accentColor,
                            size: 18,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),

                      // Note title
                      Expanded(
                        child: Text(
                          _getNoteTitle(note),
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: PlayfulTheme.textMain,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),

                      // Delete button
                      if (onDelete != null)
                        GestureDetector(
                          onTap: onDelete,
                          child: Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              color: Colors.red.withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            child: const Center(
                              child: Icon(
                                Icons.delete_outline,
                                color: Colors.red,
                                size: 18,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),

                  const SizedBox(height: 14),

                  // Note content preview with softer styling
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: PlayfulTheme.bgColor,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: accentColor.withOpacity(0.1)),
                    ),
                    child: Text(
                      notePreview,
                      style: TextStyle(
                        fontSize: 14,
                        height: 1.5,
                        color: PlayfulTheme.textMain,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),

                  if (isLongNote)
                    Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Text(
                        'Continue reading...',
                        style: TextStyle(
                          fontSize: 12,
                          color: accentColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),

                  const SizedBox(height: 14),

                  // Footer with timestamp and edit indicator
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Timestamp with modern badge design
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              accentColor.withOpacity(0.15),
                              accentColor.withOpacity(0.05),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.calendar_today_outlined,
                              size: 12,
                              color: accentColor,
                            ),
                            const SizedBox(width: 5),
                            Text(
                              '$formattedDate, $formattedTime',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: accentColor,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Edit indicator
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              PlayfulTheme.primaryTeal.withOpacity(0.15),
                              PlayfulTheme.primaryTeal.withOpacity(0.05),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.edit_outlined,
                              size: 12,
                              color: PlayfulTheme.primaryTeal,
                            ),
                            SizedBox(width: 4),
                            Text(
                              'Edit',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: PlayfulTheme.primaryTeal,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getNoteTitle(String note) {
    // Try to get the first line as title, or create a generic one
    final lines = note.trim().split('\n');
    if (lines.isNotEmpty && lines[0].trim().isNotEmpty) {
      // Limit title length to prevent overflow
      final title = lines[0].trim();
      return title.length > 30 ? '${title.substring(0, 30)}...' : title;
    }

    // If first line is empty, try to find first non-empty line
    for (final line in lines) {
      if (line.trim().isNotEmpty) {
        final title = line.trim();
        return title.length > 30 ? '${title.substring(0, 30)}...' : title;
      }
    }

    // Fallback title
    return 'Quick Note';
  }

  IconData _getNoteIcon(String note) {
    final lowerNote = note.toLowerCase();

    if (lowerNote.contains('meeting') || lowerNote.contains('discuss')) {
      return Icons.meeting_room_outlined;
    } else if (lowerNote.contains('idea') || lowerNote.contains('think')) {
      return Icons.lightbulb_outlined;
    } else if (lowerNote.contains('todo') || lowerNote.contains('task')) {
      return Icons.check_circle_outline;
    } else if (lowerNote.contains('reminder') ||
        lowerNote.contains('remember')) {
      return Icons.alarm_outlined;
    } else if (lowerNote.contains('question') || lowerNote.contains('?')) {
      return Icons.help_outline;
    } else if (lowerNote.contains('important') ||
        lowerNote.contains('urgent')) {
      return Icons.priority_high_outlined;
    }

    return Icons.sticky_note_2_outlined;
  }
}
