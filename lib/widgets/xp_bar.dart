import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/playful_theme.dart';

class XpBar extends StatelessWidget {
  final int currentXp;
  final int maxXp;
  final int level;

  const XpBar({
    super.key,
    required this.currentXp,
    required this.maxXp,
    required this.level,
  });

  @override
  Widget build(BuildContext context) {
    final progress = currentXp / maxXp;
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Level $level',
                style: GoogleFonts.nunito(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: PlayfulTheme.primaryDark,
                ).copyWith(inherit: true),
              ),
              Text(
                '$currentXp/$maxXp XP',
                style: GoogleFonts.nunito(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: PlayfulTheme.primaryDark,
                ).copyWith(inherit: true),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: SizedBox(
              height: 12,
              child: Stack(
                children: [
                  Container(
                    color: Colors.grey.shade200,
                  ),
                  FractionallySizedBox(
                    widthFactor: progress.clamp(0.0, 1.0),
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [
                            PlayfulTheme.primaryTeal,
                            PlayfulTheme.primaryYellow,
                          ],
                        ),
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
