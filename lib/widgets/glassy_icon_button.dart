import 'package:flutter/material.dart';
import 'dart:ui';
import '../theme/playful_theme.dart';

/// Glassy icon button with badge support
class GlassyIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final Color color;
  final int badgeCount;
  final double size;

  const GlassyIconButton({
    super.key,
    required this.icon,
    required this.onTap,
    this.color = PlayfulTheme.primaryTeal,
    this.badgeCount = 0,
    this.size = 48,
  });

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final Color glassColor = isDark ? Colors.black : Colors.white;

    return GestureDetector(
      onTap: onTap,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Glassy container
          Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(size / 3),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  color.withOpacity(isDark ? 0.15 : 0.2),
                  color.withOpacity(isDark ? 0.08 : 0.1),
                ],
              ),
              border: Border.all(
                color: glassColor.withOpacity(isDark ? 0.1 : 0.3),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(isDark ? 0.3 : 0.2),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(size / 3),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Container(
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        glassColor.withOpacity(isDark ? 0.1 : 0.2),
                        glassColor.withOpacity(isDark ? 0.05 : 0.1),
                      ],
                    ),
                  ),
                  child: Icon(
                    icon,
                    color: isDark ? color.withOpacity(0.9) : color,
                    size: size * 0.5,
                  ),
                ),
              ),
            ),
          ),

          // Badge
          if (badgeCount > 0)
            Positioned(
              top: -4,
              right: -4,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white,
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.red.withOpacity(0.4),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                constraints: const BoxConstraints(
                  minWidth: 20,
                  minHeight: 20,
                ),
                child: Center(
                  child: Text(
                    badgeCount > 99 ? '99+' : badgeCount.toString(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
