import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../services/auth_service.dart';

class EmailPasswordLoginScreen extends StatefulWidget {
  const EmailPasswordLoginScreen({super.key});

  @override
  State<EmailPasswordLoginScreen> createState() =>
      _EmailPasswordLoginScreenState();
}

class _EmailPasswordLoginScreenState extends State<EmailPasswordLoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _login() async {
    if (_formKey.currentState!.validate()) {
      final authService = Provider.of<AuthService>(context, listen: false);
      final error = await authService.login(
        _emailController.text.trim(),
        _passwordController.text.trim(),
      );

      if (error == null && mounted) {
        // Login successful - pop the email/password screen immediately
        Navigator.pop(context);
      } else if (error != null && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = Provider.of<AuthService>(context).isLoading;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Staff Login'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 400),
            padding: const EdgeInsets.all(32),
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
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Icon with animation
                  Icon(
                    Icons.admin_panel_settings,
                    size: 64,
                    color: Theme.of(context).primaryColor,
                  ).animate().scale(begin: const Offset(0.8, 0.8)).fadeIn(),
                  const SizedBox(height: 16),

                  // Title with animation
                  Text(
                    'Teacher / Admin Login',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.outfit(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ).copyWith(inherit: true),
                  ).animate(delay: 100.ms).fadeIn(),
                  const SizedBox(height: 32),

                  // Email field with animation
                  TextFormField(
                    controller: _emailController,
                    decoration: const InputDecoration(
                      labelText: 'Email',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.email),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your email';
                      }
                      return null;
                    },
                  ).animate(delay: 200.ms).fadeIn().slideX(begin: -0.3),
                  const SizedBox(height: 16),

                  // Password field with animation
                  TextFormField(
                    controller: _passwordController,
                    decoration: const InputDecoration(
                      labelText: 'Password',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.lock),
                    ),
                    obscureText: true,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your password';
                      }
                      return null;
                    },
                  ).animate(delay: 300.ms).fadeIn().slideX(begin: -0.3),
                  const SizedBox(height: 24),

                  // Login button with animation
                  ElevatedButton(
                    onPressed: isLoading ? null : _login,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).primaryColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : Text(
                            'Login',
                            style: GoogleFonts.outfit(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ).copyWith(inherit: true),
                          ),
                  ).animate(delay: 400.ms).shake(hz: 2),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
