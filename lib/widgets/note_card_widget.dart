import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../theme/playful_theme.dart';
import '../../widgets/playful_card.dart';

class NoteCard extends StatelessWidget {
  final String note;
  final String timestamp;
  final VoidCallback onTap;
  final VoidCallback? onDelete;

  const NoteCard({
    super.key,
    required this.note,
    required this.timestamp,
    required this.onTap,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final dateTime = DateTime.parse(timestamp);
    final formattedDate = DateFormat('MMM d, yyyy').format(dateTime);
    final formattedTime = DateFormat('HH:mm').format(dateTime);

    // Get first line of note for preview
    final notePreview = note.split('\n').first;
    final isLongNote = note.length > 100 || note.split('\n').length > 1;

    return PlayfulCard(
      accentColor: PlayfulTheme.primaryYellow,
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: PlayfulTheme.primaryYellow.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.note_alt_outlined,
                  size: 16,
                  color: PlayfulTheme.primaryYellow,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  notePreview,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: PlayfulTheme.textMain,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (onDelete != null)
                GestureDetector(
                  onTap: onDelete,
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.delete_outline,
                      size: 18,
                      color: Colors.red,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            note,
            style: const TextStyle(
              fontSize: 14,
              height: 1.4,
              color: PlayfulTheme.textMain,
            ),
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
          if (isLongNote)
            const Padding(
              padding: EdgeInsets.only(top: 4),
              child: Text(
                'Read more...',
                style: TextStyle(
                  fontSize: 12,
                  color: PlayfulTheme.primaryTeal,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '$formattedDate at $formattedTime',
                style: TextStyle(
                  fontSize: 12,
                  color: PlayfulTheme.textSecondary,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: PlayfulTheme.primaryTeal.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
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
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
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
    );
  }
}
