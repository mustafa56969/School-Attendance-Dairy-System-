import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/app_status_service.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';

class ServiceLockOverlay extends StatelessWidget {
  final Widget child;

  const ServiceLockOverlay({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppStatusService>(
      builder: (context, appStatus, _) {
        // If app is active, just show the child app
        if (appStatus.isAppActive) {
          return child;
        }

        // If app is locked, show the blur overlay
        return Stack(
          children: [
            // The actual app behind the blur
            child,
            
            // The non-dismissible blur overlay
            Positioned.fill(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                child: Container(
                  color: Colors.black.withOpacity(0.7),
                  child: Center(
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 32),
                      padding: const EdgeInsets.all(32),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(32),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.2),
                          width: 1.5,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.3),
                            blurRadius: 30,
                            offset: const Offset(0, 15),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Animated Lock Icon
                          Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: Colors.orange.withOpacity(0.2),
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.orange.withOpacity(0.5),
                                width: 2,
                              ),
                            ),
                            child: const Icon(
                              Icons.lock_person_rounded,
                              color: Colors.orange,
                              size: 48,
                            ),
                          ).animate(onPlay: (controller) => controller.repeat(reverse: true))
                           .scale(begin: const Offset(0.95, 0.95), end: const Offset(1.05, 1.05), duration: 1500.ms, curve: Curves.easeInOut),
                          
                          const SizedBox(height: 32),
                          
                          // Title
                          Text(
                            'Access Suspended',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.outfit(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          
                          const SizedBox(height: 16),
                          
                          // Enhanced Message
                          Text(
                            appStatus.lockMessage ?? 
                            "The app limit has been reached. Please contact the developer to renew your subscription and restore full access.",
                            textAlign: TextAlign.center,
                            style: GoogleFonts.outfit(
                              fontSize: 16,
                              color: Colors.white.withOpacity(0.8),
                              height: 1.5,
                            ),
                          ),
                          
                          const SizedBox(height: 32),
                          
                          // Contact Badge
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.05),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: Colors.white10),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.developer_mode, color: Colors.blueAccent, size: 20),
                                const SizedBox(width: 8),
                                Text(
                                  'Developer: Mustafa Riaz',
                                  style: GoogleFonts.outfit(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.blueAccent,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ).animate().fadeIn(duration: 600.ms).scale(begin: const Offset(0.9, 0.9)),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
