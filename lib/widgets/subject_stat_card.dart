import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../theme/playful_theme.dart';

class SubjectStatCard extends StatelessWidget {
  final String name;
  final Color color;
  final double progress;
  final int index;

  const SubjectStatCard({
    super.key,
    required this.name,
    required this.color,
    required this.progress,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.15),
                blurRadius: 16,
                offset: const Offset(0, 8),
              ),
              BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Subject icon with color accent
                Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(
                      width: 70,
                      height: 70,
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                    ),
                    Icon(_getSubjectIcon(name), color: color, size: 32),
                    // Progress indicator overlay
                    if (progress > 0)
                      Positioned(
                        bottom: 0,
                        child: Container(
                          width: 40,
                          height: 4,
                          decoration: BoxDecoration(
                            color: color.withOpacity(0.3),
                            borderRadius: BorderRadius.circular(2),
                          ),
                          child: FractionallySizedBox(
                            alignment: Alignment.centerLeft,
                            widthFactor: progress,
                            child: Container(
                              decoration: BoxDecoration(
                                color: color,
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 16),

                // Subject name
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: PlayfulTheme.textMain,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 12),

                // Progress info
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${(progress * 100).toInt()}% Complete',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                ),
              ],
            ),
          ),
        )
        .animate(delay: (100 * index).ms)
        .scale(duration: 400.ms, curve: Curves.elasticOut);
  }

  IconData _getSubjectIcon(String subjectName) {
    final lowerName = subjectName.toLowerCase();

    if (lowerName.contains('math')) return Icons.calculate_outlined;
    if (lowerName.contains('science')) return Icons.science_outlined;
    if (lowerName.contains('english')) return Icons.language_outlined;
    if (lowerName.contains('history')) return Icons.history_edu_outlined;
    if (lowerName.contains('geography')) return Icons.public_outlined;
    if (lowerName.contains('art')) return Icons.palette_outlined;
    if (lowerName.contains('music')) return Icons.music_note_outlined;
    if (lowerName.contains('physical') || lowerName.contains('sport'))
      return Icons.sports_soccer_outlined;
    if (lowerName.contains('computer') || lowerName.contains('tech'))
      return Icons.computer_outlined;

    return Icons.school_outlined;
  }
}
