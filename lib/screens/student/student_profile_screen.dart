import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../models/user_model.dart';
import '../../services/auth_service.dart';
import '../../theme/playful_theme.dart';
import '../student/vibrant_student_dashboard.dart';

class StudentProfileScreen extends StatefulWidget {
  const StudentProfileScreen({super.key});

  @override
  State<StudentProfileScreen> createState() => _StudentProfileScreenState();
}

class _StudentProfileScreenState extends State<StudentProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _fatherNameController = TextEditingController();
  final _rollNoController = TextEditingController();
  final _phoneController = TextEditingController();
  String? _selectedClass;
  bool _isLoading = false;

  final List<String> _classes = [
    'KG',
    'Nursery',
    '1st',
    '2nd',
    '3rd',
    '4th',
    '5th',
    '6th',
    '7th',
    '8th',
    '9th',
    '10th',
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _fatherNameController.dispose();
    _rollNoController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      try {
        final user = FirebaseAuth.instance.currentUser;
        if (user == null) return;

        final userModel = UserModel(
          uid: user.uid,
          email: user.email ?? '',
          role: 'student',
          name: _nameController.text.trim(),
          fatherName: _fatherNameController.text.trim(),
          rollNo: _rollNoController.text.trim(),
          phone: _phoneController.text.trim(),
          classId: _selectedClass,
        );

        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .set(userModel.toMap());

        // Refresh user model in AuthService
        if (mounted) {
          final authService = Provider.of<AuthService>(
            context,
            listen: false,
          );

          // Update the user model in the service
          await authService.checkLoginStatus();

          // Navigate to the student dashboard
          if (mounted) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => const VibrantStudentDashboard(),
              ),
            );
          }
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error saving profile: $e')),
          );
        }
      } finally {
        if (mounted) {
          setState(() => _isLoading = false);
        }
      }
    }
  }

  String? _validatePhoneNumber(String? value) {
    if (value == null || value.isEmpty) return 'Phone number is required';

    // Remove all spaces and dashes
    final cleaned = value.replaceAll(RegExp(r'[\s\-()]'), '');

    // Check if it matches Pakistani format
    if (RegExp(r'^(?:\+92|92|0)?3\d{9}$').hasMatch(cleaned)) {
      // Format it properly
      if (cleaned.startsWith('0')) {
        return cleaned.length == 11 ? null : 'Invalid Pakistani mobile number';
      } else if (cleaned.startsWith('+92')) {
        return cleaned.length == 13 ? null : 'Invalid Pakistani mobile number';
      } else if (cleaned.startsWith('92')) {
        return cleaned.length == 12 ? null : 'Invalid Pakistani mobile number';
      }
      return null;
    }

    return 'Please enter a valid Pakistani mobile number (03xx... or +923xx...)';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Complete Profile'),
        backgroundColor: PlayfulTheme.primaryTeal.withOpacity(0.1),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Header with icon
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: PlayfulTheme.primaryTeal.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.person,
                  size: 48,
                  color: PlayfulTheme.primaryTeal,
                ),
              ).animate().scale(begin: const Offset(0.8, 0.8)).fadeIn(),
              const SizedBox(height: 24),

              // Welcome text
              Text(
                'Welcome to Pak Turk School!',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: PlayfulTheme.textMain,
                    ),
              ).animate(delay: 100.ms),
              const SizedBox(height: 8),
              Text(
                'Please complete your profile to continue',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: PlayfulTheme.textSecondary,
                    ),
              ).animate(delay: 200.ms),
              const SizedBox(height: 32),

              // Name field
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Student Name',
                  prefixIcon: const Icon(Icons.person_outline),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                ),
                validator: (value) =>
                    value!.isEmpty ? 'Please enter student name' : null,
              ).animate(delay: 300.ms),
              const SizedBox(height: 16),

              // Father name field
              TextFormField(
                controller: _fatherNameController,
                decoration: InputDecoration(
                  labelText: 'Father Name',
                  prefixIcon: const Icon(Icons.family_restroom),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                ),
                validator: (value) =>
                    value!.isEmpty ? 'Please enter father name' : null,
              ).animate(delay: 400.ms),
              const SizedBox(height: 16),

              // Class selection
              DropdownButtonFormField<String>(
                value: _selectedClass,
                decoration: InputDecoration(
                  labelText: 'Class',
                  prefixIcon: const Icon(Icons.class_outlined),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                ),
                items: _classes
                    .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                    .toList(),
                onChanged: (v) => setState(() => _selectedClass = v),
                validator: (value) =>
                    value == null ? 'Please select a class' : null,
              ).animate(delay: 500.ms),
              const SizedBox(height: 16),

              // Roll number field
              TextFormField(
                controller: _rollNoController,
                decoration: InputDecoration(
                  labelText: 'Roll Number',
                  prefixIcon: const Icon(Icons.confirmation_number_outlined),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                ),
                keyboardType: TextInputType.number,
                validator: (value) =>
                    value!.isEmpty ? 'Please enter roll number' : null,
              ).animate(delay: 600.ms),
              const SizedBox(height: 16),

              // Phone number field
              TextFormField(
                controller: _phoneController,
                decoration: InputDecoration(
                  labelText: 'Father Phone Number',
                  hintText: '03001234567 or +923001234567',
                  prefixIcon: const Icon(Icons.phone_android),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                ),
                keyboardType: TextInputType.phone,
                validator: _validatePhoneNumber,
              ).animate(delay: 700.ms),
              const SizedBox(height: 32),

              // Save button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _isLoading ? null : _saveProfile,
                  icon: _isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Icon(Icons.save),
                  label: _isLoading
                      ? const Text('Saving...')
                      : const Text('Save Profile'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    backgroundColor: PlayfulTheme.primaryTeal,
                    foregroundColor: Colors.white,
                    elevation: 2,
                  ),
                ),
              ).animate(delay: 800.ms).shake(hz: 2),

              const SizedBox(height: 24),

              // Footer text
              Text(
                'Your information is secure and will only be used for school purposes.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: PlayfulTheme.textSecondary,
                    ),
              ).animate(delay: 900.ms),
            ],
          ),
        ),
      ),
    );
  }
}
