import 'package:flutter/material.dart';
import '../../theme/playful_theme.dart';

class VibrantLoadingWidget extends StatelessWidget {
  final String message;

  const VibrantLoadingWidget({super.key, this.message = 'Loading...'});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Animated loading indicator
            SizedBox(
              width: 50,
              height: 50,
              child: Stack(
                children: [
                  // Outer circle
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: PlayfulTheme.primaryTeal.withOpacity(0.3),
                          width: 3,
                        ),
                      ),
                    ),
                  ),
                  // Rotating inner circle
                  Positioned.fill(
                    child: CircularProgressIndicator(
                      strokeWidth: 3,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        PlayfulTheme.primaryTeal,
                      ),
                      backgroundColor: Colors.transparent,
                    ),
                  ),
                  // Center icon
                  const Center(
                    child: Icon(
                      Icons.auto_graph,
                      color: PlayfulTheme.primaryTeal,
                      size: 24,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Text(
              message,
              style: TextStyle(
                fontSize: 16,
                color: PlayfulTheme.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
