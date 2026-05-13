import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../services/auth_service.dart';
import 'email_password_login_screen.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isLoading = Provider.of<AuthService>(context).isLoading;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Theme.of(context).primaryColor,
              Theme.of(context).primaryColor.withOpacity(0.7),
              Theme.of(context).scaffoldBackgroundColor,
            ],
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24.0),
                  child: Container(
                    constraints: const BoxConstraints(maxWidth: 400),
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 40),
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // School Logo with animation
                        Container(
                              width: 120,
                              height: 120,
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(60),
                                child: Image.asset(
                                  'assets/logo.webp',
                                  fit: BoxFit.contain,
                                ),
                              ),
                            )
                            .animate()
                            .scale(begin: const Offset(0.5, 0.5))
                            .fadeIn(),
                        const SizedBox(height: 24),

                        // Title with animation
                        Text(
                          'Pak Turk School',
                          textAlign: TextAlign.center,
                            style: GoogleFonts.outfit(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).primaryColor,
                            ).copyWith(inherit: true),
                          ).animate(delay: 200.ms).fadeIn().slideX(begin: -0.5),
                        const SizedBox(height: 8),

                        // Subtitle with animation
                        Text(
                          'Timergara',
                          textAlign: TextAlign.center,
                            style: GoogleFonts.outfit(
                              fontSize: 20,
                              color: Theme.of(context).textTheme.bodySmall?.color,
                            ).copyWith(inherit: true),
                          ).animate(delay: 300.ms).fadeIn().slideX(begin: -0.5),
                        const SizedBox(height: 8),

                        Text(
                          'Student Login',
                          textAlign: TextAlign.center,
                            style: GoogleFonts.outfit(
                              fontSize: 16,
                              color: Theme.of(context).textTheme.bodySmall?.color,
                            ).copyWith(inherit: true),
                          ).animate(delay: 400.ms).fadeIn().slideX(begin: -0.3),
                        const SizedBox(height: 32),

                        // Description
                        Text(
                          'Sign in with your Google account to access your diary',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.outfit(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ).copyWith(inherit: true),
                        ).animate(delay: 500.ms).fadeIn(),
                        const SizedBox(height: 32),

                        // Google Sign In Button with animation
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: isLoading
                                ? null
                                : () async {
                                    final authService =
                                        Provider.of<AuthService>(
                                          context,
                                          listen: false,
                                        );
                                    try {
                                      final error = await authService
                                          .signInWithGoogle();

                                      if (error != null && context.mounted) {
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          SnackBar(
                                            content: Text('Login Error: $error'),
                                            backgroundColor: Colors.red,
                                            duration: const Duration(seconds: 5),
                                          ),
                                        );
                                      }
                                    } catch (e) {
                                      if (context.mounted) {
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          SnackBar(
                                            content: Text('Exception: $e'),
                                            backgroundColor: Colors.red,
                                            duration: const Duration(seconds: 5),
                                          ),
                                        );
                                      }
                                    }
                                  },
                            icon: isLoading
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2,
                                    ),
                                  )
                                : Image.network(
                                    'https://www.gstatic.com/firebasejs/ui/2.0.0/images/auth/google.svg',
                                    height: 24,
                                    errorBuilder:
                                        (context, error, stackTrace) =>
                                            const Icon(
                                              Icons.login,
                                              color: Colors.white,
                                            ),
                                  ),
                            label: Text(
                              'Sign in with Google',
                              style: GoogleFonts.outfit(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Theme.of(context).primaryColor,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 2,
                            ),
                          ),
                        ).animate(delay: 600.ms).shake(hz: 2),

                        const SizedBox(height: 24),

                        // Divider
                        Row(
                          children: [
                            Expanded(child: Divider(color: Theme.of(context).dividerColor)),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                              ),
                              child: Text(
                                'OR',
                                style: GoogleFonts.outfit(
                                  color: Theme.of(context).textTheme.bodySmall?.color,
                                ).copyWith(inherit: true),
                              ),
                            ),
                            Expanded(child: Divider(color: Theme.of(context).dividerColor)),
                          ],
                        ),

                        const SizedBox(height: 24),

                        // Email/Password Login Button
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton.icon(
                            onPressed: isLoading
                                ? null
                                : () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            const EmailPasswordLoginScreen(),
                                      ),
                                    );
                                  },
                            icon: Icon(
                              Icons.email_outlined,
                              color: Theme.of(context).textTheme.bodySmall?.color,
                            ),
                            label: Text(
                              'Sign in with Email',
                              style: GoogleFonts.outfit(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Theme.of(context).textTheme.bodySmall?.color,
                              ).copyWith(inherit: true),
                            ),
                            style: OutlinedButton.styleFrom(
                              side: BorderSide(color: Theme.of(context).dividerColor),
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 24),

                        // Footer
                        Text(
                          '© 2025 Pak Turk School\nAll rights reserved',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.outfit(
                            fontSize: 12,
                            color: Theme.of(context).textTheme.bodySmall?.color,
                          ).copyWith(inherit: true),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
